/*
This class is for:
1) save user data in firestore cloud
2) Maneage RBAC (role based access control)
*/

import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid; //for firebase unique ID
  final String email;
  final String password;
  final String role; //role as : ca, admin , recipient , client , viewer

  AppUser({
    required this.uid,
    required this.email,
    required this.password,
    required this.role,
  });


  factory AppUser.fromMap(Map<String, dynamic> data) { //read from Firestore
    return AppUser(
      uid: data['uid'],
      email: data['email'],
      password: data['password'],
      role: data['role'],
    );
  }

  Map<String, dynamic> toMap() { //Save to firestore
    return {
      'uid': uid,
      'email': email,
      'password': password,
      'role': role,
      'created_at': FieldValue.serverTimestamp(),
    };
  }
}
