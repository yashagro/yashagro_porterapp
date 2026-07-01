import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:partener_app/marketer/controller/marketer_dashboard_controller.dart';
import 'package:partener_app/marketer/model/marketer_route_history_model.dart';
import 'package:partener_app/marketer/view/marketer_month_summary_screen.dart';
import 'package:partener_app/marketer/view/marketer_today_summary_screen.dart';

class MarketerMapScreen extends StatelessWidget {
  const MarketerMapScreen({super.key});

  static const LatLng _defaultCenter = LatLng(20.5937, 78.9629);

  @override
  Widget build(BuildContext context) {
    final dashboardController =
        Get.isRegistered<MarketerDashboardController>()
            ? Get.find<MarketerDashboardController>()
            : Get.put(MarketerDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        title: const Text(
          'Route History',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFF4F7F1),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const MarketerTodaySummaryScreen()),
            icon: const Icon(Icons.today, color: Colors.black87),
            tooltip: 'View today summary',
          ),
          IconButton(
            onPressed: () => Get.to(() => const MarketerMonthSummaryScreen()),
            icon: const Icon(Icons.bar_chart, color: Colors.black87),
            tooltip: 'View month summary',
          ),
          // IconButton(
          //   onPressed: () async {
          //     final selectedDate = await showDatePicker(
          //       context: context,
          //       initialDate: dashboardController.selectedHistoryDate.value,
          //       firstDate: DateTime(2020),
          //       lastDate: DateTime.now().add(const Duration(days: 365)),
          //     );

