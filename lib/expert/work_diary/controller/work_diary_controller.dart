import 'package:get/get.dart';
import 'package:partener_app/expert/farmer_details/model/farmer_plot_model.dart';
import 'package:partener_app/expert/work_diary/model/workD_darie_model.dart';
import 'package:partener_app/expert/work_diary/repo/work_diary_service.dart';

class WorkDiaryController extends GetxController {
  final WorkDiaryService _service = WorkDiaryService();

  final RxList<WorkDiarieModel> workDiaries = <WorkDiarieModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final Rx<FarmerPlotModel?> plot = Rx<FarmerPlotModel?>(null);

  /// Load Work Diaries
  Future<void> fetchWorkDiaries(int userId, int plotId) async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final data = await _service.fetchWorkDiaries(userId, plotId);
      workDiaries.assignAll(data);
    } catch (e) {
      print("❌ Error fetching diaries: $e");
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load Plot Details
  Future<void> fetchPlotDetails(int plotId) async {
    try {
      final data = await _service.fetchPlotDetails(plotId);
      plot.value = data;
    } catch (e) {
      print("❌ Error fetching plot: $e");
      plot.value = null;
    }
  }
}
