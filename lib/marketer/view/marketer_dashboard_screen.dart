import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/expert/employee_tracking/controller/employee_tracking_controller.dart';
import 'package:partener_app/marketer/controller/marketer_dashboard_controller.dart';
import 'package:partener_app/marketer/model/marketer_dashboard_model.dart';
import 'package:partener_app/marketer/model/marketer_month_summary_model.dart';
import 'package:partener_app/marketer/model/marketer_today_summary_model.dart';
import 'package:partener_app/marketer/view/marketer_mark_visit_screen.dart';
import 'package:partener_app/services/routing_service.dart';
import 'package:geolocator/geolocator.dart';

class MarketerDashboardScreen extends StatelessWidget {
  const MarketerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trackingController = Get.find<EmployeeTrackingController>();
    final dashboardController = Get.put(MarketerDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        title: Obx(() {
          final name = dashboardController.user.value?.name?.trim();
          return Text(
            name != null && name.isNotEmpty ? 'Welcome $name' : 'Welcome',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w900,
              fontSize: 20,
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

          return RefreshIndicator(
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
                _buildMotivationalTargets(context, dashboardController),
                const SizedBox(height: 18),
                _buildTodayRangeSummary(
                  context,
                  dashboardController.rangeSummary.value,
                ),
                const SizedBox(height: 18),
              ],
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'markVisitFab',
        onPressed: () {
          Get.to(() => const MarketerMarkVisitScreen());
        },
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 6,
        splashColor: Colors.green.withOpacity(0.4),
        icon: const Icon(Icons.add_location_alt_rounded, size: 24),
        label: const Text(
          'Mark Visit',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 0.5,
          ),
        ),
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
                                target['type']?.toString()?.toLowerCase() ?? '';
                            IconData typeIcon = Icons.track_changes;
                            Color typeColor = Colors.blue.shade700;

                            if (type == 'farm' || type == 'farm_visit') {
                              typeIcon = Icons.agriculture;
                              typeColor = Colors.green.shade700;
                            } else if (type == 'visit' ||
                                type == 'customer_visit' ||
                                type == 'store_visit' ||
                                type.contains('customer') ||
                                type.contains('store')) {
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

  Widget _buildMotivationalTargets(
    BuildContext context,
    MarketerDashboardController controller,
  ) {
    int targetFarm = 0;
    int completedFarm = 0;
    int targetStore = 0;
    int completedStore = 0;

    print("DEBUG UI: rangeSummary = ${controller.rangeSummary.value}");
    print("DEBUG UI: completedTargets = ${controller.completedTargets.value}");
    print("DEBUG UI: myTargets = ${controller.myTargets}");

    final summaryData = controller.rangeSummary.value;
    final targetsObj = summaryData != null ? summaryData['targets'] : null;

    if (targetsObj is Map &&
        (targetsObj.containsKey('FARM_VISIT') ||
            targetsObj.containsKey('STORE_VISIT') ||
            targetsObj.containsKey('CUSTOMER_VISIT'))) {
      print("DEBUG UI: Entered IF branch");
      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final farmList = targetsObj['FARM_VISIT'] as List<dynamic>? ?? [];
      final farmTargetForDay = farmList.firstWhereOrNull((t) {
        final dateRaw = t['date'];
        if (dateRaw == null) return false;
        try {
          final parsedDate = DateTime.parse(dateRaw.toString()).toLocal();
          return DateFormat('yyyy-MM-dd').format(parsedDate) == todayStr;
        } catch (e) {
          return dateRaw.toString().startsWith(todayStr);
        }
      });
      if (farmTargetForDay != null) {
        targetFarm = farmTargetForDay['count'] as int? ?? 0;
        completedFarm = farmTargetForDay['completed'] as int? ?? 0;
      }

      final storeList =
          (targetsObj['STORE_VISIT'] ?? targetsObj['CUSTOMER_VISIT'] ?? [])
              as List<dynamic>;
      final storeTargetForDay = storeList.firstWhereOrNull((t) {
        final dateRaw = t['date'];
        if (dateRaw == null) return false;
        try {
          final parsedDate = DateTime.parse(dateRaw.toString()).toLocal();
          return DateFormat('yyyy-MM-dd').format(parsedDate) == todayStr;
        } catch (e) {
          return dateRaw.toString().startsWith(todayStr);
        }
      });
      if (storeTargetForDay != null) {
        targetStore = storeTargetForDay['count'] as int? ?? 0;
        completedStore = storeTargetForDay['completed'] as int? ?? 0;
      }

      // Fallback to real-time completed targets response count if rangeSummary is outdated/zero
      final completedData = controller.completedTargets.value;
      final List<dynamic> visitsList =
          completedData != null && completedData['visits'] != null
              ? completedData['visits'] as List<dynamic>
              : (completedData != null &&
                      completedData['data'] != null &&
                      completedData['data']['visits'] != null
                  ? completedData['data']['visits'] as List<dynamic>
                  : []);
      final realTimeFarmCount =
          visitsList.where((v) => v['type'] == 'FARM_VISIT').length;
      final realTimeStoreCount =
          visitsList.where((v) => v['type'] == 'CUSTOMER_VISIT').length;
      if (completedFarm == 0 && realTimeFarmCount > 0)
        completedFarm = realTimeFarmCount;
      if (completedStore == 0 && realTimeStoreCount > 0)
        completedStore = realTimeStoreCount;

      print(
        "DEBUG UI: IF branch result - targetFarm: $targetFarm, completedFarm: $completedFarm, targetStore: $targetStore, completedStore: $completedStore",
      );
    } else {
      print("DEBUG UI: Entered ELSE branch");
      final targets = controller.myTargets;
      for (var t in targets) {
        final type = t['type']?.toString().toLowerCase() ?? '';
        final count = t['target_count'] as int? ?? 0;

        if (type == 'farm' || type == 'farm_visit') {
          targetFarm += count;
        } else if (type == 'visit' ||
            type == 'sales' ||
            type == 'customer_visit' ||
            type == 'store_visit' ||
            type.contains('customer') ||
            type.contains('store')) {
          targetStore += count;
        }
      }

      // Parse completed targets from the visits list in completedTargets response
      final completedData = controller.completedTargets.value;
      final List<dynamic> visitsList =
          completedData != null && completedData['visits'] != null
              ? completedData['visits'] as List<dynamic>
              : (completedData != null &&
                      completedData['data'] != null &&
                      completedData['data']['visits'] != null
                  ? completedData['data']['visits'] as List<dynamic>
                  : []);

      completedFarm = visitsList.where((v) => v['type'] == 'FARM_VISIT').length;
      completedStore =
          visitsList.where((v) => v['type'] == 'CUSTOMER_VISIT').length;
      print(
        "DEBUG UI: ELSE branch result - visitsList length: ${visitsList.length}, targetFarm: $targetFarm, completedFarm: $completedFarm, targetStore: $targetStore, completedStore: $completedStore",
      );
    }

    // Calculate percentages
    final farmProgress =
        targetFarm > 0 ? (completedFarm / targetFarm).clamp(0.0, 1.0) : 1.0;
    final storeProgress =
        targetStore > 0 ? (completedStore / targetStore).clamp(0.0, 1.0) : 1.0;

    final totalTarget = targetFarm + targetStore;
    final totalCompleted = completedFarm + completedStore;
    final totalProgress =
        totalTarget > 0 ? (totalCompleted / totalTarget).clamp(0.0, 1.0) : 1.0;

    // Motivation Quote
    String quote =
        "🌟 Ready to conquer today? Start your first visit to unlock progress!";
    if (totalProgress > 0 && totalProgress < 0.5) {
      quote = "🚀 Great start! Keep pushing to reach your goals today!";
    } else if (totalProgress >= 0.5 && totalProgress < 1.0) {
      quote = "💪 You are more than halfway there! Keep it up!";
    } else if (totalProgress >= 1.0) {
      quote =
          "🎉 Outstanding! You have completed all targets for today! You're a superstar!";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade100.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Targets & Motivation",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Farm Visit Target
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.agriculture_rounded,
                  color: Colors.orange.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Farm Visits Target",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "$completedFarm / $targetFarm",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: farmProgress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade100,
                        color: Colors.orange.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Store Visit Target
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.storefront_rounded,
                  color: Colors.blue.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Store Visits Target",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          "$completedStore / $targetStore",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: storeProgress,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade100,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 12),

          // Motivational Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.green.shade100),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: Colors.green.shade700,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    quote,
                    style: TextStyle(
                      color: Colors.green.shade900,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayRangeSummary(
    BuildContext context,
    Map<String, dynamic>? rangeSummary,
  ) {
    if (rangeSummary == null) return const SizedBox.shrink();

    final dashboardController = Get.find<MarketerDashboardController>();
    final workSession = rangeSummary['work_session'];
    final travelMeter = rangeSummary['travel_meter'] ?? 0;
    final startMeter =
        workSession != null ? workSession['start_work_meter'] ?? 'N/A' : 'N/A';
    final endMeter =
        workSession != null ? workSession['end_work_meter'] ?? 'N/A' : 'N/A';

    final status =
        workSession != null ? workSession['status'] ?? 'INACTIVE' : 'INACTIVE';

    // Parse route coordinates from locations list
    final List<LatLng> routePoints = [];
    final locations = rangeSummary['locations'] as List<dynamic>? ?? [];

    // Sort locations chronologically
    final sortedLocations = List<dynamic>.from(locations);
    sortedLocations.sort((a, b) {
      final aTime =
          a['recorded_at']?.toString() ?? a['created_at']?.toString() ?? '';
      final bTime =
          b['recorded_at']?.toString() ?? b['created_at']?.toString() ?? '';
      return aTime.compareTo(bTime);
    });

    for (var loc in sortedLocations) {
      final locStr = loc['location'] as String?;
      if (locStr != null) {
        final accuracyVal = loc['accuracy'];
        final accuracy = double.tryParse(accuracyVal?.toString() ?? '') ?? 0.0;
        if (accuracy > 100) {
          continue; // skip highly inaccurate points that cause jitter
        }
        final parts = locStr.split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0].trim());
          final lon = double.tryParse(parts[1].trim());
          if (lat != null && lon != null) {
            routePoints.add(LatLng(lat, lon));
          }
        }
      }
    }

    final LatLng mapCenter =
        routePoints.isNotEmpty
            ? routePoints.last
            : const LatLng(20.5937, 78.9629);

    // Parse start/end images
    final startImages =
        workSession != null
            ? workSession['start_work_images'] as List<dynamic>? ?? []
            : [];
    final endImages =
        workSession != null
            ? workSession['end_work_images'] as List<dynamic>? ?? []
            : [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Range Summary Details",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryStatItem(
                title: "Travel Distance",
                value: "$travelMeter km",
                color: Colors.deepPurple,
                icon: Icons.alt_route_rounded,
              ),
              _SummaryStatItem(
                title: "Odometer Start",
                value: "$startMeter",
                color: Colors.teal,
                icon: Icons.speed_rounded,
              ),
              _SummaryStatItem(
                title: "Odometer End",
                value: "$endMeter",
                color: Colors.indigo,
                icon: Icons.flag_rounded,
              ),
            ],
          ),

          // Map Section (Route History plotted)
          const SizedBox(height: 20),
          const Text(
            "Today's Route Map",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 220,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  FlutterMap(
                    key: ValueKey('dashboard-route-map-${routePoints.length}'),
                    mapController: dashboardController.dashboardMapController,
                    options: MapOptions(
                      initialCenter: mapCenter,
                      initialZoom: routePoints.isNotEmpty ? 15.0 : 5.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.partener_app',
                      ),
                      if (routePoints.isNotEmpty) ...[
                        RoadPolylineLayer(
                          rawPoints: routePoints,
                          color: Colors.blue.shade700,
                          strokeWidth: 4.5,
                        ),
                        MarkerLayer(
                          markers: [
                            // Start point marker
                            Marker(
                              point: routePoints.first,
                              width: 30,
                              height: 30,
                              child: const Icon(
                                Icons.trip_origin_rounded,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                            // Current location marker
                            Marker(
                              point: routePoints.last,
                              width: 40,
                              height: 40,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.circle,
                                    color: Colors.blue,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  if (routePoints.isNotEmpty)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.map_rounded,
                            color: Colors.blue,
                          ),
                          tooltip: "Open in Google Maps",
                          onPressed:
                              () => RoutingService.launchGoogleMapsRoute(
                                routePoints,
                              ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: routePoints.isNotEmpty ? 60 : 12,
                    right: 12,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: IconButton(
                          icon: const Icon(
                            Icons.my_location_rounded,
                            color: Colors.blue,
                          ),
                          tooltip: "My Location",
                          onPressed: () async {
                            try {
                              bool serviceEnabled =
                                  await Geolocator.isLocationServiceEnabled();
                              if (!serviceEnabled) return;
                              LocationPermission permission =
                                  await Geolocator.checkPermission();
                              if (permission == LocationPermission.denied) {
                                permission =
                                    await Geolocator.requestPermission();
                                if (permission == LocationPermission.denied)
                                  return;
                              }
                              if (permission ==
                                  LocationPermission.deniedForever)
                                return;
                              Position pos =
                                  await Geolocator.getCurrentPosition(
                                    locationSettings: const LocationSettings(
                                      accuracy: LocationAccuracy.high,
                                    ),
                                  );
                              dashboardController.dashboardMapController.move(
                                LatLng(pos.latitude, pos.longitude),
                                15.0,
                              );
                            } catch (e) {
                              debugPrint("Error fetching location: $e");
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Work Images (Start/End Work Session)
          if (startImages.isNotEmpty || endImages.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Text(
              "Session Odometer Photos",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                if (startImages.isNotEmpty)
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              '${ApiRoutes.baseUri}${startImages.first['url']}',
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    height: 100,
                                    color: Colors.grey.shade100,
                                    child: const Icon(
                                      Icons.broken_image_rounded,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Text(
                              "Start Reading Photo",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (startImages.isNotEmpty && endImages.isNotEmpty)
                  const SizedBox(width: 12),
                if (endImages.isNotEmpty)
                  Expanded(
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              '${ApiRoutes.baseUri}${endImages.first['url']}',
                              height: 100,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                    height: 100,
                                    color: Colors.grey.shade100,
                                    child: const Icon(
                                      Icons.broken_image_rounded,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            child: Text(
                              "End Reading Photo",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],

          if (workSession != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Status:$status",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                if (workSession['start_time'] != null)
                  Text(
                    "Started: ${DateFormat('hh:mm a').format(DateTime.parse(workSession['start_time']).toLocal())}",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryStatItem extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryStatItem({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
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
