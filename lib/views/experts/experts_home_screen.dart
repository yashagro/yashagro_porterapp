import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/data/local_storage/shared_prefs.dart';
import '../../routes/app_routes.dart';

class ExpertsHomeScreen extends StatelessWidget {
  const ExpertsHomeScreen({super.key});

  void logout() async {
    await SharedPrefs.clearData();
    Get.offAllNamed(AppRoutes.login); // ✅ Correct route from `app_routes.dart`
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Experts Home"),
        actions: [IconButton(icon: Icon(Icons.logout), onPressed: logout)],
      ),
      body: Center(child: Text("Welcome to Experts Home")),
    );
  }
}
