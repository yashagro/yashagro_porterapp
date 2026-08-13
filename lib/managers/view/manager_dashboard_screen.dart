import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:partener_app/managers/controller/manager_dashboard_controller.dart';
import 'package:partener_app/models/user_model.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:partener_app/managers/view/manager_employee_details_screen.dart';
import 'package:partener_app/marketer/view/marketer_map_screen.dart';
import 'package:partener_app/utils/app_routes.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ManagerDashboardController());

    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F9), // A soft premium background
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F9F9),
        elevation: 0,
        title: Obx(() {
          final name = controller.managerProfile.value?.name?.trim();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome,',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                name != null && name.isNotEmpty ? name : 'Manager',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          );
        }),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.refresh, color: Colors.blue.shade700),
              onPressed: () => controller.fetchInitialData(),
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.employees.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage.value.isNotEmpty &&
              controller.employees.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchMyEmployees,
            color: Colors.blue.shade700,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                if (controller.managerProfile.value?.roleId == 9)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(AppRoutes.superManagerHome);
                      },
                      icon: const Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                      ),
                      label: const Text(
                        "Super Manager Section",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),

                // if (controller.managerProfile.value?.roleId == 8)
                Row(
                  children: [
                    Expanded(
                      child: SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: false,
                            icon: Icon(Icons.list),
                            label: Text('List'),
                          ),
                          ButtonSegment(
                            value: true,
                            icon: Icon(Icons.map),
                            label: Text('Map'),
                          ),
                        ],
                        selected: {controller.isMapView.value},
                        onSelectionChanged: (Set<bool> newSelection) {
                          controller.toggleMapView(newSelection.first);
                        },
                        style: SegmentedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // if (controller.managerProfile.value?.roleId == 8)
                if (controller.isMapView.value) ...[
                  _buildMapView(controller),
                  const SizedBox(height: 24),
                  if (controller.employees.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        "My Team Status",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    ...controller.employees
                        .map(
                          (emp) => _EmployeePremiumCard(
                            employee: emp,
                            controller: controller,
                          ),
                        )
                        .toList(),
                  ],
                ] else if (controller.employees.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.group_off,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No employees assigned to you yet.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...controller.employees
                      .map(
                        (emp) => _EmployeePremiumCard(
                          employee: emp,
                          controller: controller,
                        ),
                      )
                      .toList(),

                const SizedBox(height: 60), // Space for FAB
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMapView(ManagerDashboardController controller) {
    final rangeData = controller.selectedEmployeeRange.value;
    final List<LatLng> routePoints = [];
    final List<Map<String, dynamic>> visits = [];
    LatLng? selectedEmpLastLoc;

    if (controller.selectedEmployeeId.value != null &&
        controller.employeeLocations.containsKey(
          controller.selectedEmployeeId.value,
        )) {
      selectedEmpLastLoc =
          controller.employeeLocations[controller.selectedEmployeeId.value];
    }

    if (rangeData != null) {
      final locations = rangeData['locations'] as List<dynamic>? ?? [];
      for (var loc in locations) {
        final locStr = loc['location'] as String?;
        if (locStr != null) {
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
      final visitsData = rangeData['emp_visits'] as List<dynamic>? ?? [];
      for (var v in visitsData) {
        if (v is Map) {
          visits.add(Map<String, dynamic>.from(v));
        }
      }
    }

    final LatLng initialCenter =
        selectedEmpLastLoc ??
        (controller.employeeLocations.isNotEmpty
            ? controller.employeeLocations.values.first
            : const LatLng(20.5937, 78.9629));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 380,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: FlutterMap(
              options: MapOptions(
                initialCenter: initialCenter,
                initialZoom: selectedEmpLastLoc != null ? 13.0 : 5.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.yashagro.app',
                ),
                if (routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: routePoints,
                        color: Colors.blue.shade600,
                        strokeWidth: 4.5,
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    // Employee current/last active pins
                    ...controller.employeeLocations.entries.map((entry) {
                      final emp = controller.employees.firstWhereOrNull(
                        (e) => e.id == entry.key,
                      );
                      final statusData = controller.employeeStatuses[entry.key];
                      final workSession =
                          statusData != null
                              ? statusData['work_session']
                              : null;
                      final isOnline =
                          workSession != null &&
                          workSession['status'] == 'ACTIVE';

                      return Marker(
                        point: entry.value,
                        width: 70,
                        height: 55,
                        child: GestureDetector(
                          onTap:
                              () => controller.selectEmployeeOnMap(entry.key),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color:
                                      isOnline
                                          ? Colors.green.shade600
                                          : Colors.red.shade600,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isOnline
                                      ? Icons.directions_walk_rounded
                                      : Icons.location_off_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                              if (emp != null)
                                Container(
                                  margin: const EdgeInsets.only(top: 1),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    emp.name ?? '',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),

                    // Selected employee's visits pins
                    ...visits.map((v) {
                      final lat = double.tryParse(
                        v['latitude']?.toString() ?? '',
                      );
                      final lon = double.tryParse(
                        v['longitude']?.toString() ?? '',
                      );
                      if (lat == null || lon == null)
                        return const Marker(
                          point: LatLng(0, 0),
                          child: SizedBox.shrink(),
                        );

                      final isFarm = v['type'] == 'FARM_VISIT';

                      return Marker(
                        point: LatLng(lat, lon),
                        width: 32,
                        height: 32,
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                isFarm
                                    ? Colors.green.shade600
                                    : Colors.orange.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 3,
                              ),
                            ],
                          ),
                          child: Icon(
                            isFarm
                                ? Icons.agriculture_rounded
                                : Icons.storefront_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Range Details Panel for the selected employee
        if (controller.isRangeLoading.value)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.blue),
            ),
          )
        else if (controller.selectedEmployeeId.value != null)
          _buildSelectedEmployeeRangeDetails(controller),
      ],
    );
  }

  Widget _buildSelectedEmployeeRangeDetails(
    ManagerDashboardController controller,
  ) {
    final emp = controller.employees.firstWhereOrNull(
      (e) => e.id == controller.selectedEmployeeId.value,
    );
    if (emp == null) return const SizedBox.shrink();

    final rangeData = controller.selectedEmployeeRange.value;
    final workSession = rangeData != null ? rangeData['work_session'] : null;
    final travelMeter = rangeData != null ? rangeData['travel_meter'] ?? 0 : 0;
    final statusData = controller.employeeStatuses[emp.id];
    final liveSession = statusData != null ? statusData['work_session'] : null;
    final isOnline = liveSession != null && liveSession['status'] == 'ACTIVE';

    String loginTime = 'N/A';
    String logoutTime = 'N/A';
    if (workSession != null) {
      if (workSession['start_time'] != null) {
        loginTime = DateFormat(
          'hh:mm a',
        ).format(DateTime.parse(workSession['start_time']).toLocal());
      }
      if (workSession['end_time'] != null) {
        logoutTime = DateFormat(
          'hh:mm a',
        ).format(DateTime.parse(workSession['end_time']).toLocal());
      }
    }

    final visits =
        rangeData != null
            ? rangeData['emp_visits'] as List<dynamic>? ?? []
            : [];
    final farmCount = visits.where((v) => v['type'] == 'FARM_VISIT').length;
    final storeCount =
        visits.where((v) => v['type'] == 'CUSTOMER_VISIT').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Employee Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blue.shade50,
                backgroundImage:
                    (emp.image != null && emp.image!.isNotEmpty)
                        ? NetworkImage(emp.image!)
                        : null,
                child:
                    (emp.image == null || emp.image!.isEmpty)
                        ? Icon(Icons.person, color: Colors.blue.shade600)
                        : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      emp.name ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: isOnline ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color:
                                isOnline
                                    ? Colors.green.shade700
                                    : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.phone_rounded,
                      color: Colors.green,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green.shade50,
                      padding: const EdgeInsets.all(6),
                    ),
                    onPressed: () {
                      if (emp.mobileNo != null)
                        launchUrl(Uri.parse('tel:${emp.mobileNo}'));
                    },
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(
                      Icons.sms_rounded,
                      color: Colors.blue,
                      size: 18,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue.shade50,
                      padding: const EdgeInsets.all(6),
                    ),
                    onPressed: () {
                      if (emp.mobileNo != null)
                        launchUrl(Uri.parse('sms:${emp.mobileNo}'));
                    },
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),

          // Statistics Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatBox("Distance", "$travelMeter km"),
              _buildStatBox("Login", loginTime),
              _buildStatBox("Logout", logoutTime),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatBox("Farm Visits", "$farmCount"),
              _buildStatBox("Store Visits", "$storeCount"),
            ],
          ),
          const SizedBox(height: 14),

          // Full History Navigation Button
          ElevatedButton.icon(
            onPressed:
                () => Get.to(() => MarketerMapScreen(employeeId: emp.id)),
            icon: const Icon(
              Icons.history_rounded,
              color: Colors.white,
              size: 18,
            ),
            label: const Text(
              "View Route & Target History",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F7F1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmployeePremiumCard extends StatelessWidget {
  final UserModel employee;
  final ManagerDashboardController controller;

  const _EmployeePremiumCard({
    required this.employee,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Get.to(() => ManagerEmployeeDetailsScreen(employee: employee));
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Hero(
                  tag: 'emp_${employee.id}',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.15),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue.shade50,
                      backgroundImage:
                          (employee.image != null && employee.image!.isNotEmpty)
                              ? NetworkImage(employee.image!)
                              : null,
                      child:
                          (employee.image == null || employee.image!.isEmpty)
                              ? Icon(
                                Icons.person,
                                size: 28,
                                color: Colors.blue.shade400,
                              )
                              : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        employee.name ?? "Unknown",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(() {
                        final statusData =
                            controller.employeeStatuses[employee.id];
                        final workSession =
                            statusData != null
                                ? statusData['work_session']
                                : null;
                        final isOnline =
                            workSession != null &&
                            workSession['status'] == 'ACTIVE';

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isOnline
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isOnline ? Colors.green : Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOnline ? 'Online' : 'Offline',
                                style: TextStyle(
                                  color:
                                      isOnline
                                          ? Colors.green.shade800
                                          : Colors.red.shade800,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "Mobile: ${employee.mobileNo ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.phone_rounded,
                        color: Colors.green,
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.green.shade50,
                        padding: const EdgeInsets.all(8),
                      ),
                      onPressed: () {
                        if (employee.mobileNo != null) {
                          launchUrl(Uri.parse('tel:${employee.mobileNo}'));
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.sms_rounded,
                        color: Colors.blue,
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.blue.shade50,
                        padding: const EdgeInsets.all(8),
                      ),
                      onPressed: () {
                        if (employee.mobileNo != null) {
                          launchUrl(Uri.parse('sms:${employee.mobileNo}'));
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
