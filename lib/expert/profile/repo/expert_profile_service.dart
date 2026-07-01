import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/services/shared_prefs.dart';
import '../model/profile_model.dart';

class ProfileService {
  final Dio _dio = Dio();
  final String baseUrl = "${ApiRoutes.baseUri}${ApiRoutes.authEndpoint}";

  /// Fetch profile from API
  Future<ProfileModel?> fetchProfile() async {
    String? token = await SharedPrefs.getUserToken();
    if (token == null) throw Exception("No token found");

    final response = await _dio.get(
      "$baseUrl/profile",
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      ),
    );

    debugPrint("✅ Profile API response: ${response.data}");

    if (response.statusCode == 200 && response.data['success'] == true) {
      return ProfileModel.fromJson(response.data['data']);
    } else {
      throw Exception("Error fetching profile: ${response.data}");
    }
  }

  /// Update profile
  Future<bool> updateProfile(ProfileModel data, {File? image}) async {
    String? token = await SharedPrefs.getUserToken();
    if (token == null) throw Exception("No token found");
    final int? userId = data.id ?? await SharedPrefs.getUserId();
    if (userId == null) throw Exception("No user id found");

    final payload = {
      "role_id": data.roleId,
      "state": data.state,
      "taluka": data.taluka,
      "district": data.district,
      "pincode": data.pincode,
      "mobile_no": data.mobileNo,
      "whatsapp_number": data.whatsappNumber,
      "name": data.name,
      "village": data.village,
      "isAccountSetup": data.isAccountSetup ?? false,
    };

    debugPrint("📤 Update profile request url: $baseUrl/setup-account");
    debugPrint("📤 Update profile request body: $payload");

    late final Response response;

    if (image != null) {
      final formData = FormData.fromMap({
        ...payload,
        "image": await MultipartFile.fromFile(
          image.path,
          filename: image.path.split("/").last,
        ),
      });

      response = await _dio.put(
        "$baseUrl/setup-account",
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );
    } else {
      response = await _dio.put(
        "$baseUrl/setup-account",
        data: payload,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      );
    }

    debugPrint("✅ Update profile API response: ${response.data}");

    return response.statusCode == 200 && response.data['success'] == true;
  }
}
