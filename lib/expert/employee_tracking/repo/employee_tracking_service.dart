import 'package:dio/dio.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/services/shared_prefs.dart';

class EmployeeTrackingService {
  final Dio _dio = Dio();
  final String _base = ApiRoutes.baseUri;

  Future<bool> startWork(String location) async {
    try {
      String? token = await SharedPrefs.getUserToken();
      if (token == null) throw Exception("Token not found");

      final response = await _dio.post(
        "$_base${ApiRoutes.startWorkEndpoint}",
        data: {"location": location},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error starting work: $e");
      return false;
    }
  }

  Future<bool> endWork(String location) async {
    try {
      String? token = await SharedPrefs.getUserToken();
      if (token == null) throw Exception("Token not found");

      final response = await _dio.post(
        "$_base${ApiRoutes.endWorkEndpoint}",
        data: {"location": location},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error ending work: $e");
      return false;
    }
  }

  Future<bool> updateLocation({
    required String location,
    required double accuracy,
    required int batteryPercentage,
    required double speed,
  }) async {
    try {
      String? token = await SharedPrefs.getUserToken();
      if (token == null) throw Exception("Token not found");

      final response = await _dio.post(
        "$_base${ApiRoutes.locationEndpoint}",
        data: {
          "location": location,
          "accuracy": accuracy,
          "battery_percentage": batteryPercentage,
          "speed": speed,
        },
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error updating location: $e");
      return false;
    }
  }

  Future<bool> checkCurrentStatus() async {
    try {
      String? token = await SharedPrefs.getUserToken();
      if (token == null) throw Exception("Token not found");

      final response = await _dio.get(
        "$_base${ApiRoutes.currentWorkStatusEndpoint}",
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        }),
      );

      if (response.statusCode == 200 && response.data != null) {
        // Assume API returns some object, e.g., {"status": "started"} or {"is_working": true}
        // Since we don't know the exact response format for GET current-status, 
        // we'll try to look for 'is_working' or 'status' == 'started'.
        // Let's assume it returns { "data": { "is_working": true } } or similar.
        final data = response.data;
        if (data is Map<String, dynamic>) {
          if (data['is_working'] == true || data['status'] == 'STARTED') {
            return true;
          }
          if (data['data'] != null && data['data'] is Map) {
             if (data['data']['is_working'] == true || data['data']['status'] == 'STARTED') {
               return true;
             }
          }
        }
        return false;
      }
      return false;
    } catch (e) {
      print("❌ Error checking status: $e");
      return false;
    }
  }
}
