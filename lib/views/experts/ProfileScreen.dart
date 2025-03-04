import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/utils/app_routes.dart';

class ProfileScreen extends StatelessWidget {
  void logout() async {
    await SharedPrefs.clearUserData();
    Get.offAllNamed(AppRoutes.login); // ✅ Correct route from `app_routes.dart`
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Center(child: Text("Profile Page")),
          ElevatedButton(onPressed: logout, child: Text("Logout")),
        ],
      ),
    );
  }
}
