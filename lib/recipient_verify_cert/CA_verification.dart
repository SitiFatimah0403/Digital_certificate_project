import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../recipient_upload_cert/upload_cert.dart';
import 'review_page.dart';

// This screen is for CA to verify and review submitted certificates
class CA_Verification extends StatefulWidget {
  @override
  _CAVerificationState createState() => _CAVerificationState();
}

class _CAVerificationState extends State<CA_Verification> {
  String selectedStatus = 'All';

  // Toggle between dummy data and real Firestore
  final bool useDummyData = true;

  // Sample certificates for testing without database connection
  final List<Map<String, dynamic>> dummyDocuments = [
    {
      'id': 'doc1',
      'metadata': {
        'name': 'Ayda Bin Jebat',
        'document_type': 'Diploma',
        'date_issued': '2024-05-01T00:00:00',
        'expiry_date': '2029-05-01T00:00:00',
        'organization': 'Example University'
      },
      'status': 'pending',
    },
    {
      'id': 'doc2',
      'metadata': {
        'name': 'Khairul Binti Amin',
        'document_type': 'Certificate',
        'date_issued': '2023-04-20T00:00:00',
        'expiry_date': '2028-04-20T00:00:00',
        'organization': 'Institute of Testing'
      },
      'status': 'approved',
    },
    {
      'id': 'doc3',
      'metadata': {
        'name': 'Justin Bin Abdullah Bieber',
        'document_type': 'Transcript',
        'date_issued': '2022-01-10T00:00:00',
        'expiry_date': '2027-01-10T00:00:00',
        'organization': 'Tech University'
      },
      'status': 'rejected',
    },
  ];

  // Firestore query for live documents (used if useDummyData is false)
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

  // Assign colors based on document status
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

    // Filter dummy docs based on selected status
    final filteredDocs = selectedStatus == 'All'
        ? dummyDocuments
        : dummyDocuments
            .where((doc) =>
                doc['status'].toString().toLowerCase() ==
                selectedStatus.toLowerCase())
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Certification Approval Dashboard'),
        actions: [CircleAvatar(child: Text('CA')), SizedBox(width: 10)],
      ),
      body: Column(
        children: [
          // Status filter chips
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
          // Display either dummy or real document list
          Expanded(
            child: useDummyData
                ? ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final doc = filteredDocs[index];
                      final metadata = doc['metadata'];
                      final status = doc['status'];

                      return buildListTile(
                        docId: doc['id'],
                        metadata: metadata,
                        status: status,
                      );
                    },
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: getDocumentsStream(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;
                      if (docs.isEmpty) {
                        return Center(child: Text("No documents found."));
                      }

                      return ListView.builder(
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final metadata = doc['metadata'] ?? {};
                          final status = (doc['status'] ?? 'pending').toString();

                          return buildListTile(
                            docId: doc.id,
                            metadata: metadata,
                            status: status,
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      // Upload button (used for testing or future expansion)
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => UploadScreen())),
        child: Icon(Icons.add),
      ),
    );
  }

  // Renders one certificate row with metadata and a review button
  Widget buildListTile({
    required String docId,
    required Map<String, dynamic> metadata,
    required String status,
  }) {
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
                      docId: docId,
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
              child: Text(
                status.capitalize(),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


extension StringExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1)}';
}
