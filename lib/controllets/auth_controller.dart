import 'package:get/get.dart';
import 'package:partener_app/data/local_storage/shared_prefs.dart';
import 'package:partener_app/data/services/api_service.dart';
import 'package:partener_app/views/auth/otp_screen.dart';
import '../models/user_model.dart';
import '../utils/helpers.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  var isLoading = false.obs;

  /// **Check if User is Logged In**
  Future<bool> isUserLoggedIn() async {
    String? token = await SharedPrefs.getToken();
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

    bool otpVerified = await _apiService.verifyOtp(mobile, otp);
    isLoading.value = false;

    if (otpVerified) {
      print("✅ OTP Verified Successfully!");
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

    if (user.roleId == 1) {
      showErrorSnackbar("You are a farmer. Please use the Farmer App.");
    } else if (user.roleId == 2) {
      showErrorSnackbar("You are an Admin. Open the Admin Dashboard.");
    } else if (user.roleId == 3) {
      Get.offAllNamed(AppRoutes.expertHome);
    } else if (user.roleId == 4) {
      Get.offAllNamed(AppRoutes.dealerHome);
    } else if (user.roleId == 5) {
      Get.offAllNamed(AppRoutes.buyerHome);
    } else {
      showErrorSnackbar("Unauthorized access.");
    }
  }
}
