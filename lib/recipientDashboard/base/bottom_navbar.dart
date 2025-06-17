import 'package:digital_certificate_project/recipient_verify_cert/CA_verification.dart';
import 'package:flutter/material.dart';
import '../screen/home_screen.dart';

class BottomNavbar extends StatefulWidget {
  const BottomNavbar({super.key});

  @override
  State<BottomNavbar> createState() => _BottomNavbarState();
}

class _BottomNavbarState extends State<BottomNavbar> {
  final appScreens = [
    HomeScreen(),
    CA_Verification(),
  ];

  int _selectedIndex = 0;

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(
       // backgroundColor: Color(0xB5ABAABB),
       // title: Text("RECIPIENT"),
       // centerTitle: true,
      //),
      body: appScreens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.blueGrey,
        unselectedItemColor: const Color(0xFF526400),
        showSelectedLabels: false,
        showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: "Home"),

            BottomNavigationBarItem(icon: Icon(Icons.upload_outlined),
                activeIcon: Icon(Icons.upload_rounded),
                label: "Uploads"),
          ],
      ),
    );
  }
}
