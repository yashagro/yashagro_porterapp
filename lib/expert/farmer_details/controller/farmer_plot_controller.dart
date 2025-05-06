import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/expert/farmer_details/model/farmer_plot_model.dart';
import 'package:partener_app/expert/farmer_details/repo/farmer_api_service.dart';

class FarmerPlotController extends GetxController {
  final FarmerApiService apiService = FarmerApiService();

  RxBool isLoading = true.obs;
  FarmerPlotModel? plotModel;

  RxMap<int, String> cropsMap = <int, String>{}.obs;
  RxMap<int, String> varietiesMap = <int, String>{}.obs;
  RxMap<int, String> pruningTypeMap = <int, String>{}.obs;
  RxMap<int, String> plantationTypeMap = <int, String>{}.obs;

  int? currentPlotId;

  /// Load full data
  Future<void> loadPlotDetails(int plotId) async {
    isLoading.value = true;
    currentPlotId = plotId;

    await Future.wait([
      _fetchCrops(),
      _fetchPruningTypes(),
      _fetchPlantationTypes(),
    ]);

    await _fetchFullPlot(plotId);

    isLoading.value = false;
  }

  Future<void> _fetchFullPlot(int plotId) async {
    final data = await apiService.fetchPlotFullDetails(
      plotId,
    ); // 🔥 USE NEW FUNCTION
    if (data != null) {
      plotModel = FarmerPlotModel.fromJson(data);

      // ✅ If Crop ID exists, fetch its varieties
      if (plotModel!.crop?.file != null)
        Image.network(plotModel!.crop?.file! ?? '');
    }
  }

  Future<void> _fetchCrops() async {
    final crops = await apiService.fetchCrops();
    if (crops != null) {
      cropsMap.assignAll(crops);
    }
  }

  Future<void> _fetchVarieties(int cropId) async {
    final varieties = await apiService.fetchCropVarieties(cropId);
    if (varieties != null) {
      varietiesMap.assignAll(varieties);
    }
  }

  Future<void> _fetchPruningTypes() async {
    final pruningTypes = await apiService.fetchPruningTypes();
    if (pruningTypes != null) {
      pruningTypeMap.assignAll(pruningTypes);
    }
  }

  Future<void> _fetchPlantationTypes() async {
    final plantationTypes = await apiService.fetchPlantationTypes();
    if (plantationTypes != null) {
      plantationTypeMap.assignAll(plantationTypes);
    }
  }

  /// Refresh entire data
  Future<void> refreshAll() async {
    if (currentPlotId != null) {
      await loadPlotDetails(currentPlotId!);
    }
  }
}
