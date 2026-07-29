import 'package:dio/dio.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/services/shared_prefs.dart';

class SuperManagerApiService {
  final Dio _dio = Dio();
  final String _base = ApiRoutes.baseUri;

  Future<Options> _getAuthOptions() async {
    String? token = await SharedPrefs.getUserToken();
    if (token == null) throw Exception("Token not found");
    return Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
  }

  /// Get all users and filter for managers (role_id = 8)
  Future<List<dynamic>> getAllManagers() async {
    try {
      final response = await _dio.get(
        "$_base${ApiRoutes.adminUsersEndpoint}",
        options: await _getAuthOptions(),
      );
      print("✅ Get all users response: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> users = [];

        // Handle if response is list directly or inside 'data' key
        if (data is Map && data['data'] != null) {
          users = data['data'] as List<dynamic>;
        } else if (data is List) {
          users = data;
        }

        // Filter users to return only those with role_id == 8 (Managers)
        return users.where((user) {
          if (user is Map) {
            return user['role_id'] == 8 || user['role_id'] == '8';
          }
          return false;
        }).toList();
      }
      return [];
    } catch (e) {
      print("❌ Error getting all managers: $e");
      if (e is DioException) {
        print("⚠️ Response: ${e.response?.data}");
      }
      return [];
    }
  }

}
