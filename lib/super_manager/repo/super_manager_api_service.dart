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

  /// Get all users and filter for employees/marketers (role_id = 7)
  Future<List<dynamic>> getAllEmployees() async {
    try {
      final response = await _dio.get(
        "$_base${ApiRoutes.adminUsersEndpoint}",
        options: await _getAuthOptions(),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> users = [];

        if (data is Map && data['data'] != null) {
          users = data['data'] as List<dynamic>;
        } else if (data is List) {
          users = data;
        }

        // Filter users to return only those with role_id == 7 (Marketers)
        return users.where((user) {
          if (user is Map) {
            return user['role_id'] == 7 || user['role_id'] == '7';
          }
          return false;
        }).toList();
      }
      return [];
    } catch (e) {
      print("❌ Error getting all employees: $e");
      return [];
    }
  }

  /// Get the assigned manager for a specific employee
  Future<Map<String, dynamic>?> getEmployeeManager(int employeeId) async {
    try {
      final response = await _dio.get(
        "$_base/api/employee/$employeeId/manager",
        options: await _getAuthOptions(),
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data is Map && data['data'] != null) {
          return Map<String, dynamic>.from(data['data']);
        }
      }
    } catch (e) {
      print("❌ Error getting manager for employee $employeeId: $e");
    }
    return null;
  }

  /// Assign/Change Manager for an employee
  Future<bool> assignManager({required int employeeId, required int managerId}) async {
    try {
      final options = await _getAuthOptions();
      
      // Try assign-employee endpoint first
      final res1 = await _dio.post(
        "$_base/api/manager/assign-employee",
        data: {
          "employee_id": employeeId,
          "manager_id": managerId,
        },
        options: options,
      );

      if (res1.statusCode == 200 || res1.statusCode == 201) {
        return true;
      }
    } catch (e) {
      print("⚠️ assign-employee failed: $e. Trying change-manager...");
    }

    try {
      final options = await _getAuthOptions();
      // Try change-manager endpoint as fallback
      final res2 = await _dio.post(
        "$_base/api/manager/change-manager",
        data: {
          "employee_id": employeeId,
          "manager_id": managerId,
        },
        options: options,
      );

      if (res2.statusCode == 200 || res2.statusCode == 201) {
        return true;
      }
    } catch (e) {
      print("❌ Both assignment endpoints failed: $e");
    }
    return false;
  }
}
