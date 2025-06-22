import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Clientreview_page.dart';



class ClientVerification extends StatefulWidget {
  @override
  _CAVerificationState createState() => _CAVerificationState();
}

class _CAVerificationState extends State<ClientVerification> {
  String selectedStatus = 'All';
  final bool useDummyData = true;

  final List<Map<String, dynamic>> dummyDocuments = [
    {
      'id': 'doc1',
      "status": "pending",
      "upload_date": "2024-06-21T12:00:00Z",
      "metadata": {
        "name": "Ayda Bin Jebat",
        "document_type": "Diploma",
        "date_issued": "2024-05-01",
        "expiry_date": "2029-05-01",
        "organization": "Example University",
      },
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
      appBar: AppBar(
        title: Text('Certification Approval Dashboard'),
        actions: [CircleAvatar(child: Text('CL')), SizedBox(width: 10)],
      ),
      body: Column(
        children: [
          Wrap(
            spacing: 8,
            children:
                filters
                    .map(
                      (status) => ChoiceChip(
                        label: Text(status),
                        selected: selectedStatus == status,
                        onSelected:
                            (_) => setState(() => selectedStatus = status),
                      ),
                    )
                    .toList(),
          ),
          Expanded(
            child:
                useDummyData
                    ? ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final doc = filteredDocs[index];
                        return buildListTile(
                          docId: doc['id'] ?? '',
                          metadata: doc['metadata'],
                          status: doc['status'],
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
    );
  }

  Widget buildListTile({
    required String docId,
    required Map<String, dynamic> metadata,
    required String status,
  }) {
    String name = metadata['name']?.toString() ?? 'Unknown';
    String type = metadata['document_type']?.toString() ?? 'Document';
    String issued = metadata['date_issued']?.split('T')?.first ?? '';
    String expiry = metadata['expiry_date']?.split('T')?.first ?? '';
    String org = metadata['organization']?.toString() ?? 'Unknown Organization';

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Name and Type
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  type,
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
              ],
            ),
            Divider(height: 20, thickness: 1.2),

            // Organization and Dates (Plain Text)
            Text("Organization: $org", style: TextStyle(fontSize: 14)),
            SizedBox(height: 6),
            Text("Issued: $issued", style: TextStyle(fontSize: 14)),
            Text("Expires: $expiry", style: TextStyle(fontSize: 14)),
            SizedBox(height: 12),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
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
                  },
                  child: Text('REVIEW'),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: getStatusColor(status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.capitalize(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';
}
