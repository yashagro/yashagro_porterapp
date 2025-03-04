import 'package:dio/dio.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/models/chats_model.dart';
import 'package:partener_app/models/user_model.dart';

class ApiService {
  final Dio _dio = Dio();
  final String baseUrl = "http://194.164.148.246/api";

  /// **Send OTP Request**
  Future<bool> sendOtp(String mobile) async {
    try {
      Response response = await _dio.post(
        "$baseUrl/auth/send-otp",
        data: {"mobile_no": mobile},
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Send OTP Error: $e");
      return false;
    }
  }

  /// **Verify OTP API Call**
  Future<Map<String, dynamic>?> verifyOtp(String mobile, String otp) async {
    try {
      final response = await _dio.post(
        "$baseUrl/auth/verify-otp",
        data: {"mobile_no": mobile, "otp": otp},
      );

      if (response.statusCode == 200) {
        print("✅ OTP API Response: ${response.data}");
        return response.data; // ✅ Return full response
      } else {
        print("❌ OTP Verification Failed: ${response.data}");
        return null;
      }
    } catch (e) {
      print("❌ API Error: $e");
      return null;
    }
  }

  /// **Fetch User Profile**
  Future<UserModel?> fetchUserProfile() async {
    try {
      String? token = await SharedPrefs.getUserToken();
      if (token == null) return null;

      Response response = await _dio.get(
        "$baseUrl/auth/profile",
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

  /// **Fetch Expert Chat Rooms**
  Future<List<dynamic>?> fetchChatRooms() async {
    try {
      String? token = await SharedPrefs.getUserToken(); // ✅ Get Token
      if (token == null) return null;

      // ✅ Corrected API for Experts
      Response response = await _dio.get(
        "$baseUrl/chats/rooms", // ✅ Ensure the correct API endpoint
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        return response.data["data"];
      }
    } catch (e) {
      print("❌ Error fetching chat rooms: $e");
    }
    return null;
  }

  /// **Fetch Chat History**
  Future<List<ChatsModel>?> fetchChatHistory(int roomId) async {
    try {
      String? token = await SharedPrefs.getUserToken(); // ✅ Get Token
      if (token == null) return null;

      Response response = await _dio.get(
        "$baseUrl/chats/history/$roomId", // ✅ Fetch Chat History
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        return (response.data["data"] as List)
            .map((json) => ChatsModel.fromJson(json))
            .toList();
      }
    } catch (e) {
      print("❌ Error fetching chat history: $e");
    }
    return null;
  }

  /// **Start Chat**
  Future<int?> startChat(int plotId) async {
    try {
      String? token = await SharedPrefs.getUserToken();
      if (token == null) return null;

      Response response = await _dio.post(
        "$baseUrl/chats/start",
        data: {"plot_id": plotId}, // ✅ Pass the plot ID
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        return response.data["data"]["id"]; // ✅ Return Room ID
      } else {
        print("⚠️ Chat start failed: ${response.data}");
        return null;
      }
    } catch (e) {
      print("❌ Error starting chat: $e");
      return null;
    }
  }

  /// **Send a Message**
  Future<ChatsModel?> sendMessage(int roomId, String message) async {
    try {
      String? token = await SharedPrefs.getUserToken();
      if (token == null) return null;

      Response response = await _dio.post(
        "$baseUrl/chats/send",
        data: {"room_id": roomId, "message": message},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (response.statusCode == 200 && response.data["success"] == true) {
        return ChatsModel.fromJson(
          response.data["data"],
        ); // ✅ Return Sent Message
      } else {
        print("⚠️ Failed to send message: ${response.data}");
        return null;
      }
    } catch (e) {
      print("❌ Error sending message: $e");
      return null;
    }
  }
}
