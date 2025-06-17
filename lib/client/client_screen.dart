import 'package:flutter/material.dart';
import 'client_detail.dart';

class ClientScreen extends StatelessWidget {
  const ClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xB5ABAABB),
        title: const Text("CLIENT"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClientDetail(
            icon: Icons.document_scanner_outlined,
            label: "Request Certificate Issuance",
            destination: const RequestPage(), // nnti adjust navigation dia
          ),
          const SizedBox(height: 24),
          ClientDetail(
            icon: Icons.verified,
            label: "Review and Approve Certificates",
            destination: const ReviewPage(), // nnti adjust balik navigation dia
          ),
        ],
      ),
    );
  }
}