import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/expert/visits/model/visit_feedback_model.dart';
import 'package:partener_app/expert/visits/model/visit_model.dart';
import 'package:partener_app/services/api_service.dart';
import 'package:partener_app/services/shared_prefs.dart';

class VisitApiService {
  final Dio _dio = Dio();
  final ApiService _apiService = ApiService();
  final String baseUrl = ApiRoutes.baseUri;

  Future<Map<String, String>?> _getHeaders() async {
    String? authToken = await SharedPrefs.getUserToken();
    if (authToken == null) return null;
    return {
      "Authorization": "Bearer $authToken",
      "Content-Type": "application/json",
    };
  }

  Future<bool> approveVisitRequest(
    int requestId,
    String scheduledAt,
    String remarks,
  ) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return false;

      Response response = await _dio.put(
        "$baseUrl${ApiRoutes.approveVisitRequestEndpoint}$requestId",
        options: Options(headers: headers),
        data: {"scheduled_at": scheduledAt, "remarks": remarks},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      log("❌ Error Approving Visit Request: $e");
      return false;
    }
  }

  Future<bool> rejectVisitRequest(int requestId, String reason) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return false;

      Response response = await _dio.put(
        "$baseUrl${ApiRoutes.rejectVisitRequestEndpoint}$requestId",
        options: Options(headers: headers),
        data: {"reason": reason},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      log("❌ Error Rejecting Visit Request: $e");
      return false;
    }
  }

  Future<List<VisitModel>?> getMyVisits() async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.getMyVisitsEndpoint}",
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((e) => VisitModel.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      log("❌ Error Fetching My Visits: $e");
      return null;
    }
  }

  Future<List<VisitModel>?> getTodayVisits() async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.getTodayVisitsEndpoint}",
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((e) => VisitModel.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      log("❌ Error Fetching Today Visits: $e");
      return null;
    }
  }

  Future<List<VisitModel>?> getUpcomingVisits() async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.getUpcomingVisitsEndpoint}",
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((e) => VisitModel.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      log("❌ Error Fetching Upcoming Visits: $e");
      return null;
    }
  }

  Future<List<VisitModel>?> getAllVisits({
    String? status,
    int? employeeId,
    int? farmerId,
  }) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      Map<String, dynamic> queryParams = {};
      if (status != null) queryParams['status'] = status;
      if (employeeId != null) queryParams['employee_id'] = employeeId;
      if (farmerId != null) queryParams['farmer_id'] = farmerId;

      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.getAllVisitsEndpoint}",
        queryParameters: queryParams,
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((e) => VisitModel.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      log("❌ Error Fetching All Visits: $e");
      return null;
    }
  }

  Future<VisitModel?> getVisitDetails(int id) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.getVisitDetailsEndpoint}$id",
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        var data = response.data['data'] ?? response.data;
        return VisitModel.fromJson(data);
      }
      return null;
    } catch (e) {
      log("❌ Error Fetching Visit Details: $e");
      return null;
    }
  }

  Future<bool> updateVisitStatus(int id, String status, String remarks) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return false;

      Response response = await _dio.put(
        "$baseUrl${ApiRoutes.updateVisitStatusEndpoint}$id",
        options: Options(headers: headers),
        data: {"status": status, "remarks": remarks},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      log("❌ Error Updating Visit Status: $e");
      return false;
    }
  }

  Future<List<VisitStatusHistoryModel>?> getVisitStatusHistory(
    int visitId,
  ) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.getVisitStatusHistoryEndpoint}$visitId",
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((e) => VisitStatusHistoryModel.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      log("❌ Error Fetching Visit Status History: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getPlotDetails(int plotId) async {
    return _apiService.fetchPlotDetails(plotId);
  }

  // ---- Visit Feedback APIs ----

  /// POST /api/visit-feedback - Submit visit feedback
  Future<bool> submitVisitFeedback({
    required int visitId,
    required String feedback,
    required String recommendation,
    required String cropCondition,
    required String nextVisitDate,
  }) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return false;

      Response response = await _dio.post(
        "$baseUrl${ApiRoutes.submitVisitFeedbackEndpoint}",
        options: Options(headers: headers),
        data: {
          "visit_id": visitId,
          "feedback": feedback,
          "recommendation": recommendation,
          "crop_condition": cropCondition,
          "next_visit_date": nextVisitDate,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      log("❌ Error Submitting Visit Feedback: $e");
      return false;
    }
  }

  /// PUT /api/visit-feedback/{id} - Update visit feedback
  Future<bool> updateVisitFeedback({
    required int id,
    String? feedback,
    String? recommendation,
    String? cropCondition,
    String? nextVisitDate,
  }) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return false;

      Map<String, dynamic> data = {};
      if (feedback != null) data['feedback'] = feedback;
      if (recommendation != null) data['recommendation'] = recommendation;
      if (cropCondition != null) data['crop_condition'] = cropCondition;
      if (nextVisitDate != null) data['next_visit_date'] = nextVisitDate;

      Response response = await _dio.put(
        "$baseUrl${ApiRoutes.updateVisitFeedbackEndpoint}$id",
        options: Options(headers: headers),
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      log("❌ Error Updating Visit Feedback: $e");
      return false;
    }
  }

  /// GET /api/visit-feedback/{visit_id} - Get feedback by visit
  Future<VisitFeedbackModel?> getVisitFeedback(int visitId) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.getVisitFeedbackEndpoint}$visitId",
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        var data = response.data['data'] ?? response.data;
        return VisitFeedbackModel.fromJson(data);
      }
      return null;
    } catch (e) {
      log("❌ Error Fetching Visit Feedback: $e");
      return null;
    }
  }

  /// GET /api/my-feedbacks - Farmer feedback history
  Future<List<VisitFeedbackModel>?> getMyFeedbacks() async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      Response response = await _dio.get(
        "$baseUrl${ApiRoutes.getMyFeedbacksEndpoint}",
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'] ?? response.data;
        return data.map((e) => VisitFeedbackModel.fromJson(e)).toList();
      }
      return null;
    } catch (e) {
      log("❌ Error Fetching My Feedbacks: $e");
      return null;
    }
  }
}
