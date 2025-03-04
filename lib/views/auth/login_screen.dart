import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/controllets/auth_controller.dart';
import '../../widgets/background_container.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/app_logo.dart';
import '../../utils/constants.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController mobileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Stack(
          children: [
            /// **App Logo (Centered)**
            Positioned(
              left: 0,
              right: 0,
              top: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [AppLogo(width: 150, height: 150)],
              ),
            ),

            /// **Bottom Positioned Form with Transparency**
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(
                    0.65,
                  ), // ✅ Light Transparent Background
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Hi Welcome!", style: AppTextStyles.heading),
                    Text("Create an account", style: AppTextStyles.bodyText),
                    SizedBox(height: 20),

                    /// **Mobile Number Input**
                    CustomTextField(
                      controller: mobileController,
                      label: "Enter your mobile number",
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 15),

                    /// **Send OTP Button**
                    CustomButton(
                      text: "SEND OTP",
                      onPressed: () {
                        String mobile = mobileController.text.trim();
                        authController.sendOtp(mobile);
                      },
                    ),
                    SizedBox(height: 10),

                    /// **Highlighted OTP Info**
                    Text(
                      "We will send you a 6-digit OTP.",
                      style:
                          AppTextStyles.highlightedText, // ✅ Highlighted Text
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
