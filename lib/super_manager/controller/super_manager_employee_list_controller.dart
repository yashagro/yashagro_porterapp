import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/managers/repo/manager_api_service.dart';
import 'package:partener_app/models/user_model.dart';

class SuperManagerEmployeeListController extends GetxController {
  final ManagerApiService _managerApi = ManagerApiService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var employees = <UserModel>[].obs;

  final int managerId;

  SuperManagerEmployeeListController({required this.managerId});

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final dataList = await _managerApi.getManagerEmployees(managerId);
      employees.value =
          dataList
              .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
              .toList();
    } catch (e) {
      errorMessage.value = "Failed to load employees for this manager.";
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
