import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/expert/chats/controller/chats_controller.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/expert/chats/controller/web_socket_controller.dart';
import 'package:partener_app/views/auth/splash_screen.dart';
import 'package:partener_app/views/buyers/buyers_home_screen.dart';
import 'package:partener_app/views/dealers/dealers_home_screen.dart';
import 'package:partener_app/expert/chats/view/chat_screen.dart';
import 'package:partener_app/expert/experts_home_screen.dart';
import 'utils/app_routes.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/otp_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String initialRoute = await getInitialRoute();

  // ✅ Initialize OneSignal
  await _initializeOneSignal();

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    Get.put(WebSocketController());

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
      initialBinding: BindingsBuilder(() {
        Get.put(ChatsController());
      }),
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

    String? playerId = OneSignal.User.pushSubscription.id;
    String? notificationId = await SharedPrefs.getOneSignalPlayerID();

    OneSignal.Notifications.addClickListener((data) {
      var notificationData = data.notification.additionalData;

      log(data.notification.additionalData.toString());
      log(notificationData!['type'].runtimeType.toString());
      if (notificationData['type'] == 1) {
        Get.to(() => ChatScreen(roomId: int.parse(notificationData['id'])));
      }
    });

    if (playerId != null) {
      print("✅ OneSignal Player ID: $playerId");
      // Store Player ID in Shared Preferences
      await SharedPrefs.saveOneSignalPlayerID(playerId);
      print("💾 OneSignal Player ID saved locally.");
    } else if (notificationId != null) {
      print("OneSignal Player ID form Local storage: $notificationId");
    } else {
      print("❌ OneSignal Player ID not found. User may not be subscribed.");
    }
  } catch (e) {
    print("❌ OneSignal Initialization Error: $e");
  }
}
