import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String? password; // Make optional
  final String role;

  AppUser({
    required this.uid,
    required this.email,
    this.password, // Optional for Google Sign-In
    required this.role,
  });

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'],
      email: data['email'],
      password: data['password'], // May be null
      role: data['role'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      if (password != null) 'password': password, // Only save if not null
      'role': role,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}
