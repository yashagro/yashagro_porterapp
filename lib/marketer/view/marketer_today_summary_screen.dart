import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:partener_app/marketer/controller/marketer_dashboard_controller.dart';
import 'package:partener_app/marketer/model/marketer_today_summary_model.dart';

class MarketerTodaySummaryScreen extends StatelessWidget {
  const MarketerTodaySummaryScreen({super.key});

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
          'Today Summary',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF4F7F1),
        elevation: 0,
      ),
      body: Obx(() {
        final items = controller.todaySummary;
        final isLoading = controller.isLoading.value && items.isEmpty;

        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchDashboard,
          color: Colors.green.shade700,
          child:
              items.isEmpty
                  ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: const [
                      SizedBox(height: 120),
                      Center(child: Text('No today summary found')),
                    ],
                  )
                  : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _TodaySummaryTile(item: item);
                    },
                  ),
        );
      }),
    );
  }
}

class _TodaySummaryTile extends StatelessWidget {
  final MarketerTodaySummaryModel item;

  const _TodaySummaryTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Plot ${item.plotId}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.formattedStatus,
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Scheduled: ${_formatDate(item.scheduledAt)}',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  title: 'Travel',
                  value: _formatMinutes(item.travelMinutes),
                  color: const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  title: 'Visit',
                  value: _formatMinutes(item.visitMinutes),
                  color: const Color(0xFF1565C0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatDate(String value) {
    if (value.isEmpty) return 'No time';
    try {
      return DateFormat(
        'dd MMM yyyy, hh:mm a',
      ).format(DateTime.parse(value).toLocal());
    } catch (_) {
      return value;
    }
  }

  static String _formatMinutes(int totalMinutes) {
    if (totalMinutes <= 0) return '0m';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MiniStat({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }
}
