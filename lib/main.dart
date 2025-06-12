import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'auth/screens/login_screen.dart';
import 'core/constants.dart';
import 'auth/services/auth_service.dart';
import 'auth/utils/role_checker.dart'; // Optional: for role-based redirection
import 'package:cloud_firestore/cloud_firestore.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ); // ensure firebase_options.dart is set up

  final firestore = FirebaseFirestore.instance;

  await firestore.collection('users').doc('testuser@example.com').set({
    'email': 'testuser@example.com',
    'role': 'recipient',
    'createdAt': FieldValue.serverTimestamp(),
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Certificate Repository',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: AuthWrapper(), // controls where to go after startup
      routes: {
        '/login': (context) => LoginScreen(),
        '/adminDashboard': (context) => PlaceholderScreen('Admin Dashboard'),
        '/caDashboard': (context) => PlaceholderScreen('CA Dashboard'),
        '/recipientDashboard': (context) => PlaceholderScreen('Recipient Dashboard'),
        '/clientDashboard' : (context) => PlaceholderScreen('Client'),
        '/viewerDashboard' : (context) => PlaceholderScreen('Viewer'),
        '/unauthorized': (context) => PlaceholderScreen('Unauthorized'),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return LoginScreen();
    } else {
      // TODO: Replace this with actual role fetch from Firestore or backend
      String role = 'CA'; // Contoh je buat masa ni, Hardcoded for demo (replace later)

      final route = getRedirectRoute(role); //determines which screen to navigate to (based on the role)
      Future.microtask(() { //ensures navigation is triggered after the widget tree builds
        Navigator.pushReplacementNamed(context, route);
      });

      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}

class PlaceholderScreen extends StatelessWidget { //This is a temporary screen to stand in for your future dashboards (like Admin, CA, etc.).
  final String title;

  PlaceholderScreen(this.title);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title Content Here')),
    );
  }
}
