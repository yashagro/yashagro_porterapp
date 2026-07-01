import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/expert/chats/controller/web_socket_controller.dart';
import 'package:partener_app/expert/employee_tracking/controller/employee_tracking_controller.dart';
import 'package:partener_app/expert/profile/view/profile_screen.dart';
import 'package:partener_app/marketer/view/marketer_dashboard_screen.dart';
import 'package:partener_app/marketer/view/marketer_map_screen.dart';

class MarketerHomeScreen extends StatefulWidget {
  const MarketerHomeScreen({super.key});

  @override
  State<MarketerHomeScreen> createState() => _MarketerHomeScreenState();
}

class _MarketerHomeScreenState extends State<MarketerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MarketerDashboardScreen(),
    const MarketerMapScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Get.put(WebSocketController());
    Get.put(EmployeeTrackingController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
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
          borderRadius: const BorderRadius.only(
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
              _navItem(
                icon: Icons.work_outline,
                activeIcon: Icons.work,
                label: "Work",
              ),
              _navItem(
                icon: Icons.map_outlined,
                activeIcon: Icons.map,
                label: "Map",
              ),
              _navItem(
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      activeIcon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(activeIcon, color: Colors.green.shade700),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: Colors.green.shade700)),
          ],
        ),
      ),
      label: "",
    );
  }
}
