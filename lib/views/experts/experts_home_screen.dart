import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/views/experts/ChatListScreen.dart';
import 'package:partener_app/views/experts/ProfileScreen.dart';
import '../../utils/app_routes.dart';

class ExpertsHomeScreen extends StatefulWidget {
  const ExpertsHomeScreen({super.key});

  @override
  _ExpertsHomeScreenState createState() => _ExpertsHomeScreenState();
}

class _ExpertsHomeScreenState extends State<ExpertsHomeScreen> {
  int _currentIndex = 0; // ✅ Keeps track of the selected tab

  final List<Widget> _screens = [
    ChatListScreen(), // ✅ Chat List Page
    ProfileScreen(), // ✅ Profile Page
  ];

  void logout() async {
    await SharedPrefs.clearUserData();
    Get.offAllNamed(AppRoutes.login); // ✅ Navigate to Login Screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // ✅ Show selected tab content
      /// **Bottom Navigation Bar**
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chats"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