          //     if (selectedDate != null) {
          //       await dashboardController.fetchRouteHistoryForDate(
          //         selectedDate,
          //       );
          //     }
          //   },
          //   icon: const Icon(Icons.history, color: Colors.black87),
          //   tooltip: 'Select history date',
          // ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Obx(() {
          final dashboard = dashboardController.dashboard.value;
          final routeHistory = dashboardController.routeHistory;
          final selectedIndex = dashboardController.selectedRouteIndex.value;
          final selectedPoint =
              selectedIndex >= 0 && selectedIndex < routeHistory.length
                  ? routeHistory[selectedIndex]
                  : null;
          final locationPoint =
              selectedPoint?.latLng ??
              dashboard?.currentLatLng ??
              _defaultCenter;
          final isLoading =
              dashboardController.isLoading.value && dashboard == null;

          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: dashboardController.fetchDashboard,
            color: Colors.green.shade700,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                dashboardController.user.value?.name ??
                                    'Marketer Tracking',
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
                                'History Mode',
                                style: TextStyle(
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.42,
                          child: Stack(
                            children: [
                              FlutterMap(
                                key: ValueKey(
                                  '${dashboardController.selectedHistoryDate.value.toIso8601String()}-$selectedIndex-${locationPoint.latitude}-${locationPoint.longitude}',
                                ),
                                options: MapOptions(
                                  initialCenter: locationPoint,
                                  initialZoom:
                                      routeHistory.isNotEmpty ? 15.5 : 5.2,
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName:
                                        'com.example.partener_app',
                                  ),
                                  MarkerLayer(
                                    markers: _buildMarkers(
                                      dashboard: dashboard,
                                      routeHistory: routeHistory,
                                      selectedPoint: selectedPoint,
                                      locationPoint: locationPoint,
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                left: 14,
                                right: 14,
                                bottom: 14,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Wrap(
                                    spacing: 12,
                                    runSpacing: 8,
                                    children: [
                                      _legendDot(
                                        color: Colors.green,
                                        label: 'Active',
                                      ),
                                      _legendDot(
                                        color: Colors.orange,
                                        label: 'Start',
                                      ),
                                      _legendDot(
                                        color: Colors.red,
                                        label: 'End',
                                      ),
                                      _legendDot(
                                        color: Colors.blue,
                                        label: 'Selected',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildHistoryPanel(
                        context: context,
                        controller: dashboardController,
                        dashboard: dashboard,
                        routeHistory: routeHistory,
                        selectedPoint: selectedPoint,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  List<Marker> _buildMarkers({
    required List<MarketerRouteHistoryModel> routeHistory,
    required MarketerRouteHistoryModel? selectedPoint,
    required LatLng locationPoint,
    required dynamic dashboard,
  }) {
    if (routeHistory.isEmpty) {
      return [
        Marker(
          point: locationPoint,
          width: 96,
          height: 86,
          child: _markerBadge(
            label: dashboard?.formattedStatus ?? 'Location',
            color: Colors.green,
            iconColor: Colors.red,
          ),
        ),
      ];
    }

    final markers = <Marker>[];
    final firstPoint = routeHistory.first.latLng;
    final lastPoint = routeHistory.last.latLng;
    final selectedLatLng = selectedPoint?.latLng;

    if (firstPoint != null) {
      markers.add(
        Marker(
          point: firstPoint,
          width: 90,
          height: 82,
          child: _markerBadge(
            label: 'Start',
            color: Colors.orange,
            iconColor: Colors.orange,
          ),
        ),
      );
    }

    if (selectedLatLng != null) {
      markers.add(
        Marker(
          point: selectedLatLng,
          width: 90,
          height: 82,
          child: _markerBadge(
            label: 'Selected',
            color: Colors.blue,
            iconColor: Colors.blue,
          ),
        ),
      );
    }

    if (lastPoint != null) {
      markers.add(
        Marker(
          point: lastPoint,
          width: 90,
          height: 82,
          child: _markerBadge(
            label: 'End',
            color: Colors.blue,
            iconColor: Colors.red,
          ),
        ),
      );
    }

    return markers;
  }

  Widget _buildHistoryPanel({
    required BuildContext context,
    required MarketerDashboardController controller,
    required dynamic dashboard,
    required List<MarketerRouteHistoryModel> routeHistory,
    required MarketerRouteHistoryModel? selectedPoint,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Colors.green.shade100,
                child: Text(
                  (controller.user.value?.name?.trim().isNotEmpty ?? false)
                      ? controller.user.value!.name!.trim()[0].toUpperCase()
                      : 'M',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.user.value?.name ?? 'Marketer',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'ID: ${controller.user.value?.id ?? '-'}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  dashboard?.formattedStatus ?? 'Unknown',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: controller.selectedHistoryDate.value,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );

              if (selectedDate != null) {
                await controller.fetchRouteHistoryForDate(selectedDate);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      DateFormat(
                        'dd/MM/yyyy',
                      ).format(controller.selectedHistoryDate.value),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.calendar_month_outlined),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _metricChip(
                  title: 'Working',
                  value: _formatHours(dashboard?.workingMinutes ?? 0),
                  color: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _metricChip(
                  title: 'Travel',
                  value: _formatHours(dashboard?.travelMinutes ?? 0),
                  color: const Color(0xFFF57C00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _sessionCard(
            title: 'Login Time',
            time:
                routeHistory.isNotEmpty
                    ? _formatRecordedAt(routeHistory.first.recordedAt)
                    : 'Not available',
            subtitle:
                routeHistory.isNotEmpty
                    ? routeHistory.first.location
                    : 'No location history',
          ),
          const SizedBox(height: 10),
          _sessionCard(
            title: 'Logout Time',
            time:
                routeHistory.isNotEmpty
                    ? _formatRecordedAt(routeHistory.last.recordedAt)
                    : 'Not available',
            subtitle:
                routeHistory.isNotEmpty
                    ? routeHistory.last.location
                    : 'No location history',
          ),
          const SizedBox(height: 16),
          Text(
            'Session Timeline',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 10),
          if (routeHistory.isNotEmpty)
            Text(
              '${routeHistory.length} location points',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          if (routeHistory.isNotEmpty) const SizedBox(height: 10),
          routeHistory.isEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No location points found',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              )
              : RepaintBoundary(
                child: Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: routeHistory.length,
                    cacheExtent: 300,
                    itemBuilder: (context, index) {
                      final item = routeHistory[index];
                      final isSelected = identical(item, selectedPoint);
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => controller.selectRoutePoint(index),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.blue.shade50 : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? Colors.blue.shade200
                                      : Colors.black12,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                margin: const EdgeInsets.only(top: 6),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected ? Colors.blue : Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Location Pin #${index + 1}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      'Coords: ${item.location}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      'Battery: ${item.batteryPercentage}% • ${_formatRecordedAt(item.recordedAt)}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _markerBadge({
    required String label,
    required Color color,
    required Color iconColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Icon(Icons.location_on, color: iconColor, size: 36),
      ],
    );
  }

  Widget _legendDot({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _metricChip({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _sessionCard({
    required String title,
    required String time,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(time, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatHours(int totalMinutes) {
    if (totalMinutes <= 0) return '0h 0m';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String _formatRecordedAt(String value) {
    if (value.isEmpty) return 'Not available';
    try {
      return DateFormat('hh:mm a').format(DateTime.parse(value).toLocal());
    } catch (_) {
      return value;
    }
  }
}
