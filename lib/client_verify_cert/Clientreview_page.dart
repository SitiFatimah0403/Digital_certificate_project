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
          SizedBox(width: 8),
          Text('Status: Pending Approval', style: TextStyle(fontSize: 16)),
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
  bool isLoading = true;
  final FirestoreService _firestoreService = FirestoreService();

  Map<String, dynamic> metadata = {};
  String status = 'pending';

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  Future<void> loadDocument() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('truecopies')
          .doc(widget.docId)
          .get();

      if (doc.exists) {
        setState(() {
          metadata = Map<String, dynamic>.from(doc['metadata'] ?? {});
          status = (doc['status']?.toString().toLowerCase() ?? 'pending');
          isLoading = false;
        });
      } else {
        throw Exception("Document not found.");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load document: $e')),
      );
    }
  }

  Future<void> updateStatus(BuildContext context, String newStatus) async {
    try {
      await _firestoreService.updateDocumentStatus(widget.docId, newStatus.toLowerCase());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to "$newStatus".')),
      );

      setState(() => isLoading = true);
      await loadDocument();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
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

  Widget buildCertificateCard() {
    final recipient = metadata['recipientName'] ?? metadata['name'] ?? 'Unknown Recipient';
    final issuer = metadata['organizationName'] ?? metadata['organization'] ?? 'Unknown Issuer';
    final course = metadata['courseName'] ?? metadata['document_type'] ?? 'Course';
    final issuedDate = metadata['issuedDate'] ?? metadata['date_issued'] ?? 'N/A';
    final expiryDate = metadata['expiryDate'] ?? metadata['expiry_date'] ?? 'N/A';

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            issuer,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text(
            'Certificate of Completion',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text('This is to certify that', style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          Text(
            recipient,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'has successfully completed the course',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            course,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 20),
          Text('Issued on: $issuedDate', style: TextStyle(fontSize: 14)),
          SizedBox(height: 4),
          Text('Valid until: $expiryDate', style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Certificate Document'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StatusBanner(status: status),
                  SizedBox(height: 20),
                  buildCertificateCard(),
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

