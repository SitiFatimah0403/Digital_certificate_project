import 'package:flutter/material.dart';
import '../widget/cert_view.dart';
import 'package:digital_certificate_project/auth/services/auth_service.dart';

class HomeScreen extends StatelessWidget {
   HomeScreen({super.key});

  // ✅ Create an instance of AuthService
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(181, 42, 38, 51),
         title: const Text(
        "RECIPIENT",
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
            icon: Icon(Icons.logout, color: Colors.white,),
            onPressed: () async {
              await _authService.signOut(); // ✅ call method from AuthService
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false, // Clear all previous screens
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 40, bottom: 20),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your Cert",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15),
          CertView(),
        ],
      ),
    );
  }
}
