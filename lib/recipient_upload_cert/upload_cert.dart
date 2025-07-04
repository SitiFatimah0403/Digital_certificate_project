import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Home Page"), backgroundColor: Colors.black),
      body: Center(
        child: ElevatedButton(
          child: Text("Go to Upload Page"),
          onPressed: () {
            Navigator.pushNamed(context, '/upload');
          },
        ),
      ),
    );
  }
}

class UploadScreen extends StatefulWidget {
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? selectedFile;
  String? fileName;
  String status = "No file selected";

  final nameController = TextEditingController();
  final orgController = TextEditingController();
  final docTypeController = TextEditingController();

  DateTime? issueDate;
  DateTime? expiryDate;

  bool metadataExtracted = false;

  Future<Map<String, String>> extractMetadataFromPDF(File file) async {
    final bytes = await file.readAsBytes();
    final document = PdfDocument(inputBytes: bytes);
    final text = PdfTextExtractor(document).extractText();
    document.dispose();

    final nameMatch = RegExp(r'Name\s*:\s*(.+)').firstMatch(text);
    final orgMatch = RegExp(r'Organization\s*:\s*(.+)').firstMatch(text);
    final typeMatch = RegExp(r'Document Type\s*:\s*(.+)').firstMatch(text);

    return {
      'name': nameMatch?.group(1)?.trim() ?? '',
      'organization': orgMatch?.group(1)?.trim() ?? '',
      'document_type': typeMatch?.group(1)?.trim() ?? '',
    };
  }

  Future<void> pickDate(BuildContext context, bool isIssueDate) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    print("🗓️ Date selected: $selected");

    if (!mounted) return;
    if (selected != null) {
      setState(() {
        if (isIssueDate) {
          issueDate = selected;
        } else {
          expiryDate = selected;
        }
      });
    }
  }

  Future<void> pickFile({bool isImage = false}) async {
    if (isImage) {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          selectedFile = File(picked.path);
          fileName = picked.name;
          status = "✅ Image selected. Please enter metadata manually.";
          metadataExtracted = false; // ✅ ADDED HERE
        });
      }
    } else {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final extracted = await extractMetadataFromPDF(file);

        setState(() {
          selectedFile = file;
          fileName = result.files.single.name;
          nameController.text = extracted['name'] ?? '';
          orgController.text = extracted['organization'] ?? '';
          docTypeController.text = extracted['document_type'] ?? '';
          status = "✅ PDF loaded and metadata extracted.";
          metadataExtracted = true;
        });
      }
    }
  }

  Future<void> uploadAndSave() async {
    print("🚀 Starting upload process...");
    print("📂 File: $fileName");
    print("👤 Current user: ${FirebaseAuth.instance.currentUser}");

    if (selectedFile == null ||
        nameController.text.isEmpty ||
        orgController.text.isEmpty ||
        docTypeController.text.isEmpty ||
        issueDate == null ||
        expiryDate == null) {
      setState(() {
        status = "❗ Please complete all fields before uploading.";
      });
      return;
    }

    try {
      /* ni untuk testing*/
      //final userId = FirebaseAuth.instance.currentUser?.uid ?? 'test_user';
      //print("🧪 Using userId: $userId");

      //ni untuk dynamic user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          status = "❗ User not signed in.";
        });
        return;
      }

      final uuid = Uuid().v4();

      /*try untuk tengok extract ke tak ke firestore
      final storageRef = FirebaseStorage.instance.ref(
        'truecopies/${user.uid}/$uuid-$fileName',
      );

      await storageRef.putFile(selectedFile!, SettableMetadata());
      final downloadUrl = await storageRef.getDownloadURL();
      */

      // TEMPORARILY BYPASSING STORAGE FOR TESTING
      final downloadUrl = "https://example.com/dummy.pdf";

      final docRef = FirebaseFirestore.instance.collection('truecopies').doc();
      await docRef.set({
        'user_id': user.uid,
        'file_url': downloadUrl,
        'file_name': fileName,
        'upload_date': DateTime.now(),
        'status': 'pending_approval',
        'verified': false,
        'metadata': {
          'name': nameController.text,
          'organization': orgController.text,
          'document_type': docTypeController.text,
          'date_issued': issueDate!.toIso8601String(),
          'expiry_date': expiryDate!.toIso8601String(),
        },
      });

      setState(() {
        status = "✅ File uploaded and metadata saved successfully!";
      });
    } catch (e) {
      print("❌ Upload failed: $e");

      setState(() {
        status = "❌ Upload failed: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload True Copy", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              /*ElevatedButton(
                onPressed: () => pickFile(isImage: true),
                child: Text("Upload Image"),
              ),*/
              ElevatedButton(
                onPressed: () => pickFile(isImage: false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black, // 🔲 Black background
                  foregroundColor: Colors.white, // ⚪ Optional: white text
                ),
                child: Text("Upload PDF"),
              ),
              SizedBox(height: 10),
              Text(fileName != null ? "Selected: $fileName" : status),
              if (selectedFile != null) ...[
                SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Full Name"),
                ),
                TextField(
                  controller: orgController,
                  decoration: InputDecoration(labelText: "Organization"),
                ),
                TextField(
                  controller: docTypeController,
                  decoration: InputDecoration(labelText: "Document Type"),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Issued: ${issueDate != null ? issueDate!.toLocal().toString().split(' ')[0] : 'Not set'}",
                    ),
                    ElevatedButton(
                      onPressed: () => pickDate(context, true),
                      child: Text("Select Issue Date"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // 🔲 Black background
                        foregroundColor: Colors.white, // ⚪ Optional: white text
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Expiry: ${expiryDate != null ? expiryDate!.toLocal().toString().split(' ')[0] : 'Not set'}",
                    ),
                    ElevatedButton(
                      onPressed: () => pickDate(context, false),
                      child: Text("Select Expiry Date"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black, // 🔲 Black background
                        foregroundColor: Colors.white, // ⚪ Optional: white text
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: uploadAndSave,
                  child: Text("Submit & Upload"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // 🔲 Black background
                    foregroundColor: Colors.white, // ⚪ Optional: white text
                  ),
                ),
              ],
              SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
