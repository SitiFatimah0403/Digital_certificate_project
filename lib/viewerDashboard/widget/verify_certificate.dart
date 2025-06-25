import 'package:flutter/material.dart';

class VerifyCertificateScreen extends StatelessWidget {
  const VerifyCertificateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Certificate")),
      body: const Center(
        child: Text("Upload or enter certificate ID to verify authenticity."),
      ),
    );
  }
}
