import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:partener_app/expert/lab_report/controller/lab_report_controller.dart';
import 'package:intl/intl.dart';


class LabReportListWidget extends StatelessWidget {
  final int plotId;
  final LabReportController controller = Get.put(LabReportController());

  LabReportListWidget({super.key, required this.plotId}) {
    controller.getLabReports(plotId.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      } else if (controller.labReports.isEmpty) {
        return const Center(child: Text("No lab reports available"));
      } else {
        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.labReports.length,
          itemBuilder: (context, index) {
            final report = controller.labReports[index];
            return GestureDetector(
              onTap:
                  () => _viewPdf(
                    report.fileUrl ?? "",
                    report.title ?? "lab_report",
                  ),
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow(Icons.description, "Title", report.title),
                      _buildRow(Icons.category, "Type", report.type),
                      _buildRow(
                        Icons.timer,
                        "Expiry",
                        _formatDate(report.expiry),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      }
    });
  }

  Widget _buildRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade700, size: 20),
          const SizedBox(width: 8),
          Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value?.toString() ?? "N/A",
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return "N/A";
    try {
      final date = DateTime.parse(isoDate);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (_) {
      return "Invalid date";
    }
  }

  Future<void> _viewPdf(String url, String title) async {
    if (url.isEmpty) {
      Get.snackbar("Error", "Invalid PDF URL");
      return;
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/$title.pdf';

      debugPrint('🧾 Downloading PDF from: $url');
      debugPrint('📁 Saving to path: $path');

      final dio = Dio();
      final response = await dio.download(url, path);
      debugPrint('✅ Download completed: ${response.statusCode}');

      final result = await OpenFile.open(path);
      debugPrint('📄 OpenFile result: ${result.message}');

      if (result.type != ResultType.done) {
        Get.snackbar(
          "Error",
          "Could not open PDF. Please install a PDF viewer.",
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ PDF Open Failed: $e');
      debugPrint(stackTrace.toString());
      Get.snackbar("Error", "Failed to open PDF");
    }
  }
}
