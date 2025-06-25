import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../client_verify_cert/firestore_service.dart';
import '../client_verify_cert/widget/metadata.dart';


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
        .collection('clientPage')
        .doc(widget.docId)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;
      setState(() {
        metadata = Map<String, dynamic>.from(data['metadata'] ?? {});
        status = (data['status']?.toString().toLowerCase() ?? 'pending');
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
    child: Column( // 👈 Here is where your content goes
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Certificate of Completion',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        MetadataSection(metadata: metadata), // 👈 Your widget
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

