import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/views/auth/splash_screen.dart';
import 'package:partener_app/views/buyers/buyers_home_screen.dart';
import 'package:partener_app/views/dealers/dealers_home_screen.dart';
import 'package:partener_app/views/experts/experts_home_screen.dart';
import 'routes/app_routes.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/otp_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Partner App',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: AppRoutes.splash,
      getPages: [
        GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
        GetPage(name: AppRoutes.login, page: () => LoginScreen()),
        GetPage(
          name: AppRoutes.otp,
          page: () {
            final String mobile = Get.parameters['mobileNumber'] ?? '';
            return OtpScreen(
              mobileNumber: mobile,
            ); // ✅ Pass mobile number safely
          },
        ),
        GetPage(name: AppRoutes.expertHome, page: () => ExpertsHomeScreen()),
        GetPage(name: AppRoutes.dealerHome, page: () => DealersHomeScreen()),
        GetPage(name: AppRoutes.buyerHome, page: () => BuyersHomeScreen()),
      ],
    );
  }
}
