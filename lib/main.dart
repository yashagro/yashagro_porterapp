import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/expert/chats/controller/chats_controller.dart';
import 'package:partener_app/services/background_location_service.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:partener_app/expert/chats/controller/web_socket_controller.dart';
import 'package:partener_app/views/auth/splash_screen.dart';
import 'package:partener_app/views/buyers/buyers_home_screen.dart';
import 'package:partener_app/views/dealers/dealers_home_screen.dart';
import 'package:partener_app/expert/chats/view/chat_screen.dart';
import 'package:partener_app/expert/experts_home_screen.dart';
import 'package:partener_app/marketer/marketer_home_screen.dart';
import 'package:partener_app/managers/managers_home_screen.dart';
import 'package:partener_app/super_manager/view/super_manager_dashboard_screen.dart';
import 'utils/app_routes.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/otp_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String initialRoute = await getInitialRoute();

  // ✅ Initialize OneSignal
  await _initializeOneSignal();

  // ✅ Initialize background service for location tracking
  await initializeBackgroundService();

  // ✅ Auto-restart background tracking if employee was working before app close
  await _restoreBackgroundTrackingIfNeeded();

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
        GetPage(
          name: AppRoutes.marketerHome,
          page: () => const MarketerHomeScreen(),
        ),
        GetPage(
          name: AppRoutes.managerHome,
          page: () => const ManagersHomeScreen(),
        ),
        GetPage(
          name: AppRoutes.superManagerHome,
          page: () => const SuperManagerDashboardScreen(),
        ),
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
    // case 4:
    //   return AppRoutes.dealerHome;
    // case 5:
    //   return AppRoutes.buyerHome;

    case 7:
      return AppRoutes.marketerHome;
    case 8:
    case 9:
      return AppRoutes.managerHome;
    default:
      return AppRoutes.splash;
  }
}

/// If the employee was in "working" state when the app last closed,
/// automatically restart the background location service on next launch.
Future<void> _restoreBackgroundTrackingIfNeeded() async {
  try {
    // Only restart if there's a valid auth token (i.e., logged in)
    final token = await SharedPrefs.getUserToken();
    if (token == null || token.isEmpty) return;

    final isAlreadyRunning = await isBackgroundTrackingRunning();
    if (isAlreadyRunning) return;

    // Check SharedPrefs flag set by background_location_service.dart
    final prefs = await SharedPreferences.getInstance();
    final wasWorking = prefs.getBool('bg_is_working') ?? false;
    if (wasWorking) {
      print('🔄 Restoring background location tracking after app restart...');
      await startBackgroundTracking(token);
    }
  } catch (e) {
    print('❌ Error restoring background tracking: $e');
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
