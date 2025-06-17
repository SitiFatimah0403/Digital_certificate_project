import 'package:digital_certificate_project/auth/screens/login_screen';
import 'package:digital_certificate_project/recipientDashboard/base/bottom_navbar.dart';
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
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthService _authService =

      AuthService(); //to get current logged in user

      AuthService();

  AuthWrapper({super.key}); //to get current logged in user

  Future<String?> getUserRole(User user) async {
    final docRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.email); //access data from firestore db (from user email)
    final doc = await docRef.get(); //retrieve from firestore

    if (doc.exists && doc.data() != null && doc.data()!.containsKey('role')) {
      return doc['role'];
    } else {
      print('🚫 Document does NOT exist. Creating new user with role "recipient".');
    }

    // Create default user document if not found or missing role
    await docRef.set({
      'email': email,
      'role': 'recipient',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return 'recipient';
  } catch (e, stackTrace) {
    print('🔥 Exception in getUserRole: $e');
    print('📄 Stack trace: $stackTrace');
    return null;
  }
}

//to sign out
Future<void> signOut() async {
  await FirebaseAuth.instance.signOut();
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
      print('🔥 Error getting user role: ${snapshot.error}');
      print('📄 Stack trace: ${snapshot.stackTrace}');
      return Scaffold(
        body: Center(child: Text("Error retrieving user role.")),
      );
    } else {
      final role = snapshot.data!;
      final route = getRedirectRoute(role);

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
