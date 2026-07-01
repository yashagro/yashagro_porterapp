import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/marketer/model/marketer_dashboard_model.dart';
import 'package:partener_app/marketer/model/marketer_month_summary_model.dart';
import 'package:partener_app/marketer/model/marketer_route_history_model.dart';
import 'package:partener_app/marketer/model/marketer_today_summary_model.dart';
import 'package:partener_app/models/user_model.dart';
import 'package:partener_app/services/shared_prefs.dart';

class MarketerDashboardService {
  final Dio _dio = Dio();

  Future<MarketerDashboardModel?> fetchDashboard() async {
    final token = await SharedPrefs.getUserToken();
    if (token == null || token.isEmpty) {
      throw Exception('No token found');
    }

    final response = await _dio.get(
      '${ApiRoutes.baseUri}${ApiRoutes.employeeDashboardEndpoint}',
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception('Failed to fetch marketer dashboard');
    }

    final responseData = response.data;
    if (responseData is! Map<String, dynamic>) {
      throw Exception('Unexpected marketer dashboard response');
    }

    final rawDashboard =
        responseData['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(responseData['data'])
            : responseData;

    return MarketerDashboardModel.fromJson(rawDashboard);
  }

  Future<List<MarketerTodaySummaryModel>> fetchTodaySummary() async {
    final response = await _authorizedGet(
      '${ApiRoutes.baseUri}${ApiRoutes.employeeDashboardTodaySummaryEndpoint}',
    );

    final rawList = response['data'] is List ? response['data'] as List : [];
    return rawList
        .whereType<Map>()
        .map(
          (item) => MarketerTodaySummaryModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<MarketerMonthSummaryModel?> fetchMonthSummary() async {
    final response = await _authorizedGet(
      '${ApiRoutes.baseUri}${ApiRoutes.employeeDashboardMonthSummaryEndpoint}',
    );

    final rawData =
        response['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(response['data'])
            : response;

    return MarketerMonthSummaryModel.fromJson(rawData);
  }

  Future<UserModel?> fetchUserProfile() async {
    final response = await _authorizedGet(
      '${ApiRoutes.baseUri}${ApiRoutes.userProfileEndpoint}',
    );

    final rawData =
        response['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(response['data'])
            : response;

    return UserModel.fromJson(rawData);
  }

  Future<List<MarketerRouteHistoryModel>> fetchRouteHistory({
    required int employeeId,
    required DateTime date,
  }) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    final response = await _authorizedGet(
      '${ApiRoutes.baseUri}${ApiRoutes.employeeRouteHistoryEndpoint}?employee_id=$employeeId&date=$formattedDate',
    );

    final rawList = response['data'] is List ? response['data'] as List : [];
    return rawList
        .whereType<Map>()
        .map(
          (item) => MarketerRouteHistoryModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();
  }

  Future<Map<String, dynamic>> _authorizedGet(String url) async {
    final token = await SharedPrefs.getUserToken();
    if (token == null || token.isEmpty) {
      throw Exception('No token found');
    }

    final response = await _dio.get(
      url,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode != 200 || response.data == null) {
      throw Exception('Request failed for $url');
    }

    if (response.data is! Map<String, dynamic>) {
      throw Exception('Unexpected response for $url');
    }

    return Map<String, dynamic>.from(response.data);
  }
}
