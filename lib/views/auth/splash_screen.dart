import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../widgets/background_container.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppLogo(),
            SizedBox(height: 20),
            Text("Grow Smarter, Harvest Better", style: TextStyle(color: Colors.white, fontSize: 16)),
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: CustomButton(
                text: "Continue",
                onPressed: () => Get.toNamed(AppRoutes.login),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
