import 'package:flutter/material.dart';

class AccessSharedLinksScreen extends StatelessWidget {
  const AccessSharedLinksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Access Shared Links")),
      body: const Center(
        child: Text("Paste or open a shared certificate link here."),
      ),
    );
  }
}
