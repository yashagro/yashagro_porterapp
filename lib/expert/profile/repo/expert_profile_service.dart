import 'dart:io';
import 'package:dio/dio.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/services/shared_prefs.dart';
import '../model/profile_model.dart';

class ProfileService {
  final Dio _dio = Dio();
  final String baseUrl = "$baseUri/api/auth";

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

    FormData formData = FormData.fromMap({
      "role_id": data.roleId,
      "state": data.state,
      "taluka": data.taluka,
      "district": data.district,
      "pincode": data.pincode,
      "whatsapp_number": data.whatsappNumber,
      "name": data.name,
      "village": data.village,
      "isAccountSetup": data.isAccountSetup ?? false,
      if (image != null)
        "image": await MultipartFile.fromFile(
          image.path,
          filename: image.path.split("/").last,
        ),
    });

    final response = await _dio.put(
      "$baseUrl/setup-account",
      data: formData,
      options: Options(
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "multipart/form-data",
        },
      ),
    );

    return response.statusCode == 200 && response.data['success'] == true;
  }
}
