import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("Sign in with Google"),
          onPressed: () async {
            try {
              final user = await _authService.signInWithGoogle();
              if (user != null) {
                Navigator.pushReplacementNamed(context, '/dashboard'); // route to role-based dashboard
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
        ),
      ),
    );
  }
}
