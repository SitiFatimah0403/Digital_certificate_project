import 'package:digital_certificate_project/auth/screens/login_screen';
import 'package:digital_certificate_project/recipientDashboard/screen/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'auth/screens/signin_screen.dart';
import 'core/constants.dart';
import 'auth/services/auth_service.dart';
import 'auth/utils/role_checker.dart'; // Optional: for role-based redirection
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print("Firebase initialized"); //check if it is successful
  } catch (e, stackTrace) {
    print("Error during Firebase init: $e");
    print(stackTrace);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Certificate Repository',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.grey),
      home: AuthWrapper(), // controls where to go after startup
      routes: {
        '/login': (context) => LoginScreen(),
        '/Signup': (context) => SignUpScreen(),
        '/adminDashboard': (context) => PlaceholderScreen('Admin Dashboard'),
        '/caDashboard': (context) => PlaceholderScreen('CA Dashboard'),
        '/recipientDashboard': (context) => HomeScreen(),
        '/clientDashboard': (context) => PlaceholderScreen('Client'),
        '/viewerDashboard': (context) => PlaceholderScreen('Viewer'),
        '/unauthorized': (context) => PlaceholderScreen('Unauthorized'),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthService _authService =
      AuthService(); //to get current logged in user

  Future<String?> getUserRole(User user) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.email); //access data from firestore db (from user email)
    final doc = await docRef.get(); //retrieve from firestore

    if (doc.exists && doc.data() != null && doc.data()!.containsKey('role')) {
      return doc['role'];
    } else {
      // Optional: create the document if not found
      await docRef.set({
        'email': user.email,
        'role': 'recipient', // default role
        'createdAt':
            FieldValue.serverTimestamp(), //Auto generate server timestamp
      });
      return 'recipient';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return LoginScreen();
    }

    return FutureBuilder<String?>(
      future: getUserRole(user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: Center(child: Text("Error retrieving user role.")),
          );
        } else {
          final role = snapshot.data!;
          final route = getRedirectRoute(role);

          // Use Future.microtask to navigate after the build
          Future.microtask(() {
            Navigator.pushReplacementNamed(context, route);
          });

          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
      },
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  //This is a temporary screen to stand in for your future dashboards (like Admin, CA, etc.).
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
