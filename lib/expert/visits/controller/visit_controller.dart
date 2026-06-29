import 'package:get/get.dart';
import 'package:partener_app/expert/visits/model/visit_feedback_model.dart';
import 'package:partener_app/expert/visits/model/visit_model.dart';
import 'package:partener_app/expert/visits/repo/visit_api_service.dart';

class VisitController extends GetxController {
  final VisitApiService _apiService = VisitApiService();

  var isLoading = false.obs;

  var pendingRequests = <VisitModel>[].obs;
  var myVisits = <VisitModel>[].obs;
  var todayVisits = <VisitModel>[].obs;
  var upcomingVisits = <VisitModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading(true);
    await Future.wait([
      fetchPendingRequests(),
      fetchMyVisits(),
      fetchTodayVisits(),
      fetchUpcomingVisits(),
    ]);
    isLoading(false);
  }

  Future<void> fetchPendingRequests() async {
    // Assuming status='PENDING' for requests, adjust as per API
    var res = await _apiService.getAllVisits(status: 'PENDING');
    if (res != null) {
      pendingRequests.assignAll(res);
    }
  }

  Future<void> fetchMyVisits() async {
    var res = await _apiService.getMyVisits();
    if (res != null) {
      myVisits.assignAll(res);
    }
  }

  Future<void> fetchTodayVisits() async {
    var res = await _apiService.getTodayVisits();
    if (res != null) {
      todayVisits.assignAll(res);
    }
  }

  Future<void> fetchUpcomingVisits() async {
    var res = await _apiService.getUpcomingVisits();
    if (res != null) {
      upcomingVisits.assignAll(res);
    }
  }

  Future<bool> approveRequest(
    int requestId,
    String scheduledAt,
    String remarks,
  ) async {
    bool success = await _apiService.approveVisitRequest(
      requestId,
      scheduledAt,
      remarks,
    );
    if (success) {
      await fetchAllData();
    }
    return success;
  }

  Future<bool> rejectRequest(int requestId, String reason) async {
    bool success = await _apiService.rejectVisitRequest(requestId, reason);
    if (success) {
      await fetchAllData();
    }
    return success;
  }

  Future<bool> updateStatus(int visitId, String status, String remarks) async {
    bool success = await _apiService.updateVisitStatus(
      visitId,
      status,
      remarks,
    );
    if (success) {
      await fetchAllData();
    }
    return success;
  }

  Future<bool> submitFeedback({
    required int visitId,
    required String feedback,
    required String recommendation,
    required String cropCondition,
    required String nextVisitDate,
  }) async {
    bool success = await _apiService.submitVisitFeedback(
      visitId: visitId,
      feedback: feedback,
      recommendation: recommendation,
      cropCondition: cropCondition,
      nextVisitDate: nextVisitDate,
    );
    if (success) {
      await fetchAllData();
    }
    return success;
  }

  Future<VisitFeedbackModel?> getVisitFeedback(int visitId) async {
    return await _apiService.getVisitFeedback(visitId);
  }

  Future<VisitModel?> getVisitDetails(int visitId) async {
    return await _apiService.getVisitDetails(visitId);
  }

  Future<List<VisitStatusHistoryModel>?> getVisitStatusHistory(
    int visitId,
  ) async {
    return await _apiService.getVisitStatusHistory(visitId);
  }

  Future<Map<String, dynamic>?> getPlotDetails(int plotId) async {
    return await _apiService.getPlotDetails(plotId);
  }
}
