import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class CertDetailPage extends StatefulWidget {
  final Map<String, dynamic> cert;

  const CertDetailPage({super.key, required this.cert});

  @override
  State<CertDetailPage> createState() => _CertDetailPageState();
}

class _CertDetailPageState extends State<CertDetailPage> {
  late PdfControllerPinch pdfController;

  @override
  void initState() {
    super.initState();

    final String pdfFile = widget.cert['file'] ?? 'default.pdf';

    pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset('assets/pdfs/$pdfFile'),
    );
  }

  @override
  void dispose() {
    pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Certificate')),
      body: PdfViewPinch(controller: pdfController),
    );
  }
}
