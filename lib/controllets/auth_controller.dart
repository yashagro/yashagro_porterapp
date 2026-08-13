import 'dart:developer';
import 'package:get/get.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/services/api_service.dart';
import 'package:partener_app/views/auth/otp_screen.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:partener_app/expert/chats/controller/web_socket_controller.dart';
import '../models/user_model.dart';
import '../utils/helpers.dart';
import '../utils/app_routes.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  var isLoading = false.obs;

  /// **Check if User is Logged In**
  Future<bool> isUserLoggedIn() async {
    String? token = await SharedPrefs.getUserToken();
    return token != null;
  }

  /// **Send OTP**
  Future<bool> sendOtp(String mobile) async {
    isLoading.value = true;

    bool success = await _apiService.sendOtp(mobile);
    isLoading.value = false;

    if (success) {
      // ✅ Navigate only if not already on OTP screen
      if (!Get.isDialogOpen! && Get.currentRoute != AppRoutes.otp) {
        Get.to(() => OtpScreen(mobileNumber: mobile));
      }
      return true;
    } else {
      showErrorSnackbar("Failed to send OTP. Try again.");
      return false;
    }
  }

  Future<void> verifyOtp(String mobile, String otp) async {
    isLoading.value = true;

    final response = await _apiService.verifyOtp(
      mobile,
      otp,
    ); // ✅ Get full response

    if (response != null && response['success'] == true) {
      // ✅ Extract & Store Token & Role
      String token = response['data']['token'];
      await SharedPrefs.saveUserToken(token); // ✅ Store token

      // ✅ Fetch Profile & Store Role (keep loading active)
      await fetchUserProfile(keepLoading: true);
    } else {
      isLoading.value = false;
      showErrorSnackbar("Invalid OTP. Please check and try again.");
    }
  }

  /// **Fetch Profile & Navigate**
  Future<void> fetchUserProfile({bool keepLoading = false}) async {
    if (!keepLoading) {
      isLoading.value = true;
    }
    UserModel? user = await _apiService.fetchUserProfile();
    isLoading.value = false;

    if (user == null) {
      showErrorSnackbar("Failed to fetch profile.");
      return;
    }

    // ✅ Store User ID & Role in Local Storage
    await SharedPrefs.saveUserId(user.id ?? 0); // ✅ Store user ID
    await SharedPrefs.saveUserRole(user.roleId ?? 0); // ✅ Store user role

    // ✅ Navigate Based on Role
    switch (user.roleId) {
      case 1:
        showErrorSnackbar("You are a farmer. Please use the Farmer App.");
        break;
      case 2:
        showErrorSnackbar("You are an Admin. Open the Admin Dashboard.");
        break;
      case 3:
        Get.offAllNamed(AppRoutes.expertHome);
        break;
      // case 4:
      //   Get.offAllNamed(AppRoutes.dealerHome);
      //   break;
      // case 5:
      //   Get.offAllNamed(AppRoutes.buyerHome);
      //   break;
      case 7:
        Get.offAllNamed(AppRoutes.marketerHome);
        break;
      case 8:
      case 9:
        Get.offAllNamed(AppRoutes.managerHome);
        break;
      default:
        showErrorSnackbar("Unauthorized access.");
    }
  }

  /// **Logout and Cleanup Resources**
  Future<void> logout() async {
    // 1. Stop background location service if active
    try {
      final service = FlutterBackgroundService();
      if (await service.isRunning()) {
        service.invoke('stopTracking');
      }
    } catch (e) {
      log('Error stopping background service: $e', name: 'auth');
    }

    // 2. Disconnect and remove WebSocket controller
    try {
      if (Get.isRegistered<WebSocketController>()) {
        final ws = Get.find<WebSocketController>();
        ws.onClose();
        Get.delete<WebSocketController>(force: true);
      }
    } catch (e) {
      log('Error cleaning up WebSocketController: $e', name: 'auth');
    }

    // 3. Clear user preferences data
    await SharedPrefs.clearUserData();

    // 4. Redirect to login
    Get.offAllNamed(AppRoutes.login);
  }
}
