import 'package:flutter/material.dart';

class AccessSharedLinksScreen extends StatefulWidget {
  const AccessSharedLinksScreen({super.key});

  @override
  State<AccessSharedLinksScreen> createState() => _AccessSharedLinksScreenState();
}

class _AccessSharedLinksScreenState extends State<AccessSharedLinksScreen> {
  final TextEditingController _linkController = TextEditingController();
  String? _errorText;

  void _accessCertificate() {
    final link = _linkController.text.trim();

    if (link.isEmpty || !link.startsWith("http")) {
      setState(() {
        _errorText = "Please enter a valid link (starting with http)";
      });
      return;
    }

    setState(() {
      _errorText = null;
    });

    // acah acah access the cert
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Accessing certificate from:\n$link")),
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white), 
        title: const Text(
          "Access Shared Links",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter Shared Link:",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _linkController,
              decoration: InputDecoration(
                hintText: "https://example.com/certificate/abc123",
                border: OutlineInputBorder(),
                errorText: _errorText,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _accessCertificate,
                icon: const Icon(Icons.link),
                label: const Text("Access Certificate"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
