import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> metadata;
  final String status;

  ReviewPage({required this.docId, required this.metadata, required this.status});

  Future<void> updateStatus(BuildContext context, String newStatus) async {
    await FirebaseFirestore.instance
        .collection('truecopies')
        .doc(docId)
        .update({'status': newStatus.toLowerCase()});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to $newStatus')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review Certificate Document')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (status.toLowerCase() == 'pending')
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.grey.shade300,
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Status: Pending Approval'),
                  ],
                ),
              ),
            SizedBox(height: 20),
            Text('Name: ${metadata['name'] ?? ''}'),
            Text('Issued Organisation: ${metadata['organization'] ?? ''}'),
            Text('Title: ${metadata['document_type'] ?? ''}'),
            Text('Date Issued: ${metadata['date_issued']?.split('T')?.first ?? ''}'),
            Text('Expiry Date: ${metadata['expiry_date']?.split('T')?.first ?? ''}'),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => updateStatus(context, 'Approved'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: Text('Approve'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => updateStatus(context, 'Rejected'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: Text('Reject'),
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
