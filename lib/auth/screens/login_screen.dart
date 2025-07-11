import 'package:digital_certificate_project/auth/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'signin_screen.dart';
import '../../Components/round_logo.dart';
import '../services/auth_service.dart';
import '../services/firestore_user_service.dart'; 
import 'package:firebase_auth/firebase_auth.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState(); 
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false;

  final FirestoreUserService firestoreService = FirestoreUserService();

  // Google Sign-In logic
/*void _handleGoogleSignIn() async {
  try {
    final user = await AuthService().signInWithGoogle();

    if (user != null) {
      final uid = user.uid;
      final email = user.email!;

      // Check if the user already exists in Firestore
      final existingUser = await firestoreService.getUserByUid(uid);

      if (existingUser == null) {
        // If not, save new user with default role
        await FirebaseFirestore.instance.collection('users').doc(email).set({
          'uid': uid,
          'email': email,
          'role': 'recipient', // You can change this default role as needed
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

  // Get the role from Firestore
      final role = await firestoreService.getUserRole(uid);

      if (role != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In successful!')),
        );

        // Navigate to appropriate dashboard based on role
        if (role == 'recipient') {
          Navigator.pushReplacementNamed(context, '/recipientDashboard');
        } else if (role == 'CA') {
          Navigator.pushReplacementNamed(context, '/caDashboard'); 
        } else {
          Navigator.pushReplacementNamed(context, '/'); //nanti add sini lagi
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User role not found in Firestore')),
        );
      }
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Google Sign-In failed: $e')),
    );
  }
}*/

//try new google sign in
void _handleGoogleSignIn() async {
  try {
    // Sign out any existing sessions first
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();

    final user = await AuthService().signInWithGoogle();

    if (user != null) {
      final email = user.email!;
      final uid = user.uid;

      // Check if the user already exists
      final existingUser = await firestoreService.getUserByEmail(email);

      if (existingUser == null) {
        // Register user in Firestore with default role
        await firestoreService.saveUser(
          AppUser(uid: uid, email: email, role: 'recipient'),
        );
      }

      // Get user role
      final role = await firestoreService.getUserRole(email);

      if (role != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Google Sign-In successful!')),
        );

        // Redirect based on role
        switch (role) {
          case 'recipient':
            Navigator.pushReplacementNamed(context, '/recipientDashboard');
            break;
          case 'CA':
            Navigator.pushReplacementNamed(context, '/caDashboard');
            break;
          case 'Client':
            Navigator.pushReplacementNamed(context, '/clientDashboard');
            break;
          case 'Admin':
            Navigator.pushReplacementNamed(context, '/adminDashboard');
            break;
          case 'Viewer':
            Navigator.pushReplacementNamed(context, '/viewerDashboard');
            break;
          default:
            Navigator.pushReplacementNamed(context, '/recipientDashboard');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No role found for this user.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Google Sign-In error: $e')),
    );
  }
}



  // Email/password login
  Future<void> loginUser(String email, String password) async {
    try {
    // Sign in using Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    final user = userCredential.user;

    if (user != null) {
      // Fetch role from Firestore using the signed-in user's UID
      final userData = await firestoreService.getUserByEmail(email);

      if (userData != null) {
        final role = userData['role'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );

        if (role == 'recipient') {
          Navigator.pushReplacementNamed(context, '/recipientDashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User role not found in Firestore')),
        );
      }
    }
  } on FirebaseAuthException catch (e) {
    String message = 'Login failed';

    if (e.code == 'user-not-found') {
      message = 'No user found with that email.';
    } else if (e.code == 'wrong-password') {
      message = 'Incorrect password.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Login failed: $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 30),
          children: [
            SizedBox(height: 100),
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
            SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: Text('Forgot Password?', style: TextStyle(fontSize: 13)),
            ),
            SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                final email = emailController.text.trim();
                final password = passwordController.text;
                if (email.isNotEmpty && password.isNotEmpty) {
                  loginUser(email, password);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please enter all fields')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF096192),
                minimumSize: Size(double.infinity, 44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Log In', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account yet? ", style: TextStyle(color: Colors.grey[700], fontSize: 16)),
                TextButton(
                  child: Text("Sign Up"),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => SignUpScreen()),
                    );
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _handleGoogleSignIn,
              icon: const Icon(Icons.login),
              label: const Text('Sign in with Google'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
