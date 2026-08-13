import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:partener_app/managers/repo/manager_api_service.dart';
import 'package:partener_app/models/user_model.dart';
import 'package:partener_app/services/shared_prefs.dart';
import 'package:partener_app/services/api_service.dart';

class ManagerDashboardController extends GetxController {
  final ManagerApiService _managerApi = ManagerApiService();
  final ApiService _apiService = ApiService();

  var isLoading = false.obs;
  var isActionLoading = false.obs;
  var employees = <UserModel>[].obs;
  var errorMessage = ''.obs;
  var managerProfile = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
    fetchInitialData();
  }

  Future<void> loadPreferences() async {
    isMapView.value = await SharedPrefs.getMapViewPreference();
  }

  Future<void> fetchInitialData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      managerProfile.value = await _apiService.fetchUserProfile();
      await fetchMyEmployees();
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyEmployees() async {
    try {
      final dataList = await _managerApi.getMyEmployees();
      employees.value =
          dataList
              .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
              .toList();
    } catch (e) {
      errorMessage.value = "Failed to load employees.";
      print(e);
    }
    // Fetch locations in the background
    fetchAllEmployeeLocations();
  }

  var isMapView = false.obs;
  var employeeLocations = <int, LatLng>{}.obs;
  var employeeStatuses = <int, Map<String, dynamic>>{}.obs;

  void toggleMapView(bool value) {
    isMapView.value = value;
    SharedPrefs.saveMapViewPreference(value);
    if (value && employeeLocations.isEmpty) {
      fetchAllEmployeeLocations();
    }
  }

  Future<void> fetchAllEmployeeLocations() async {
    for (var emp in employees) {
      if (emp.id != null) {
        final data = await _managerApi.getEmployeeDashboard(emp.id!);
        if (data != null) {
          employeeStatuses[emp.id!] = data;
          if (data['current_location'] != null) {
            final locStr = data['current_location'].toString();
            final parts = locStr.split(',');
            if (parts.length >= 2) {
              final lat = double.tryParse(parts[0].trim());
              final lng = double.tryParse(parts[1].trim());
              if (lat != null && lng != null) {
                employeeLocations[emp.id!] = LatLng(lat, lng);
              }
            }
          }
        }
      }
    }
  }

  var selectedEmployeeId = Rxn<int>();
  var selectedEmployeeRange = Rxn<Map<String, dynamic>>();
  var isRangeLoading = false.obs;

  Future<void> selectEmployeeOnMap(int employeeId) async {
    selectedEmployeeId.value = employeeId;
    selectedEmployeeRange.value = null;
    isRangeLoading.value = true;
    try {
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final rangeData = await _managerApi.fetchEmployeeRangeSummary(
        employeeId: employeeId,
        startDate: todayStr,
        endDate: todayStr,
      );
      selectedEmployeeRange.value = rangeData;
    } catch (e) {
      print("Error fetching employee range summary: $e");
    } finally {
      isRangeLoading.value = false;
    }
  }
}
