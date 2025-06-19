import 'package:flutter/material.dart';
import '../utils/cert_json.dart';
import 'cert_detail_page.dart';

class CertView extends StatelessWidget {
  const CertView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column( //  relying on parent ListView to handle scrolling
      children: certList.map((cert) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: CertCard(
            certName: cert['certName'],
            receivedDate: cert['receivedDate'],
            onMorePressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CertDetailPage(cert: cert),
                ),
              );
            },
            certImage: null,
          ),
        );
      }).toList(),
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
