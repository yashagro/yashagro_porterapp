import 'package:dio/dio.dart';
import 'package:partener_app/data/local_storage/shared_prefs.dart';
import 'package:partener_app/models/user_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = "http://194.164.148.246/api/auth";

  /// **Send OTP Request**
  Future<bool> sendOtp(String mobile) async {
    try {
      Response response = await _dio.post("$baseUrl/send-otp", data: {
        "mobile_no": mobile,
      });

      return response.statusCode == 200;
    } catch (e) {
      print("Send OTP Error: $e");
      return false;
    }
  }

  /// **Verify OTP API Call**
  Future<bool> verifyOtp(String mobile, String otp) async {
    try {
      print("🔹 Sending OTP verification request with:");
      print("Mobile: $mobile, OTP: $otp");

      Response response = await _dio.post(
        "$baseUrl/verify-otp",
        data: {
          "mobile_no": mobile.trim(), // ✅ Ensure correct field name
          "otp": otp.trim(), // ✅ Trim spaces
        },
        options: Options(headers: {
          "Content-Type": "application/json" // ✅ Ensures correct request format
        }),
      );

      print("🔹 OTP API Response: ${response.data}");

      if (response.statusCode == 200 && response.data['success']) {
        String token = response.data['data']['token'];
        await SharedPrefs.saveToken(token);
        return true;
      } else {
        print("❌ OTP Verification Failed: ${response.data['message']}");
        return false;
      }
    } catch (e) {
      print("❌ OTP Verification Error: $e");
      return false;
    }
  }

  /// **Fetch User Profile**
  Future<UserModel?> fetchUserProfile() async {
    try {
      String? token = await SharedPrefs.getToken();
      if (token == null) return null;

      Response response = await _dio.get(
        "$baseUrl/profile",
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data['success']) {
        return UserModel.fromJson(response.data['data']);
      }
      return null;
    } catch (e) {
      print("Fetch Profile Error: $e");
      return null;
    }
  }
}
