import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'cert_detail_page.dart';

class CertView extends StatelessWidget {
  const CertView({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('recipientCert').snapshots(),
      builder: (context, snapshot) {
        print("Firestore connection state: ${snapshot.connectionState}");
        print("Has error: ${snapshot.hasError}");
        print("Docs: ${snapshot.data?.docs.length}");

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No certificates found.'));
        }

        final certs = snapshot.data!.docs;

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(top: 20, bottom: 20),
          children: certs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            // Format Firestore Timestamp to readable string
            String formattedDate = 'Unknown';
            if (data['issuanceDate'] is Timestamp) {
              final timestamp = data['issuanceDate'] as Timestamp;
              formattedDate =
                  DateFormat('MMMM d, yyyy').format(timestamp.toDate());
            } else if (data['issuanceDate'] is String) {
              formattedDate = data['issuanceDate'];
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: CertCard(
                certName: data['Name'] ?? 'Unknown',
                receivedDate: formattedDate,
                onMorePressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CertDetailPage(cert: data),
                    ),
                  );
                },
                certImage: null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class CertCard extends StatelessWidget {
  final String certName;
  final String receivedDate;
  final VoidCallback onMorePressed;
  final ImageProvider? certImage;

  const CertCard({
    super.key,
    required this.certName,
    required this.receivedDate,
    required this.onMorePressed,
    this.certImage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFFECEAEA),
        borderRadius: BorderRadius.circular(21),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[300],
            backgroundImage: certImage,
            child: certImage == null
                ? const Icon(Icons.person, size: 30, color: Colors.black54)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Received on: $receivedDate',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onMorePressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black26),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text("View"),
          ),
        ],
      ),
    );
  }
}
