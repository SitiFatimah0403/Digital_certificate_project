import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class CertDetailPage extends StatefulWidget {
  final Map<String, dynamic> cert;

  const CertDetailPage({super.key, required this.cert});

  @override
  State<CertDetailPage> createState() => _CertDetailPageState();
}

class _CertDetailPageState extends State<CertDetailPage> {
  PdfControllerPinch? pdfController;

  @override
  void initState() {
    super.initState();
    final String fileName = widget.cert['file'] ?? 'default.pdf';
    pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset('assets/pdfs/$fileName'),
    );
  }

  @override
  void dispose() {
    pdfController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.cert['Name'] ?? 'View Certificate')),
      body: pdfController == null
          ? const Center(child: CircularProgressIndicator())
          : PdfViewPinch(controller: pdfController!),
    );
  }
}
