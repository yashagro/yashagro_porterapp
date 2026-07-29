import 'package:get/get.dart';
import 'package:partener_app/models/user_model.dart';
import 'package:partener_app/super_manager/repo/super_manager_api_service.dart';

class SuperManagerDashboardController extends GetxController {
  final SuperManagerApiService _apiService = SuperManagerApiService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var managers = <UserModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllManagers();
  }

  Future<void> fetchAllManagers() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final dataList = await _apiService.getAllManagers();
      managers.value = dataList
          .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      errorMessage.value = "Failed to load managers.";
      print(e);
    } finally {
      isLoading.value = false;
    }
  }
}
