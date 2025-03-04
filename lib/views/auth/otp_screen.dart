import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/controllets/auth_controller.dart';
import '../../widgets/background_container.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/app_logo.dart';
import '../../utils/constants.dart';

class OtpScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController otpController = TextEditingController();
  final String mobileNumber;

  OtpScreen({required this.mobileNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundContainer(
        child: Stack(
          children: [
            /// **App Logo Positioned at Top**
            Positioned(
              left: 0,
              right: 0,
              top: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [AppLogo(width: 150, height: 150)],
              ),
            ),

            /// **Bottom Positioned OTP Form**
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(
                    0.85,
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
                    Text("OTP Verification", style: AppTextStyles.heading),
                    Text(
                      "A 6-digit code has been sent to",
                      style: AppTextStyles.bodyText,
                    ),
                    Text(
                      "+91 $mobileNumber", // ✅ Show Mobile Number
                      style:
                          AppTextStyles.highlightedText, // ✅ Highlighted Text
                    ),
                    SizedBox(height: 20),

                    /// **OTP Input**
                    CustomTextField(
                      controller: otpController,
                      label: "Enter OTP",
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 15),

                    /// **Verify OTP Button**
                    CustomButton(
                      text: "Verify OTP",
                      onPressed: () {
                        String otp = otpController.text.trim();
                        authController.verifyOtp(mobileNumber, otp);
                      },
                    ),
                    SizedBox(height: 15),

                    /// **Resend OTP Option**
                    GestureDetector(
                      onTap: () {
                        authController.sendOtp(mobileNumber);
                      },
                      child: Text(
                        "Didn’t get OTP? Resend",
                        style: AppTextStyles.highlightedText.copyWith(
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),

                    /// **Security Note**
                    Text(
                      "Never share your OTP",
                      style: AppTextStyles.smallText,
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
