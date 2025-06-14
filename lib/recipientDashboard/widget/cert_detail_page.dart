import 'package:flutter/material.dart';

class CertDetailPage extends StatelessWidget {
  final Map<String, dynamic> cert;

  const CertDetailPage({super.key, required this.cert});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cert['certName']),
      ),
      body: Center(
        child: Text('You received this certificate on ${cert['receivedDate']}'),
      ),
    );
  }
}
