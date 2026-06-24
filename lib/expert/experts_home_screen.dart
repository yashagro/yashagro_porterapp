import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/expert/chats/controller/web_socket_controller.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/expert/chats/view/chat_list_screen.dart';
import 'package:partener_app/expert/profile/view/profile_screen.dart';
import 'package:partener_app/expert/visits/view/visit_requests_screen.dart';
import '../utils/app_routes.dart';

class ExpertsHomeScreen extends StatefulWidget {
  const ExpertsHomeScreen({super.key});

  @override
  _ExpertsHomeScreenState createState() => _ExpertsHomeScreenState();
}

class _ExpertsHomeScreenState extends State<ExpertsHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    ChatListScreen(),
    VisitRequestsScreen(),
    ProfileScreen(),
  ];

  void logout() async {
    await SharedPrefs.clearUserData();
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void initState() {
    super.initState();

    Get.put(WebSocketController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: Colors.green.shade700,
            unselectedItemColor: Colors.green.shade400,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            elevation: 10,
            items: [
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble_outline),
                activeIcon: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat, color: Colors.green.shade700),
                      SizedBox(width: 6),
                      Text(
                        "Chat",
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
                label: "",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.event_note_outlined),
                activeIcon: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_note, color: Colors.green.shade700),
                      SizedBox(width: 6),
                      Text(
                        "Requests",
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
                label: "",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.person, color: Colors.green.shade700),
                      SizedBox(width: 6),
                      Text(
                        "Profile",
                        style: TextStyle(color: Colors.green.shade700),
                      ),
                    ],
                  ),
                ),
                label: "",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
