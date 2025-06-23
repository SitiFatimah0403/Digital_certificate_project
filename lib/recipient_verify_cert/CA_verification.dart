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

  final bool useDummyData = true;

  final List<Map<String, dynamic>> dummyDocuments = [
    {
      'id': 'doc1',
      'metadata': {
        'name': 'Ayda Bin Jebat',
        'document_type': 'Diploma',
        'date_issued': '2024-05-01T00:00:00',
        'expiry_date': '2029-05-01T00:00:00',
        'organization': 'Example University',
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
        'organization': 'Institute of Testing',
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
        'organization': 'Tech University',
      },
      'status': 'rejected',
    },
    {
      'id': 'doc4',
      'metadata': {
        'name': 'Ali Bin Zain',
        'document_type': 'SPM Certificate',
        'date_issued': '2025-06-26T00:00:00',
        'expiry_date': '2025-06-30T00:00:00',
        'organization': 'KAKNGAH UNIVERSITY',
      },
      'status': 'pending',
    },
  ];

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

    final filteredDocs =
        selectedStatus == 'All'
            ? dummyDocuments
            : dummyDocuments
                .where(
                  (doc) =>
                      doc['status'].toString().toLowerCase() ==
                      selectedStatus.toLowerCase(),
                )
                .toList();

    return Scaffold(
      backgroundColor: Color(0xFFFAF4F9),
     appBar: AppBar(
  backgroundColor: const Color.fromARGB(255, 2, 2, 2),
  title: Text(
    'Certification Approval Dashboard',
    style: TextStyle(
      color: Colors.white,
      fontFamily: 'RobotoMono',
      fontSize: 16 // Ensure this matches the font name in pubspec.yaml
    ),
  ),
  actions: [
    CircleAvatar(
      backgroundColor: Colors.white,
      child: Text(
        'CA',
        style: TextStyle(
          color: Colors.black,
          fontFamily: 'RobotoMono',
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    SizedBox(width: 10),
  ],
),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              children:
                  filters.map((status) {
                    return ChoiceChip(
                      label: Text(
                        status,
                        style: TextStyle(
                          color:
                              selectedStatus == status
                                  ? Colors.white
                                  : const Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                      selected: selectedStatus == status,
                      selectedColor: const Color.fromARGB(255, 3, 3, 3),
                      checkmarkColor: Colors.white,
                      backgroundColor: Colors.white,
                      onSelected:
                          (_) => setState(() => selectedStatus = status),
                    );
                  }).toList(),
            ),
          ),
          Expanded(
            child:
                useDummyData
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
                            final status =
                                (doc['status'] ?? 'pending').toString();

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
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UploadScreen()),
            ),
        backgroundColor: const Color.fromARGB(255, 5, 5, 5),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget buildListTile({
    required String docId,
    required Map<String, dynamic> metadata,
    required String status,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  metadata['name'] ?? 'Unknown',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  metadata['document_type'] ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                SizedBox(height: 2),
                Text(
                  'Received on: ${metadata['date_issued']?.split('T')?.first ?? ''}',
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
              ],
            ),
          ),
          Column(
            children: [
              TextButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ReviewPage(
                            docId: docId,
                            metadata: metadata,
                            status: status,
                          ),
                    ),
                  );

                  if (result == 'Approved' || result == 'Rejected') {
                    setState(() {
                      final index = dummyDocuments.indexWhere(
                        (doc) => doc['id'] == docId,
                      );
                      if (index != -1) {
                        dummyDocuments[index]['status'] = result.toLowerCase();
                      }
                    });
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Colors.black12),
                  ),
                ),
                child: Text('View'),
              ),
              SizedBox(height: 6),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: getStatusColor(status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.capitalize(),
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() =>
      this.isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;
}
