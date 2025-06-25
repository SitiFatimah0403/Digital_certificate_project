import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class GenerateCertPage extends StatelessWidget {
  const GenerateCertPage({super.key});

  Future<List<Map<String, dynamic>>> fetchRequestCertData() async {
    final snapshot = await FirebaseFirestore.instance.collection('requestCert').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  void _uploadFile(BuildContext context, Map<String, dynamic> data) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final file = result.files.first;
      final fileName = '${data['name']}_${DateTime.now().millisecondsSinceEpoch}.${file.extension}';
      final storageRef = FirebaseStorage.instance.ref().child('certificates/$fileName');

      try {
        await storageRef.putData(file.bytes!);
        final downloadUrl = await storageRef.getDownloadURL();

        // Optional: store uploaded cert info back in Firestore
        await FirebaseFirestore.instance.collection('uploadedCerts').add({
          'name': data['name'],
          'event': data['title'],
          'issuanceDate': data['date'],
          'fileUrl': downloadUrl,
          'fileType': file.extension,
          'uploadedAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Uploaded & saved for ${data['name']}')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Certificate Info'), centerTitle: true),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchRequestCertData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final dataList = snapshot.data!;
          if (dataList.isEmpty) {
            return const Center(child: Text('No certificate requests found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: dataList.length,
            itemBuilder: (context, index) {
              final data = dataList[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? '',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Event: ${data['title'] ?? 'No title'}"),
                      Text("Issuance Date: ${data['date'] ?? 'No date'}"),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.upload_file),
                            label: const Text("Upload Cert"),
                            onPressed: () => _uploadFile(context, data),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}


