import 'package:flutter/material.dart';
import 'base/bottom_navbar.dart';

void main() {    //untuk display UI tu
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavbar(),//sini
    );
  }
}


