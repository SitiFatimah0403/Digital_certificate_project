import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firestore_service.dart';
import 'package:digital_certificate_project/recipient_verify_cert/widget/metadata_section.dart';

// Shows a banner for pending documents
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

// Review screen to approve or reject a certificate
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
  bool useDummyMode = true; // Toggle to false when ready for real Firestore

  // Updates the document status (dummy or real)
  Future<void> updateStatus(BuildContext context, String newStatus) async {
    setState(() => isLoading = true);

    try {
      if (useDummyMode) {
        await Future.delayed(Duration(seconds: 1)); // Simulate delay
      } else {
        await _firestoreService.updateCertificateStatus(widget.docId, newStatus);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus${useDummyMode }')),
      );
      Navigator.pop(context, newStatus); // Send the updated status back

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Ask user to confirm before changing the document status
  void _showConfirmationDialog(BuildContext context, String newStatus) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Confirm $newStatus'),
        content: Text(
          'Are you sure you want to mark this certificate as "$newStatus"?',
        ),
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
              backgroundColor:
                  newStatus == 'Approved' ? Colors.green : Colors.red,
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: Text('Approve'),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _showConfirmationDialog(context, 'Rejected'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
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
