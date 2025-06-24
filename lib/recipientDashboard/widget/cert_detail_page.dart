import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdfx/pdfx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

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
    final fileName = widget.cert['file'] ?? 'default.pdf';
    pdfController = PdfControllerPinch(
      document: PdfDocument.openAsset('assets/pdfs/$fileName'),
    );
  }

  @override
  void dispose() {
    pdfController?.dispose();
    super.dispose();
  }

  Future<void> sharePdf() async {
    final fileName = widget.cert['file'] ?? 'default.pdf';

    // Load from assets
    final byteData = await rootBundle.load('assets/pdfs/$fileName');

    // Save to temp file
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());

    // Share the file
    await Share.shareXFiles([XFile(tempFile.path)], text: 'Check out my certificate!');
  }

  @override
  Widget build(BuildContext context) {
    final certName = widget.cert['Name'] ?? 'Certificate';

    return Scaffold(
      appBar: AppBar(
        title: Text(certName),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_sharp),
            onPressed: sharePdf,
          ),
        ],
      ),
      body: pdfController == null
          ? const Center(child: CircularProgressIndicator())
          : PdfViewPinch(controller: pdfController!),
    );
  }
}
