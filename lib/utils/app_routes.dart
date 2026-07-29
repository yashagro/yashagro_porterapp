import 'package:get/get.dart';
import 'package:partener_app/views/auth/splash_screen.dart';
import 'package:partener_app/views/buyers/buyers_home_screen.dart';
import 'package:partener_app/views/dealers/dealers_home_screen.dart';
import 'package:partener_app/expert/experts_home_screen.dart';
import 'package:partener_app/marketer/marketer_home_screen.dart';
import 'package:partener_app/managers/managers_home_screen.dart';
import 'package:partener_app/super_manager/view/super_manager_dashboard_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/otp_screen.dart';

class AppRoutes {
  static const String splash = "/";
  static const String login = "/login";
  static const String otp = "/otp";
  static const String expertHome = "/expert-home";
  static const String dealerHome = "/dealer-home";
  static const String buyerHome = "/buyer-home";
  static const String marketerHome = "/marketer-home";
  static const String managerHome = "/manager-home";
  static const String superManagerHome = "/super-manager-home";

  /// **Define all routes here (Avoid duplication)**
  static final routes = [
    GetPage(name: splash, page: () => SplashScreen()),
    GetPage(name: login, page: () => LoginScreen()),
    GetPage(
      name: otp,
      page: () => OtpScreen(mobileNumber: Get.parameters['mobileNumber'] ?? ''),
    ),
    GetPage(name: expertHome, page: () => ExpertsHomeScreen()),
    GetPage(name: dealerHome, page: () => DealersHomeScreen()),
    GetPage(name: buyerHome, page: () => BuyersHomeScreen()),
    GetPage(name: marketerHome, page: () => const MarketerHomeScreen()),
    GetPage(name: managerHome, page: () => const ManagersHomeScreen()),
    GetPage(name: superManagerHome, page: () => const SuperManagerDashboardScreen()),
  ];
}
