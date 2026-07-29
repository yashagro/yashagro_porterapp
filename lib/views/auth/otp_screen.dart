import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/controllets/auth_controller.dart';
import '../../widgets/background_container.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/app_logo.dart';
import '../../utils/constants.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;

  const OtpScreen({super.key, required this.mobileNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController otpController = TextEditingController();
  static const int _resendCooldown = 30;
  Timer? _resendTimer;
  int _secondsRemaining = _resendCooldown;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    setState(() {
      _secondsRemaining = _resendCooldown;
    });

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _secondsRemaining = 0;
          });
        }
        return;
      }

      if (mounted) {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  Future<void> _handleResendOtp() async {
    if (_secondsRemaining > 0) return;

    final bool isSent = await authController.sendOtp(widget.mobileNumber);
    if (isSent && mounted) {
      _startResendTimer();
    }
  }

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
                      "+91 ${widget.mobileNumber}", // ✅ Show Mobile Number
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
                    Obx(() => CustomButton(
                      text: "Verify OTP",
                      isLoading: authController.isLoading.value,
                      onPressed: () {
                        String otp = otpController.text.trim();
                        authController.verifyOtp(widget.mobileNumber, otp);
                      },
                    )),
                    SizedBox(height: 15),

                    /// **Resend OTP Option**
                    GestureDetector(
                      onTap: _secondsRemaining == 0 ? _handleResendOtp : null,
                      child: Text(
                        _secondsRemaining == 0
                            ? "Didn’t get OTP? Resend"
                            : "Didn’t get OTP? Resend in $_secondsRemaining s",
                        style: AppTextStyles.highlightedText.copyWith(
                          decoration: TextDecoration.underline,
                          color:
                              _secondsRemaining == 0
                                  ? AppTextStyles.highlightedText.color
                                  : Colors.grey,
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
