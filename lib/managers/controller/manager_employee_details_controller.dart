import 'package:get/get.dart';
import 'package:partener_app/managers/repo/manager_api_service.dart';

class ManagerEmployeeDetailsController extends GetxController {
  final ManagerApiService _managerApi = ManagerApiService();
  
  var isLoading = false.obs;
  var dashboardData = Rxn<Map<String, dynamic>>();
  var todaySummary = Rxn<Map<String, dynamic>>();
  var monthSummary = Rxn<Map<String, dynamic>>();
  var targets = <dynamic>[].obs;
  
  Future<void> fetchEmployeeData(int employeeId) async {
    isLoading.value = true;
    
    // Fetch all 4 APIs in parallel
    final results = await Future.wait([
      _managerApi.getEmployeeDashboard(employeeId),
      _managerApi.getEmployeeTodaySummary(employeeId),
      _managerApi.getEmployeeMonthSummary(employeeId),
      _managerApi.getEmployeeTargets(employeeId),
    ]);
    
    dashboardData.value = results[0] as Map<String, dynamic>?;
    todaySummary.value = results[1] as Map<String, dynamic>?;
    monthSummary.value = results[2] as Map<String, dynamic>?;
    targets.assignAll(results[3] as List<dynamic>);
    
    isLoading.value = false;
  }

  Future<bool> assignDailyTargets({
    required int employeeId,
    required int farmTargetCount,
    required int storeTargetCount,
    required String targetDate,
  }) async {
    isLoading.value = true;
    bool success = true;

    final List<Future<bool>> futures = [];
    if (farmTargetCount > 0) {
      futures.add(_managerApi.assignTarget(
        employeeId: employeeId,
        type: 'farm',
        targetCount: farmTargetCount,
        targetDescription: 'Daily Farm Target',
        startDate: targetDate,
        endDate: targetDate,
      ));
    }
    if (storeTargetCount > 0) {
      futures.add(_managerApi.assignTarget(
        employeeId: employeeId,
        type: 'visit',
        targetCount: storeTargetCount,
        targetDescription: 'Daily Store Target',
        startDate: targetDate,
        endDate: targetDate,
      ));
    }

    if (futures.isNotEmpty) {
      final results = await Future.wait(futures);
      success = results.every((element) => element == true);
    } else {
      success = false;
    }

    isLoading.value = false;

    if (success) {
      Get.snackbar('Success', 'Targets assigned successfully', snackPosition: SnackPosition.BOTTOM);
      fetchEmployeeData(employeeId);
    } else {
      Get.snackbar('Error', 'Failed to assign targets', snackPosition: SnackPosition.BOTTOM);
    }
    return success;
  }

  Future<bool> assignTarget({
    required int employeeId,
    required String type,
    required int targetCount,
    required String targetDescription,
    required String startDate,
    required String endDate,
  }) async {
    isLoading.value = true;
    final success = await _managerApi.assignTarget(
      employeeId: employeeId,
      type: type,
      targetCount: targetCount,
      targetDescription: targetDescription,
      startDate: startDate,
      endDate: endDate,
    );
    isLoading.value = false;
    
    if (success) {
      Get.snackbar('Success', 'Target assigned successfully', snackPosition: SnackPosition.BOTTOM);
      fetchEmployeeData(employeeId); // Refresh targets
    } else {
      Get.snackbar('Error', 'Failed to assign target', snackPosition: SnackPosition.BOTTOM);
    }
    return success;
  }

  Future<bool> updateTarget({
    required int employeeId,
    required int targetId,
    required String type,
    required int targetCount,
    required String targetDescription,
  }) async {
    isLoading.value = true;
    final success = await _managerApi.updateTarget(
      targetId: targetId,
      type: type,
      targetCount: targetCount,
      targetDescription: targetDescription,
    );
    isLoading.value = false;
    
    if (success) {
      Get.snackbar('Success', 'Target updated successfully', snackPosition: SnackPosition.BOTTOM);
      fetchEmployeeData(employeeId); // Refresh targets
    } else {
      Get.snackbar('Error', 'Failed to update target', snackPosition: SnackPosition.BOTTOM);
    }
    return success;
  }

  Future<bool> deleteTarget({
    required int employeeId,
    required int targetId,
  }) async {
    isLoading.value = true;
    final success = await _managerApi.deleteTarget(targetId);
    isLoading.value = false;
    
    if (success) {
      Get.snackbar('Success', 'Target deleted successfully', snackPosition: SnackPosition.BOTTOM);
      fetchEmployeeData(employeeId); // Refresh targets
    } else {
      Get.snackbar('Error', 'Failed to delete target', snackPosition: SnackPosition.BOTTOM);
    }
    return success;
  }
}
