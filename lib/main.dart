import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/controllets/chats_controller.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/controllets/web_socket_controller.dart';
import 'package:partener_app/views/auth/splash_screen.dart';
import 'package:partener_app/views/buyers/buyers_home_screen.dart';
import 'package:partener_app/views/dealers/dealers_home_screen.dart';
import 'package:partener_app/views/experts/experts_home_screen.dart';
import 'utils/app_routes.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/otp_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String initialRoute = await getInitialRoute();
  Get.put(WebSocketController());
  Get.put(ChatsController());

  // ✅ Initialize OneSignal
  await _initializeOneSignal();

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final WebSocketController socketController = Get.put(WebSocketController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Partner App',
      theme: ThemeData(primarySwatch: Colors.green),
      initialRoute: initialRoute,
      getPages: [
        GetPage(name: AppRoutes.splash, page: () => SplashScreen()),
        GetPage(name: AppRoutes.login, page: () => LoginScreen()),
        GetPage(
          name: AppRoutes.otp,
          page: () {
            final String mobile = Get.parameters['mobileNumber'] ?? '';
            return OtpScreen(mobileNumber: mobile);
          },
        ),
        GetPage(name: AppRoutes.expertHome, page: () => ExpertsHomeScreen()),
        GetPage(name: AppRoutes.dealerHome, page: () => DealersHomeScreen()),
        GetPage(name: AppRoutes.buyerHome, page: () => BuyersHomeScreen()),
      ],
    );
  }
}

/// **Determine Initial Route Based on Token & User Role**
Future<String> getInitialRoute() async {
  String? token = await SharedPrefs.getUserToken();
  int? role = await SharedPrefs.getUserRole();
  int? userId = await SharedPrefs.getUserId();

  if (token == null || token.isEmpty || role == null) {
    print("❌ No token or role found. Redirecting to SplashScreen.");
    return AppRoutes.splash;
  }

  print("🔹 Token: $token");
  print("🔹 Role: $role");
  print("🔹 User Id: $userId");

  switch (role) {
    case 3:
      return AppRoutes.expertHome;
    case 4:
      return AppRoutes.dealerHome;
    case 5:
      return AppRoutes.buyerHome;
    default:
      return AppRoutes.splash;
  }
}

Future<void> _initializeOneSignal() async {
  try {
    // Set Log Level for Debugging
    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);

    // Initialize OneSignal with App ID
    OneSignal.initialize("d6dc0dc0-947b-4226-99df-6c265799cb12");

    // Request permission for notifications
    await OneSignal.Notifications.requestPermission(true);

    // Wait a moment to allow OneSignal to process
    await Future.delayed(Duration(seconds: 3));

    // Fetch OneSignal Subscription Info
    String? playerId = OneSignal.User.pushSubscription.id;
    bool? isOptedIn = OneSignal.User.pushSubscription.optedIn;

    if (playerId != null && isOptedIn == true) {
      print("✅ OneSignal Player ID: $playerId");

      // Store Player ID in Shared Preferences
      await SharedPrefs.saveOneSignalPlayerID(playerId);
      print("💾 OneSignal Player ID saved locally.");
    } else {
      print("❌ OneSignal Player ID not found. User may not be subscribed.");
    }
  } catch (e) {
    print("❌ OneSignal Initialization Error: $e");
  }
}
