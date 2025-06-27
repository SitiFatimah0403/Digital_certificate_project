import 'package:digital_certificate_project/Components/round_logo.dart';
import 'package:digital_certificate_project/auth/models/user_model.dart';
import 'package:digital_certificate_project/auth/services/firestore_user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirestoreUserService firestoreService = FirestoreUserService();
  bool passwordVisible = false;

  Future<void> signUpUser(String email, String password) async {
    try {
      if (!email.endsWith('@student.upm.edu.my' )) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Only @student.upm.edu.my emails are allowed')),
        );
        return;
      }

      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        final newUser = AppUser(
          uid: firebaseUser.uid,
          email: email,
          password: password,
          role: 'recipient',
        );


        await firestoreService.saveUser(newUser);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup successful! Please log in.')),
        );

        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Signup failed';

      if (e.code == 'email-already-in-use') {
        message = 'Email already in use. Please log in.';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email format.';
      } else if (e.code == 'weak-password') {
        message = 'Password should be at least 6 characters.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e, stackTrace) {
  print('🔥 Signup error: $e');
  print('📄 Stack trace: $stackTrace');

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Signup failed: $e')),
  );
}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(title: Text("Sign Up")),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 30),
          children: [
            SizedBox(height: 50),
           const Center(
            child: RoundLogoWidget(
              size: 80,
              fontSize: 14,
              label: 'TrustCert',
               ),
              ),
            SizedBox(height: 40),

            Text('Email', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
            SizedBox(height: 5),
            TextFormField(
              controller: emailController,
              decoration: InputDecoration(
                hintText: 'Enter your email',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: 20),

            Text('Password', style: TextStyle(color: Colors.grey[700], fontSize: 16)),
            SizedBox(height: 5),
            TextFormField(
              controller: passwordController,
              obscureText: !passwordVisible,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                suffixIcon: IconButton(
                  icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => passwordVisible = !passwordVisible),
                ),
              ),
            ),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                final email = emailController.text.trim();
                final password = passwordController.text.trim();
                if (email.isNotEmpty && password.isNotEmpty) {
                  signUpUser(email, password);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter all fields')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Sign Up', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
