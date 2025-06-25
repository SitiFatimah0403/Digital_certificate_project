import 'package:flutter/material.dart';

class AuthenticateAccessScreen extends StatelessWidget {
  const AuthenticateAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Authenticate Access")),
      body: const Center(
        child: Text("Authenticate yourself to access secured certificates."),
      ),
    );
  }
}
