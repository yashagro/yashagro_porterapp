import 'package:get/get.dart';
import 'package:partener_app/expert/lab_report/model/lab_report_model.dart';
import 'package:partener_app/expert/lab_report/repo/lab_report_repo.dart';
import 'dart:developer'; // for better logging

class LabReportController extends GetxController {
  final _repo = LabReportRepo();
  var isLoading = false.obs;
  var labReports = <Labreport>[].obs;

  Future<void> getLabReports(String plotId) async {
    log('[LabReportController] Fetching lab reports for plotId: $plotId');
    try {
      isLoading.value = true;

      final data = await _repo.fetchLabReports(plotId);
      print(   "data of lab report is $data"  );

      log('[LabReportController] Fetched ${data.length} reports');
      for (int i = 0; i < data.length; i++) {
        final report = data[i];
        log(
          'Report $i → Title: ${report.title}, Type: ${report.type}, Expiry: ${report.expiry}',
        );
      }

      labReports.assignAll(data);
    } catch (e, stackTrace) {
      log('[LabReportController] Error: $e', stackTrace: stackTrace);
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
