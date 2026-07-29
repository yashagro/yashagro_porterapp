import 'dart:io';

import 'package:dio/dio.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/services/shared_prefs.dart';

class WorkStatusResponse {
  final bool success;
  final String message;

  const WorkStatusResponse({
    required this.success,
    required this.message,
  });
}

class EmployeeTrackingService {
  final Dio _dio = Dio();
  final String _base = ApiRoutes.baseUri;

  Future<WorkStatusResponse> startWork(
    String location,
    List<File> images,
    int travelMeter,
  ) async {
    try {
      String? token = await SharedPrefs.getUserToken();
      if (token == null) throw Exception("Token not found");

      final formData = FormData();
      formData.fields.add(MapEntry('location', location));
      formData.fields.add(MapEntry('travel_meter', travelMeter.toString()));
      formData.fields.add(MapEntry('meter_reading', travelMeter.toString()));

      for (final image in images) {
        formData.files.add(
          MapEntry(
            'start_work_images',
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post(
        "$_base${ApiRoutes.startWorkEndpoint}",
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        }),
      );
      print("✅ Start work API response: ${response.data}");

      final message = _extractMessage(response.data);
      return WorkStatusResponse(
        success: response.statusCode == 200,
        message: message ?? "Unable to start work.",
      );
    } catch (e) {
      print("❌ Error starting work: $e");
      if (e is DioException) {
        print("⚠️ Start work error response: ${e.response?.data}");
        return WorkStatusResponse(
          success: false,
          message: _extractMessage(e.response?.data) ?? e.message ?? "Failed to start work",
        );
      }
      return WorkStatusResponse(
        success: false,
        message: e.toString(),
      );
    }
  }

  Future<WorkStatusResponse> endWork(
    String location,
    List<File> images,
    int travelMeter,
  ) async {
    try {
      String? token = await SharedPrefs.getUserToken();
      if (token == null) throw Exception("Token not found");

      final formData = FormData();
      formData.fields.add(MapEntry('location', location));
      formData.fields.add(MapEntry('travel_meter', travelMeter.toString()));
      formData.fields.add(MapEntry('meter_reading', travelMeter.toString()));

      for (final image in images) {
        formData.files.add(
          MapEntry(
            'end_work_images',
            await MultipartFile.fromFile(
              image.path,
              filename: image.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post(
        "$_base${ApiRoutes.endWorkEndpoint}",
        data: formData,
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        }),
      );
      print("✅ End work API response: ${response.data}");

      final message = _extractMessage(response.data);
      return WorkStatusResponse(
        success: response.statusCode == 200,
        message: message ?? "Unable to end work.",
      );
    } catch (e) {
      print("❌ Error ending work: $e");
      if (e is DioException) {
        print("⚠️ End work error response: ${e.response?.data}");
        return WorkStatusResponse(
          success: false,
          message: _extractMessage(e.response?.data) ?? e.message ?? "Failed to end work",
        );
      }
      return WorkStatusResponse(
        success: false,
        message: e.toString(),
      );
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
      print("✅ Update location API response: ${response.data}");

      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error updating location: $e");
      if (e is DioException) {
        print("⚠️ Update location error response: ${e.response?.data}");
      }
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
      print("✅ Current work status API response: ${response.data}");

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
      if (e is DioException) {
        print("⚠️ Current work status error response: ${e.response?.data}");
      }
      return false;
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final candidates = [
        data['message'],
        data['msg'],
        data['error'],
        data['detail'],
        data['data'] is Map<String, dynamic> ? data['data']['message'] : null,
      ];

      for (final candidate in candidates) {
        if (candidate != null && candidate.toString().trim().isNotEmpty) {
          return candidate.toString().trim();
        }
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    return null;
  }
}
