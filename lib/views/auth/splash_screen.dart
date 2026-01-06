import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/app_routes.dart';
import '../../widgets/background_container.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_button.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: BackgroundContainer(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 100),
              AppLogo(),
      
              Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: CustomButton(
                  text: "Continue",
                  onPressed: () => Get.toNamed(AppRoutes.login),
                ),
              ),
              SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
