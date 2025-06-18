import 'package:flutter/material.dart';

class StatusPage extends StatelessWidget {
  final String status;

  const StatusPage({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Status Result")),
      body: Center(
        child: Text(
          'Certificate $status',
          style: TextStyle(
            fontSize: 24,
            color: status == "Approved" ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
