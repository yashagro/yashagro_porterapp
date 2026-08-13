import 'dart:developer' show log;

import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:partener_app/marketer/model/marketer_dashboard_model.dart';
import 'package:partener_app/marketer/model/marketer_month_summary_model.dart';
import 'package:partener_app/marketer/model/marketer_route_history_model.dart';
import 'package:partener_app/marketer/model/marketer_today_summary_model.dart';
import 'package:partener_app/marketer/repo/marketer_dashboard_service.dart';
import 'package:partener_app/models/user_model.dart';
import 'package:partener_app/services/shared_prefs.dart';

class MarketerDashboardController extends GetxController {
  final MarketerDashboardService _service = MarketerDashboardService();
  int? employeeIdOverride;

  MarketerDashboardController({this.employeeIdOverride});

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
  Rx<Map<String, dynamic>?> currentStatus = Rx<Map<String, dynamic>?>(null);
  RxList<dynamic> myTargets = <dynamic>[].obs;
  Rx<Map<String, dynamic>?> rangeSummary = Rx<Map<String, dynamic>?>(null);
  Rx<Map<String, dynamic>?> completedTargets = Rx<Map<String, dynamic>?>(null);

  // New Range History States
  Rx<DateTimeRange?> selectedHistoryDateRange = Rx<DateTimeRange?>(
    DateTimeRange(start: DateTime.now(), end: DateTime.now()),
  );
  RxList<Map<String, dynamic>> rangeDaysList = <Map<String, dynamic>>[].obs;
  RxBool isHistoryLoading = false.obs;
  Rx<DateTime?> selectedSpecificDay = Rx<DateTime?>(null);
  RxMap<String, dynamic> specificDayDetails = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
    fetchHistoryForRange(selectedHistoryDateRange.value!);
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final currentUserId = employeeIdOverride ?? await SharedPrefs.getUserId();
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final results = await Future.wait([
        _service.fetchDashboard(),
        _service.fetchUserProfile(),
        _service.fetchMonthSummary(),
        _service.fetchTodaySummary(),
        _service.fetchCurrentStatus(),
        if (currentUserId != null)
          _service.fetchEmployeeTargetRange(
            employeeId: currentUserId,
            startDate: todayStr,
            endDate: todayStr,
          )
        else
          Future.value(null),
        if (currentUserId != null)
          _service.fetchEmployeeRangeSummary(
            employeeId: currentUserId,
            startDate: todayStr,
            endDate: todayStr,
          )
        else
          Future.value(null),
        if (currentUserId != null)
          _service.fetchEmployeeCompletedTargets(
            employeeId: currentUserId,
            startDate: todayStr,
            endDate: todayStr,
          )
        else
          Future.value(null),
      ]);

      dashboard.value = results[0] as MarketerDashboardModel?;
      user.value = results[1] as UserModel?;
      monthSummary.value = results[2] as MarketerMonthSummaryModel?;
      todaySummary.assignAll(results[3] as List<MarketerTodaySummaryModel>);
      currentStatus.value = results[4] as Map<String, dynamic>?;

      final targetRangeData = results[5] as Map<String, dynamic>?;
      if (targetRangeData != null && targetRangeData['targets'] is List) {
        myTargets.assignAll(targetRangeData['targets'] as List<dynamic>);
      } else {
        myTargets.clear();
      }

      rangeSummary.value = results[6] as Map<String, dynamic>?;
      completedTargets.value = results[7] as Map<String, dynamic>?;

      print("DEBUG rangeSummary: ${rangeSummary.value}");
      print("DEBUG completedTargets: ${completedTargets.value}");

