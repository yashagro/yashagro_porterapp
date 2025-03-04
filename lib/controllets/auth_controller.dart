import 'package:get/get.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/services/api_service.dart';
import 'package:partener_app/views/auth/otp_screen.dart';
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
  Future<void> sendOtp(String mobile) async {
    isLoading.value = true;

    bool success = await _apiService.sendOtp(mobile);
    isLoading.value = false;

    if (success) {
      print("✅ OTP Sent Successfully!");

      // ✅ Navigate only if not already on OTP screen
      if (!Get.isDialogOpen! && Get.currentRoute != AppRoutes.otp) {
        Get.to(() => OtpScreen(mobileNumber: mobile));
      }
    } else {
      showErrorSnackbar("Failed to send OTP. Try again.");
    }
  }

  Future<void> verifyOtp(String mobile, String otp) async {
    isLoading.value = true;
    print("🔹 Verifying OTP for Mobile: $mobile, OTP: $otp");

    final response = await _apiService.verifyOtp(
      mobile,
      otp,
    ); // ✅ Get full response
    isLoading.value = false;

    if (response != null && response['success'] == true) {
      print("✅ OTP Verified Successfully!");

      // ✅ Extract & Store Token & Role
      String token = response['data']['token'];
      await SharedPrefs.saveUserToken(token); // ✅ Store token

      // ✅ Fetch Profile & Store Role
      await fetchUserProfile();
    } else {
      print("❌ Invalid OTP. Try again.");
      showErrorSnackbar("Invalid OTP. Please check and try again.");
    }
  }

  /// **Fetch Profile & Navigate**
  Future<void> fetchUserProfile() async {
    isLoading.value = true;
    UserModel? user = await _apiService.fetchUserProfile();
    isLoading.value = false;

    if (user == null) {
      showErrorSnackbar("Failed to fetch profile.");
      return;
    }

    // ✅ Store User ID & Role in Local Storage
    await SharedPrefs.saveUserId(user.id); // ✅ Store user ID
    await SharedPrefs.saveUserRole(user.roleId); // ✅ Store user role

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
      case 4:
        Get.offAllNamed(AppRoutes.dealerHome);
        break;
      case 5:
        Get.offAllNamed(AppRoutes.buyerHome);
        break;
      default:
        showErrorSnackbar("Unauthorized access.");
    }
  }
}
