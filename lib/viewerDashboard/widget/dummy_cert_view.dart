import 'package:flutter/material.dart';
import 'package:digital_certificate_project/viewerDashboard/widget/cert_detail.dart';

class DummyCertView extends StatelessWidget {
  const DummyCertView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> certs = [
      {
        'Name': 'Jungkooks Certificate',
        'issuanceDate': 'April 25, 2025',
        'file': 'cert1.pdf',
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      itemCount: certs.length,
      itemBuilder: (context, index) {
        final cert = certs[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CertCard(
            certName: cert['Name'],
            receivedDate: cert['issuanceDate'],
            onMorePressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CertDetail(cert: cert)),
              );
            },
            certImage: null,
          ),
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
            child:
                certImage == null
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
