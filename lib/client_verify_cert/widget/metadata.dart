import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MetadataSection extends StatelessWidget {
  final Map<String, dynamic> metadata;

  const MetadataSection({required this.metadata, super.key});

  String formatDate(dynamic dateValue) {
    if (dateValue == null) return '';
    if (dateValue is String) {
      return dateValue.split('T').first;
    }
    if (dateValue is DateTime) {
      return dateValue.toIso8601String().split('T').first;
    }
    if (dateValue is Timestamp) {
      return dateValue.toDate().toIso8601String().split('T').first;
    }
    return dateValue.toString();
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
