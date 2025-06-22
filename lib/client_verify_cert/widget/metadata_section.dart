import 'package:flutter/material.dart';

class MetadataSection extends StatelessWidget {
  final Map<String, dynamic> metadata;

  const MetadataSection({super.key, required this.metadata});

  @override
  Widget build(BuildContext context) {
    // Use null-aware operators and fallback strings
    final recipientName = metadata['recipientName']?.toString() ?? 'Unknown Recipient';
    final certType = metadata['certType']?.toString() ?? 'Unknown Certificate';
    final issuer = metadata['issuer']?.toString() ?? 'Unknown Issuer';
    final issueDate = metadata['issueDate']?.toString().split('T').first ?? '-';
    final expiryDate = metadata['expiryDate']?.toString().split('T').first ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipientName,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          certType,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: 8),
        Text('Issuer: $issuer'),
        Text('Issued: $issueDate'),
        Text('Expires: $expiryDate'),
      ],
    );
  }
}
