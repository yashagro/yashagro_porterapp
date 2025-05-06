import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:partener_app/expert/work_diary/controller/work_diary_controller.dart';
import 'package:partener_app/expert/work_diary/model/workD_darie_model.dart';

class WorkDiaryTableWidget extends StatelessWidget {
  final int plotId;
  final int userId;
  final String plotName;

  WorkDiaryTableWidget({
    required this.plotId,
    required this.userId,
    required this.plotName,
  }) {
    final WorkDiaryController controller = Get.put(WorkDiaryController());
    controller.fetchWorkDiaries(userId, plotId);
  }

  @override
  Widget build(BuildContext context) {
    final WorkDiaryController controller = Get.find<WorkDiaryController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      } else if (controller.hasError.value || controller.workDiaries.isEmpty) {
        return const Center(child: Text("No work diary entries found."));
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Text(
              'Plot: ${plotName}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 10),
            _buildWorkDiaryTable(context, controller.workDiaries),
          ],
        );
      }
    });
  }

  Widget _buildWorkDiaryTable(
    BuildContext context,
    List<WorkDiarieModel> diaries,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        showCheckboxColumn: false, // ✅ Removes checkbox
        headingRowColor: MaterialStateColor.resolveWith(
          (states) => Colors.green.shade100,
        ),
        columns: const [
          DataColumn(
            label: Text("Day", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text(
              "Activity",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          DataColumn(
            label: Text(
              "Status",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
        rows:
            diaries.reversed.map((entry) {
              return DataRow(
                cells: [
                  DataCell(Text("Day ${entry.day ?? '-'}")),
                  DataCell(
                    SizedBox(
                      width: 150,
                      child: Text(
                        entry.activity != null && entry.activity!.length > 100
                            ? "${entry.activity!.substring(0, 100)}..."
                            : (entry.activity ?? "No scheduled activity"),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    onTap: () => _showDetailedDialog(context, entry),
                  ),
                  DataCell(
                    Text(
                      entry.status ?? "UNKNOWN",
                      style: TextStyle(
                        color:
                            (entry.status ?? "").toUpperCase() == "COMPLETED"
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                  ),
                ],
                onSelectChanged: null, // ✅ Disable selection
              );
            }).toList(),
      ),
    );
  }

  void _showDetailedDialog(BuildContext context, WorkDiarieModel entry) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("Diary Entry - Day ${entry.day ?? '-'}"),
            backgroundColor: Color(0xFFFAF9F6),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow("Activity", entry.activity ?? "-"),
                  const SizedBox(height: 10),
                  _detailRow("Status", entry.status ?? "-"),
                  const SizedBox(height: 10),
                  _detailRow("Date & Time", _formatIndianDateTime(entry.date)),
                  const SizedBox(height: 10),

                  const SizedBox(height: 10),
                  _detailRow("Feedback", entry.feedback ?? "-"),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: const Text("Close"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }

  String _formatIndianDateTime(String? dateStr) {
    if (dateStr == null) return "N/A";
    try {
      DateTime utcTime = DateTime.parse(dateStr).toUtc();
      // Convert to Indian Standard Time (UTC+5:30)
      DateTime istTime = utcTime.add(const Duration(hours: 5, minutes: 30));
      return "${DateFormat('dd-MM-yyyy hh:mm a').format(istTime)}";
    } catch (e) {
      return "Invalid Date";
    }
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }
}
