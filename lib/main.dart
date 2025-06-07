import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/screens/login_screen.dart';
import 'core/constants.dart';
import 'auth/services/auth_service.dart';
import 'auth/utils/role_checker.dart'; // Optional: for role-based redirection

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ensure firebase_options.dart is set up
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
      String role = 'CA'; // Hardcoded for demo (replace later)

      final route = getRedirectRoute(role);
      Future.microtask(() {
        Navigator.pushReplacementNamed(context, route);
      });

      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
  }
}

class PlaceholderScreen extends StatelessWidget {
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
