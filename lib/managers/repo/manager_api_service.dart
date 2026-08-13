import 'package:dio/dio.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/services/shared_prefs.dart';

class ManagerApiService {
  final Dio _dio = Dio();
  final String _base = ApiRoutes.baseUri;

  Future<Options> _getAuthOptions() async {
    String? token = await SharedPrefs.getUserToken();
    if (token == null) throw Exception("Token not found");
    return Options(headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
  }



  /// Get employee dashboard details for a specific employee
  Future<Map<String, dynamic>?> getEmployeeDashboard(int employeeId) async {
    try {
      final url = "$_base${ApiRoutes.employeeDashboardEndpoint}?user_id=$employeeId";
      print("🌐 Fetching employee dashboard from: $url");
      final response = await _dio.get(
        url,
        options: await _getAuthOptions(),
      );
      print("✅ Get employee dashboard response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
      return null;
    } catch (e) {
      print("❌ Error getting employee dashboard: $e");
      return null;
    }
  }

  /// Get employee today summary
  Future<Map<String, dynamic>?> getEmployeeTodaySummary(int employeeId) async {
    try {
      final url = "$_base${ApiRoutes.employeeDashboardTodaySummaryEndpoint}?user_id=$employeeId";
      print("🌐 Fetching employee today summary from: $url");
      final response = await _dio.get(
        url,
        options: await _getAuthOptions(),
      );
      print("✅ Get employee today summary response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
      return null;
    } catch (e) {
      print("❌ Error getting employee today summary: $e");
      return null;
    }
  }

  /// Get employee month summary
  Future<Map<String, dynamic>?> getEmployeeMonthSummary(int employeeId) async {
    try {
      final url = "$_base${ApiRoutes.employeeDashboardMonthSummaryEndpoint}?user_id=$employeeId";
      print("🌐 Fetching employee month summary from: $url");
      final response = await _dio.get(
        url,
        options: await _getAuthOptions(),
      );
      print("✅ Get employee month summary response: ${response.data}");
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
      return null;
    } catch (e) {
      print("❌ Error getting employee month summary: $e");
      return null;
    }
  }

  /// Get all manager-employee assignments
  Future<List<dynamic>> getAllAssignments() async {
    try {
      final response = await _dio.get(
        "$_base${ApiRoutes.managerAssignmentsEndpoint}",
        options: await _getAuthOptions(),
      );
      print("✅ Get all assignments response: ${response.data}");
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] != null) {
          return data['data'] as List<dynamic>;
        }
        if (data is List) {
          return data;
        }
      }
      return [];
    } catch (e) {
      print("❌ Error getting all assignments: $e");
      if (e is DioException) {
        print("⚠️ Response: ${e.response?.data}");
      }
      return [];
    }
  }