      await fetchRouteHistoryForDate(selectedHistoryDate.value);
    } catch (e) {
      errorMessage.value = 'Failed to load dashboard data.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchHistoryForRange(DateTimeRange range) async {
    selectedHistoryDateRange.value = range;
    isHistoryLoading.value = true;
    try {
      final currentUserId = employeeIdOverride ?? await SharedPrefs.getUserId();
      if (currentUserId == null) return;

      final diffInDays = range.end.difference(range.start).inDays;
      List<Map<String, dynamic>> days = [];

      for (int i = 0; i <= diffInDays; i++) {
        final day = range.start.add(Duration(days: i));
        final dayStr = DateFormat('yyyy-MM-dd').format(day);

        // Fetch targets, range summary, completed targets, and raw visits for each specific day
        final results = await Future.wait([
          _service.fetchEmployeeTargetRange(
            employeeId: currentUserId,
            startDate: dayStr,
            endDate: dayStr,
          ),
          _service.fetchEmployeeRangeSummary(
            employeeId: currentUserId,
            startDate: dayStr,
            endDate: dayStr,
          ),
          _service.fetchEmployeeCompletedTargets(
            employeeId: currentUserId,
            startDate: dayStr,
            endDate: dayStr,
          ),
          _service.getMarketerVisits(),
        ]);

        final targetData = results[0] as Map<String, dynamic>?;
        final summaryData = results[1] as Map<String, dynamic>?;
        final completedData = results[2] as Map<String, dynamic>?;
        final rawVisits = results[3] as List<dynamic>? ?? [];

        // Calculate Target info
        int targetFarm = 0;
        int targetStore = 0;
        int completedFarm = 0;
        int completedStore = 0;

        final targetsObj = summaryData != null ? summaryData['targets'] : null;
        if (targetsObj is Map && (targetsObj.containsKey('FARM_VISIT') || targetsObj.containsKey('STORE_VISIT'))) {
          final farmList = targetsObj['FARM_VISIT'] as List<dynamic>? ?? [];
          final farmTargetForDay = farmList.firstWhereOrNull((t) {
            final dateRaw = t['date'];
            if (dateRaw == null) return false;
            try {
              final parsedDate = DateTime.parse(dateRaw.toString()).toLocal();
              return DateFormat('yyyy-MM-dd').format(parsedDate) == dayStr;
            } catch (e) {
              return dateRaw.toString().startsWith(dayStr);
            }
          });
          if (farmTargetForDay != null) {
            targetFarm = farmTargetForDay['count'] as int? ?? 0;
            completedFarm = farmTargetForDay['completed'] as int? ?? 0;
          }

          final storeList = targetsObj['STORE_VISIT'] as List<dynamic>? ?? [];
          final storeTargetForDay = storeList.firstWhereOrNull((t) {
            final dateRaw = t['date'];
            if (dateRaw == null) return false;
            try {
              final parsedDate = DateTime.parse(dateRaw.toString()).toLocal();
              return DateFormat('yyyy-MM-dd').format(parsedDate) == dayStr;
            } catch (e) {
              return dateRaw.toString().startsWith(dayStr);
            }
          });
          if (storeTargetForDay != null) {
            targetStore = storeTargetForDay['count'] as int? ?? 0;
            completedStore = storeTargetForDay['completed'] as int? ?? 0;
          }
        } else {
          final targetsList =
              targetData != null
                  ? targetData['targets'] as List<dynamic>? ?? []
                  : [];
          for (var t in targetsList) {
            final type = t['type']?.toString().toLowerCase() ?? '';
            final count = t['target_count'] as int? ?? 0;
            if (type == 'farm') {
              targetFarm += count;
            } else {
              targetStore += count;
            }
          }

          final compTargets = completedData != null && completedData['completed_targets'] != null
              ? completedData['completed_targets'] as Map<String, dynamic>
              : (completedData != null && completedData['data'] != null && completedData['data']['completed_targets'] != null
                  ? completedData['data']['completed_targets'] as Map<String, dynamic>
                  : {});

          completedFarm = compTargets['farm'] as int? ?? 0;
          completedStore = (compTargets['visit'] ?? compTargets['store'] ?? compTargets['customer']) as int? ?? 0;
        }

        final rawWorkSession = summaryData != null ? summaryData['work_session'] : null;
        Map<String, dynamic>? workSession;
        if (rawWorkSession != null && rawWorkSession['start_time'] != null) {
          try {
            final parsedDate = DateTime.parse(rawWorkSession['start_time'].toString()).toLocal();
            final sessionDateStr = DateFormat('yyyy-MM-dd').format(parsedDate);
            if (sessionDateStr == dayStr) {
              workSession = Map<String, dynamic>.from(rawWorkSession);
            }
          } catch (e) {
            final startTimeStr = rawWorkSession['start_time'].toString();
            final sessionDateStr = startTimeStr.split('T')[0];
            if (sessionDateStr == dayStr) {
              workSession = Map<String, dynamic>.from(rawWorkSession);
            }
          }
        }
        final travelMeter =
            summaryData != null ? summaryData['travel_meter'] ?? 0 : 0;
        final locations =
            summaryData != null
                ? summaryData['locations'] as List<dynamic>? ?? []
                : [];

        // Parse and merge visits
        final List<dynamic> visits = [];
        if (summaryData != null) {
          final empVisits = (summaryData['emp_visits'] ?? summaryData['visits']) as List<dynamic>? ?? [];
          visits.addAll(empVisits);
        }

        // If the summary visits array is empty, populate from filtered raw GET /api/emp-mark-visit list
        if (visits.isEmpty) {
          final filteredVisitsList = rawVisits.where((v) {
            final empId = v['employee_id'] ?? v['employee']?['id'];
            if (empId != null && empId.toString() != currentUserId.toString()) {
              return false;
            }
            final createdAt = v['created_at']?.toString();
            if (createdAt != null) {
              final dateStr = createdAt.split('T')[0];
              return dateStr == dayStr;
            }
            return false;
          }).toList();
          visits.addAll(filteredVisitsList);
        }

        days.add({
          'date': day,
          'target_farm': targetFarm,
          'target_store': targetStore,
          'completed_farm': completedFarm,
          'completed_store': completedStore,
          'travel_meter': travelMeter,
          'work_session': workSession,
          'locations': locations,
          'visits': visits,
          'completed_targets_data': completedData,
        });
      }

      rangeDaysList.assignAll(days);

      // Auto-select the first day for detail view if not empty
      if (days.isNotEmpty) {
        selectSpecificDay(days.first['date'] as DateTime);
      } else {
        selectedSpecificDay.value = null;
        specificDayDetails.clear();
      }
    } catch (e) {
      log('Error fetching range history: $e');
    } finally {
      isHistoryLoading.value = false;
    }
  }

  void selectSpecificDay(DateTime day) {
    selectedSpecificDay.value = day;
    final match = rangeDaysList.firstWhere(
      (element) =>
          DateFormat('yyyy-MM-dd').format(element['date'] as DateTime) ==
          DateFormat('yyyy-MM-dd').format(day),
      orElse: () => <String, dynamic>{},
    );
    specificDayDetails.addAll(match);
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
    if (employeeIdOverride != null) {
      return employeeIdOverride;
    }
    if (user.value?.id != null) {
      return user.value!.id;
    }
    return SharedPrefs.getUserId();
  }
}
