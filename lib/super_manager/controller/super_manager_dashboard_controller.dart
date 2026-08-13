import 'package:get/get.dart';
import 'package:partener_app/models/user_model.dart';
import 'package:partener_app/super_manager/repo/super_manager_api_service.dart';

class SuperManagerDashboardController extends GetxController {
  final SuperManagerApiService _apiService = SuperManagerApiService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var managers = <UserModel>[].obs;
  var employees = <UserModel>[].obs;

  // Search & Navigation tab states
  var currentTab = 0.obs; // 0 = Managers, 1 = Employees
  var searchQuery = ''.obs;

  // Cache for employee manager names
  var employeeManagers = <int, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      await Future.wait([
        fetchAllManagers(),
        fetchAllEmployees(),
      ]);
    } catch (e) {
      errorMessage.value = "Failed to load dashboard data.";
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllManagers() async {
    try {
      final dataList = await _apiService.getAllManagers();
      managers.value = dataList
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error loading managers: $e");
    }
  }

  Future<void> fetchAllEmployees() async {
    try {
      final dataList = await _apiService.getAllEmployees();
      employees.value = dataList
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();

      // Pre-load manager info for each employee
      for (var emp in employees) {
        if (emp.id != null) {
          fetchEmployeeManagerName(emp.id!);
        }
      }
    } catch (e) {
      print("Error loading employees: $e");
    }
  }

  Future<void> fetchEmployeeManagerName(int employeeId) async {
    if (employeeManagers.containsKey(employeeId)) return;
    try {
      final mgr = await _apiService.getEmployeeManager(employeeId);
      if (mgr != null && mgr['name'] != null) {
        employeeManagers[employeeId] = mgr['name'].toString();
      } else {
        employeeManagers[employeeId] = "No Manager";
      }
    } catch (e) {
      employeeManagers[employeeId] = "No Manager";
    }
  }

  List<UserModel> get filteredManagers {
    if (searchQuery.isEmpty) return managers;
    final query = searchQuery.value.toLowerCase();
    return managers.where((m) {
      final name = m.name?.toLowerCase() ?? '';
      final phone = m.mobileNo?.toLowerCase() ?? '';
      final email = m.email?.toLowerCase() ?? '';
      final idStr = m.id?.toString() ?? '';
      return name.contains(query) || phone.contains(query) || email.contains(query) || idStr.contains(query);
    }).toList();
  }

  List<UserModel> get filteredEmployees {
    if (searchQuery.isEmpty) return employees;
    final query = searchQuery.value.toLowerCase();
    return employees.where((e) {
      final name = e.name?.toLowerCase() ?? '';
      final phone = e.mobileNo?.toLowerCase() ?? '';
      final idStr = e.id?.toString() ?? '';
      final managerName = (employeeManagers[e.id] ?? '').toLowerCase();
      return name.contains(query) || phone.contains(query) || idStr.contains(query) || managerName.contains(query);
    }).toList();
  }

  Future<bool> reassignEmployeeManager(int employeeId, int managerId) async {
    isLoading.value = true;
    try {
      final success = await _apiService.assignManager(employeeId: employeeId, managerId: managerId);
      if (success) {
        // Clear cache and fetch again to update list
        employeeManagers.remove(employeeId);
        await fetchEmployeeManagerName(employeeId);
        Get.snackbar("Success", "Manager reassigned successfully", snackPosition: SnackPosition.BOTTOM);
        return true;
      } else {
        Get.snackbar("Error", "Failed to reassign manager", snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "An unexpected error occurred", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
    return false;
  }
}