  /// Get manager assigned to an employee
  Future<Map<String, dynamic>?> getEmployeeManager(int employeeId) async {
    try {
      final response = await _dio.get(
        "$_base${ApiRoutes.employeeManagerEndpoint}$employeeId/manager",
        options: await _getAuthOptions(),
      );
      print("✅ Get employee manager response: ${response.data}");
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] != null) {
          return data['data'];
        }
        return data as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      print("❌ Error getting employee manager: $e");
      if (e is DioException) {
        print("⚠️ Response: ${e.response?.data}");
      }
      return null;
    }
  }

  /// Get logged-in manager's employees
  Future<List<dynamic>> getMyEmployees() async {
    try {
      final response = await _dio.get(
        "$_base${ApiRoutes.myEmployeesEndpoint}",
        options: await _getAuthOptions(),
      );
      print("✅ Get my employees response: ${response.data}");
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] != null) {
          return data['data'] as List<dynamic>;
        }
        if (data is List) {
          return data;
        }
      }
      return [];
    } catch (e) {
      print("❌ Error getting my employees: $e");
      if (e is DioException) {
        print("⚠️ Response: ${e.response?.data}");
      }
      return [];
    }
  }

  /// Get all employees under a specific manager
  Future<List<dynamic>> getManagerEmployees(int managerId) async {
    try {
      final response = await _dio.get(
        "$_base${ApiRoutes.managerEmployeesEndpoint}$managerId/employees",
        options: await _getAuthOptions(),
      );
      print("✅ Get manager employees response: ${response.data}");
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] != null) {
          return data['data'] as List<dynamic>;
        }
        if (data is List) {
          return data;
        }
      }
      return [];
    } catch (e) {
      print("❌ Error getting manager employees: $e");
      if (e is DioException) {
        print("⚠️ Response: ${e.response?.data}");
      }
      return [];
    }
  }

  /// Assign target to an employee
  Future<bool> assignTarget({
    required int employeeId,
    required String type,
    required int targetCount,
    required String targetDescription,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _dio.post(
        "$_base${ApiRoutes.assignTargetEndpoint}",
        options: await _getAuthOptions(),
        data: {
          "employee_id": employeeId,
          "type": type,
          "target_count": targetCount,
          "target_description": targetDescription,
          "start_date": startDate,
          "end_date": endDate,
        },
      );
      print("✅ Assign target response: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error assigning target: $e");
      if (e is DioException) {
        print("⚠️ Response: ${e.response?.data}");
      }
      return false;
    }
  }

  /// Update an existing target
  Future<bool> updateTarget({
    required int targetId,
    required String type,
    required int targetCount,
    required String targetDescription,
  }) async {
    try {
      final response = await _dio.put(
        "$_base${ApiRoutes.updateTargetEndpoint}$targetId",
        options: await _getAuthOptions(),
        data: {
          "type": type,
          "target_count": targetCount,
          "target_description": targetDescription,
        },
      );
      print("✅ Update target response: ${response.data}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error updating target: $e");
      if (e is DioException) {
        print("⚠️ Response: ${e.response?.data}");
      }
      return false;
    }
  }

  /// Delete an existing target
  Future<bool> deleteTarget(int targetId) async {
    try {
      final response = await _dio.delete(
        "$_base${ApiRoutes.deleteTargetEndpoint}$targetId",
        options: await _getAuthOptions(),
      );
      print("✅ Delete target response: ${response.data}");
      if (response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      print("❌ Error deleting target: $e");
      if (e is DioException) {
        print("⚠️ Response: ${e.response?.data}");
      }
      return false;
    }
  }

  /// Get employee targets
  Future<List<dynamic>> getEmployeeTargets(int employeeId) async {
    try {
      final response = await _dio.get(
        "$_base${ApiRoutes.getEmployeeTargetsEndpoint}$employeeId",
        options: await _getAuthOptions(),
      );
      print("✅ Get employee targets response: ${response.data}");
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data['data'] != null) {
          return data['data'] as List<dynamic>;
        }
        if (data is List) {
          return data;
        }
      }
      return [];
    } catch (e) {
      print("❌ Error getting employee targets: $e");
      if (e is DioException) {
        print("⚠️ Response: ${e.response?.data}");
      }
      return [];
    }
  }

  Future<Map<String, dynamic>?> fetchEmployeeRangeSummary({
    required int employeeId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _dio.get(
        '$_base/api/employee-range-summary?employee_id=$employeeId&start_date=$startDate&end_date=$endDate',
        options: await _getAuthOptions(),
      );
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
    } catch (e) {
      print("Error fetching range summary: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchEmployeeTargetRange({
    required int employeeId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _dio.get(
        '$_base${ApiRoutes.employeeTargetRangeEndpoint}?employee_id=$employeeId&start_date=$startDate&end_date=$endDate',
        options: await _getAuthOptions(),
      );
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
    } catch (e) {
      print("Error fetching target range: $e");
    }
    return null;
  }

  Future<Map<String, dynamic>?> fetchEmployeeCompletedTargets({
    required int employeeId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _dio.get(
        '$_base${ApiRoutes.employeeCompletedTargetsEndpoint}?employee_id=$employeeId&start_date=$startDate&end_date=$endDate',
        options: await _getAuthOptions(),
      );
      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        return Map<String, dynamic>.from(response.data['data']);
      }
    } catch (e) {
      print("Error fetching completed targets: $e");
    }
    return null;
  }
}
