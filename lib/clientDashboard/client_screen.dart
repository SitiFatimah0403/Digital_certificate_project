import 'package:digital_certificate_project/auth/services/auth_service.dart';
import 'package:digital_certificate_project/clientDashboard/requestCert.dart';
import 'package:flutter/material.dart';
import 'client_detail.dart';
import '../client_verify_cert/CA_ClientVerification.dart';

class ClientScreen extends StatelessWidget {
  ClientScreen({super.key});

  final AuthService _authService = AuthService(); // for sign out - Fatimah

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF096192),
        title: const Text(
          "CLIENT",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'RobotoMono',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _authService.signOut(); // call method from AuthService
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClientDetail(
            icon: Icons.document_scanner_outlined,
            label: "Request Certificate Issuance",
            destination: Requestcert(),
          ),
          const SizedBox(height: 24),
          ClientDetail(
            icon: Icons.verified,
            label: "Review and Approve Certificates",
            destination: CA_Verification(),
          ),
        ],
      ),
    );
  }
}
