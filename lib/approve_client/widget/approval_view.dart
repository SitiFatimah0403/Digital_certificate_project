import 'package:flutter/material.dart';
import '../screen/approve_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CertificatePage(
        recipientName: "Danial Asyraaf",
        courseName: "Mobile Program 2025",
        date: "16 June 2025",
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
