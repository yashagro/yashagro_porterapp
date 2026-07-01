import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/marketer/controller/marketer_dashboard_controller.dart';

class MarketerMonthSummaryScreen extends StatelessWidget {
  const MarketerMonthSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.isRegistered<MarketerDashboardController>()
            ? Get.find<MarketerDashboardController>()
            : Get.put(MarketerDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        title: const Text(
          'Month Summary',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF4F7F1),
        elevation: 0,
      ),
      body: Obx(() {
        final summary = controller.monthSummary.value;
        final isLoading = controller.isLoading.value && summary == null;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchDashboard,
          color: Colors.green.shade700,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              _MonthCard(
                title: 'Total Visits',
                value: '${summary?.totalVisits ?? 0}',
              ),
              _MonthCard(
                title: 'Completed Visits',
                value: '${summary?.completedVisits ?? 0}',
              ),
              _MonthCard(
                title: 'Travel Hours',
                value: _formatMinutes(summary?.totalTravelMinutes ?? 0),
              ),
              _MonthCard(
                title: 'Visit Hours',
                value: _formatMinutes(summary?.totalVisitMinutes ?? 0),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatMinutes(int totalMinutes) {
    if (totalMinutes <= 0) return '0m';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}

class _MonthCard extends StatelessWidget {
  final String title;
  final String value;

  const _MonthCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
