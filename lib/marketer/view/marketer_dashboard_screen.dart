import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:partener_app/expert/employee_tracking/controller/employee_tracking_controller.dart';
import 'package:partener_app/marketer/controller/marketer_dashboard_controller.dart';
import 'package:partener_app/marketer/model/marketer_dashboard_model.dart';
import 'package:partener_app/marketer/model/marketer_month_summary_model.dart';
import 'package:partener_app/marketer/model/marketer_today_summary_model.dart';
import 'package:partener_app/marketer/view/marketer_mark_visit_screen.dart';

class MarketerDashboardScreen extends StatelessWidget {
  const MarketerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trackingController = Get.find<EmployeeTrackingController>();
    final dashboardController = Get.put(MarketerDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F1),
        elevation: 0,
        title: Obx(() {
          final name = dashboardController.user.value?.name?.trim();
          return Text(
            name != null && name.isNotEmpty ? 'Welcome $name' : 'Welcome',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w700,
            ),
          );
        }),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Obx(() {
              final isWorking = trackingController.isWorking.value;
              final isTrackingLoading = trackingController.isLoading.value;
              final isInitialStatusLoading =
                  trackingController.isInitialStatusLoading.value;

              if (isInitialStatusLoading) {
                return const SizedBox(
                  width: 44,
                  height: 44,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              return TextButton.icon(
                onPressed:
                    isTrackingLoading
                        ? null
                        : () async {
                          await trackingController.toggleWorkStatus();
                          await dashboardController.fetchDashboard();
                        },
                style: TextButton.styleFrom(
                  backgroundColor:
                      isWorking ? Colors.red.shade600 : Colors.green.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon:
                    isTrackingLoading
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Icon(
                          isWorking
                              ? Icons.stop_circle_outlined
                              : Icons.play_circle_outline,
                          size: 18,
                        ),
                label: Text(isWorking ? 'Stop' : 'Start'),
              );
            }),
          ),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          final dashboard = dashboardController.dashboard.value;
          final monthSummary = dashboardController.monthSummary.value;
          final todaySummary = dashboardController.todaySummary;
          final myTargets = dashboardController.myTargets;
          final isDashboardLoading = dashboardController.isLoading.value;
          final errorMessage = dashboardController.errorMessage.value;
          final isWorking = trackingController.isWorking.value;
          final isInitialStatusLoading =
              trackingController.isInitialStatusLoading.value;

          if (isDashboardLoading && dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (isInitialStatusLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              IgnorePointer(
                ignoring: !isWorking,
                child: RefreshIndicator(
                  onRefresh: dashboardController.fetchDashboard,
                  color: Colors.green.shade700,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      if (errorMessage.isNotEmpty && dashboard == null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _InfoCard(
                            icon: Icons.error_outline,
                            title: 'Dashboard unavailable',
                            description: errorMessage,
                          ),
                        ),
                      //     _buildTodayTimeCard(dashboard),
                      const SizedBox(height: 18),
                      _buildTimeGraph(dashboard),
                      const SizedBox(height: 18),
                      _buildMonthSummary(monthSummary, dashboard),
                      const SizedBox(height: 18),
                      _buildTodayVisitsChart(todaySummary),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
              if (!isWorking)
                Positioned.fill(
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                      child: Container(
                        color: Colors.white.withValues(alpha: 0.18),
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  color: Colors.green.shade700,
                                  size: 30,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Start work to unlock dashboard',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'All dashboard data is blurred until work starts. Use the Start button in the app bar.',
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    height: 1.45,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: 'myTargetsFab',
            onPressed:
                () => _showMyTargetsBottomSheet(
                  context,
                  dashboardController.myTargets,
                ),
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.track_changes),
            label: const Text(
              'My Targets',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'markVisitFab',
            onPressed: () {
              Get.to(() => const MarketerMarkVisitScreen());
            },
            backgroundColor: Colors.green.shade700,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add_location_alt),
            label: const Text(
              'Mark Visit',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGraph(MarketerDashboardModel? dashboard) {
    final totalMinutes =
        (dashboard?.travelMinutes ?? 0) + (dashboard?.visitMinutes ?? 0);
    final metrics = [
      _TimeMetric(
        label: 'Total Hours',
        minutes: totalMinutes,
        color: const Color(0xFF1565C0),
      ),
      _TimeMetric(
        label: 'Working Hours',
        minutes: dashboard?.workingMinutes ?? 0,
        color: const Color(0xFFF57C00),
      ),
      _TimeMetric(
        label: 'Travel Hours',
        minutes: dashboard?.travelMinutes ?? 0,
        color: const Color(0xFF2E7D32),
      ),
    ];

    final maxMinutes = metrics
        .map((metric) => metric.minutes)
        .fold<int>(1, (max, value) => value > max ? value : max);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today time graph',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children:
                  metrics
                      .map(
                        (metric) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  _formatMinutes(metric.minutes),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  height:
                                      26 +
                                      ((metric.minutes / maxMinutes) * 120),
                                  decoration: BoxDecoration(
                                    color: metric.color,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  metric.label,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSummary(
    MarketerMonthSummaryModel? monthSummary,
    MarketerDashboardModel? dashboard,
  ) {
    final totalMinutes =
        (monthSummary?.totalTravelMinutes ?? 0) +
        (monthSummary?.totalVisitMinutes ?? 0);
    final items = [
      _SummaryItem(label: 'Total Hours', value: _formatMinutes(totalMinutes)),
      _SummaryItem(
        label: 'Working Hours',
        value: _formatMinutes(dashboard?.workingMinutes ?? 0),
      ),
      _SummaryItem(
        label: 'Travel Hours',
        value: _formatMinutes(monthSummary?.totalTravelMinutes ?? 0),
      ),
      _SummaryItem(
        label: 'Visit Hours',
        value: _formatMinutes(monthSummary?.totalVisitMinutes ?? 0),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hours summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7F1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.value,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodayVisitsChart(List<MarketerTodaySummaryModel> todaySummary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 18),
          if (todaySummary.isEmpty)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('No visit summary found for today.'),
            )
          else
            Column(
              children:
                  todaySummary
                      .map((item) => _TodaySummaryBar(item: item))
                      .toList(),
            ),
        ],
      ),
    );
  }

  void _showMyTargetsBottomSheet(BuildContext context, List<dynamic> targets) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My Targets',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child:
                    targets.isEmpty
                        ? Container(
                          padding: const EdgeInsets.all(18),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F7F1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'No targets assigned yet.',
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                        : ListView.builder(
                          itemCount: targets.length,
                          itemBuilder: (context, index) {
                            final target = targets[index];

                            // Determine icon and color based on type
                            final type =
                                target['type']?.toString().toLowerCase() ?? '';
                            IconData typeIcon = Icons.track_changes;
                            Color typeColor = Colors.blue.shade700;

                            if (type == 'farm') {
                              typeIcon = Icons.agriculture;
                              typeColor = Colors.green.shade700;
                            } else if (type == 'visit') {
                              typeIcon = Icons.directions_walk;
                              typeColor = Colors.orange.shade700;
                            } else if (type == 'sales') {
                              typeIcon = Icons.storefront;
                              typeColor = Colors.purple.shade700;
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                border: Border.all(color: Colors.grey.shade100),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: typeColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          typeIcon,
                                          color: typeColor,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              type.capitalizeFirst ??
                                                  'Unknown Type',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 18,
                                              ),
                                            ),
                                            if (target['target_description'] !=
                                                    null &&
                                                target['target_description']
                                                    .toString()
                                                    .isNotEmpty)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                child: Text(
                                                  target['target_description'],
                                                  style: TextStyle(
                                                    color: Colors.grey.shade600,
                                                    fontSize: 13,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: typeColor,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            const Text(
                                              'TARGET',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "${target['target_count'] ?? 0}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "Start: ${target['start_date'] ?? 'N/A'}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.event,
                                              size: 14,
                                              color: Colors.grey.shade600,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              "End: ${target['end_date'] ?? 'N/A'}",
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatMinutes(int totalMinutes) {
    if (totalMinutes <= 0) {
      return '0m';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) {
      return '${minutes}m';
    }
    if (minutes == 0) {
      return '${hours}h';
    }
    return '${hours}h ${minutes}m';
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.green.shade700),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySummaryBar extends StatelessWidget {
  final MarketerTodaySummaryModel item;

  const _TodaySummaryBar({required this.item});

  @override
  Widget build(BuildContext context) {
    final travelFlex =
        item.travelMinutes == 0 && item.visitMinutes == 0
            ? 1
            : (item.travelMinutes <= 0 ? 1 : item.travelMinutes);
    final visitFlex =
        item.travelMinutes == 0 && item.visitMinutes == 0
            ? 1
            : (item.visitMinutes <= 0 ? 1 : item.visitMinutes);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F7F1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Plot ${item.plotId} • ${item.formattedStatus}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                _formatScheduledAt(item.scheduledAt),
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Expanded(
                  flex: travelFlex,
                  child: Container(height: 12, color: const Color(0xFF2E7D32)),
                ),
                Expanded(
                  flex: visitFlex,
                  child: Container(height: 12, color: const Color(0xFF1565C0)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Travel: ${_formatMinutesStatic(item.travelMinutes)}',
                  style: TextStyle(color: Colors.grey.shade800),
                ),
              ),
              Expanded(
                child: Text(
                  'Visit: ${_formatMinutesStatic(item.visitMinutes)}',
                  style: TextStyle(color: Colors.grey.shade800),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatScheduledAt(String value) {
    if (value.isEmpty) return 'No time';
    try {
      return DateFormat(
        'dd MMM, hh:mm a',
      ).format(DateTime.parse(value).toLocal());
    } catch (_) {
      return value;
    }
  }

  static String _formatMinutesStatic(int totalMinutes) {
    if (totalMinutes <= 0) {
      return '0m';
    }
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) return '${minutes}m';
    if (minutes == 0) return '${hours}h';
    return '${hours}h ${minutes}m';
  }
}

class _TimeMetric {
  final String label;
  final int minutes;
  final Color color;

  const _TimeMetric({
    required this.label,
    required this.minutes,
    required this.color,
  });
}

class _SummaryItem {
  final String label;
  final String value;

  const _SummaryItem({required this.label, required this.value});
}
