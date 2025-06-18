import 'package:flutter/material.dart';

// Reusable widget to display document metadata
class MetadataSection extends StatelessWidget {
  final Map<String, dynamic> metadata;

  const MetadataSection({required this.metadata, super.key});

  String formatDate(String? iso) {
    if (iso == null) return '';
    return iso.split('T').first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name: ${metadata['name'] ?? ''}'),
        Text('Issued Organisation: ${metadata['organization'] ?? ''}'),
        Text('Title: ${metadata['document_type'] ?? ''}'),
        Text('Date Issued: ${formatDate(metadata['date_issued'])}'),
        Text('Expiry Date: ${formatDate(metadata['expiry_date'])}'),
      ],
    );
  }
}
