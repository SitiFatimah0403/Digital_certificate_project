import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firestore_service.dart';


class StatusBanner extends StatelessWidget {
  final String status;

  const StatusBanner({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    if (status.toLowerCase() != 'pending') return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.grey.shade300,
      child: Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Text('Status: Pending Approval'),
        ],
      ),
    );
  }
}

class ReviewPage extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> metadata;
  final String status;

  const ReviewPage({
    required this.docId,
    required this.metadata,
    required this.status,
    Key? key,
  }) : super(key: key);

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool isLoading = false;

  final FirestoreService _firestoreService = FirestoreService();


  Future<void> updateStatus(BuildContext context, String newStatus) async {
  setState(() => isLoading = true);

  try {
    await _firestoreService.updateCertificateStatus(widget.docId, newStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to $newStatus')),
    );
    Navigator.pop(context);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to update status: $e')),
    );
  } finally {
    setState(() => isLoading = false);
  }
}


  void _showConfirmationDialog(BuildContext context, String newStatus) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm $newStatus'),
        content: Text('Are you sure you want to mark this certificate as "$newStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              updateStatus(context, newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'Approved' ? Colors.green : Colors.red,
            ),
            child: Text('Yes, $newStatus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Review Certificate Document')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBanner(status: widget.status),
                  SizedBox(height: 20),
                  MetadataSection(metadata: widget.metadata),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showConfirmationDialog(context, 'Approved'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: Text('Approve'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showConfirmationDialog(context, 'Rejected'),
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

class MetadataSection extends StatelessWidget {
  final Map<String, dynamic> metadata;

  const MetadataSection({required this.metadata, super.key});

  String formatDate(String? iso) {
    if (iso == null) return '';
    return iso.split('T').first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name: ${metadata['name'] ?? ''}'),
        Text('Issued Organisation: ${metadata['organization'] ?? ''}'),
        Text('Title: ${metadata['document_type'] ?? ''}'),
        Text('Date Issued: ${formatDate(metadata['date_issued'])}'),
        Text('Expiry Date: ${formatDate(metadata['expiry_date'])}'),
      ],
    );
  }
}
