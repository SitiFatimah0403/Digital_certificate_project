import 'package:flutter/material.dart';
import '../widget/cert_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xB5ABAABB),
        title: const Text("RECIPIENT"),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 40, bottom: 20),
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Your Cert",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                //Text(
                //"View all",
                //style: TextStyle(
                //fontSize: 14,
                //fontWeight: FontWeight.w500,
                //color: Colors.blue,
                //),
                //),
              ],
            ),
          ),
          SizedBox(height: 15),
          CertView(), // CertView
        ],
      ),
    );
  }
}
