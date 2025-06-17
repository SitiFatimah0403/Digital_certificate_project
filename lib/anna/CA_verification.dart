import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../recipient_upload_cert/upload_cert.dart';
import 'review_page.dart';

class CA_Verification extends StatefulWidget {
  @override
  _CAVerificationState createState() => _CAVerificationState();
}

class _CAVerificationState extends State<CA_Verification> {
  String selectedStatus = 'All';

  Stream<QuerySnapshot> getDocumentsStream() {
    var collection = FirebaseFirestore.instance.collection('truecopies');
    if (selectedStatus == 'All') {
      return collection.orderBy('upload_date', descending: true).snapshots();
    } else {
      return collection
          .where('status', isEqualTo: selectedStatus.toLowerCase())
          .orderBy('upload_date', descending: true)
          .snapshots();
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Pending', 'Approved', 'Rejected'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Certification Approval Dashboard'),
        actions: [CircleAvatar(child: Text('CA')), SizedBox(width: 10)],
      ),
      body: Column(
        children: [
          Wrap(
            spacing: 8,
            children: filters.map((status) {
              return ChoiceChip(
                label: Text(status),
                selected: selectedStatus == status,
                onSelected: (_) => setState(() => selectedStatus = status),
              );
            }).toList(),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getDocumentsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;

                if (docs.isEmpty) return Center(child: Text("No documents found."));

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final metadata = doc['metadata'] ?? {};
                    final status = (doc['status'] ?? 'pending_approval').toString();

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        title: Text(metadata['name'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(metadata['document_type'] ?? ''),
                            Text(metadata['date_issued']?.split('T')?.first ?? '')
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ReviewPage(
                                      docId: doc.id,
                                      metadata: metadata,
                                      status: status,
                                    ),
                                  ),
                                );
                              },
                              child: Text('REVIEW >', style: TextStyle(color: Colors.blue)),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: getStatusColor(status),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(status.capitalize(), style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => UploadScreen())),
        child: Icon(Icons.add),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
