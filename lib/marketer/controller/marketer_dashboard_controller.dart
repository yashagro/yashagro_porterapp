import 'package:get/get.dart';
import 'package:partener_app/marketer/model/marketer_dashboard_model.dart';
import 'package:partener_app/marketer/model/marketer_month_summary_model.dart';
import 'package:partener_app/marketer/model/marketer_route_history_model.dart';
import 'package:partener_app/marketer/model/marketer_today_summary_model.dart';
import 'package:partener_app/marketer/repo/marketer_dashboard_service.dart';
import 'package:partener_app/models/user_model.dart';
import 'package:partener_app/services/shared_prefs.dart';

class MarketerDashboardController extends GetxController {
  final MarketerDashboardService _service = MarketerDashboardService();

  Rx<MarketerDashboardModel?> dashboard = Rx<MarketerDashboardModel?>(null);
  Rx<UserModel?> user = Rx<UserModel?>(null);
  Rx<MarketerMonthSummaryModel?> monthSummary = Rx<MarketerMonthSummaryModel?>(
    null,
  );
  RxList<MarketerTodaySummaryModel> todaySummary =
      <MarketerTodaySummaryModel>[].obs;
  RxList<MarketerRouteHistoryModel> routeHistory =
      <MarketerRouteHistoryModel>[].obs;
  Rx<DateTime> selectedHistoryDate = DateTime.now().obs;
  RxInt selectedRouteIndex = (-1).obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final results = await Future.wait([
        _service.fetchDashboard(),
        _service.fetchUserProfile(),
        _service.fetchMonthSummary(),
        _service.fetchTodaySummary(),
      ]);

      dashboard.value = results[0] as MarketerDashboardModel?;
      user.value = results[1] as UserModel?;
      monthSummary.value = results[2] as MarketerMonthSummaryModel?;
      todaySummary.assignAll(results[3] as List<MarketerTodaySummaryModel>);
      await fetchRouteHistoryForDate(selectedHistoryDate.value);
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard data.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRouteHistoryForDate(DateTime date) async {
    selectedHistoryDate.value = date;
    try {
      final employeeId = await _resolveEmployeeId();
      if (employeeId == null) {
        routeHistory.clear();
        return;
      }

      final history = await _service.fetchRouteHistory(
        employeeId: employeeId,
        date: date,
      );
      routeHistory.assignAll(history);
      selectedRouteIndex.value = history.isNotEmpty ? history.length - 1 : -1;
    } catch (e) {
      routeHistory.clear();
      selectedRouteIndex.value = -1;
    }
  }

  void selectRoutePoint(int index) {
    if (index < 0 || index >= routeHistory.length) {
      selectedRouteIndex.value = -1;
      return;
    }
    selectedRouteIndex.value = index;
  }

  Future<int?> _resolveEmployeeId() async {
    if (user.value?.id != null) {
      return user.value!.id;
    }
    return SharedPrefs.getUserId();
  }
}
