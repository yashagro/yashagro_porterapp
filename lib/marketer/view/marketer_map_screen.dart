import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:partener_app/marketer/controller/marketer_dashboard_controller.dart';
import 'package:partener_app/services/routing_service.dart';
import 'package:geolocator/geolocator.dart';

class MarketerMapScreen extends StatefulWidget {
  final int? employeeId;
  const MarketerMapScreen({super.key, this.employeeId});

  @override
  State<MarketerMapScreen> createState() => _MarketerMapScreenState();
}

class _MarketerMapScreenState extends State<MarketerMapScreen> {
  String selectedFilter = 'ALL'; // ALL, FARM_VISIT, CUSTOMER_VISIT
  LatLng? _currentLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  Future<void> _fetchCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      if (permission == LocationPermission.deniedForever) return;

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      debugPrint("Error fetching location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final tag =
        widget.employeeId != null ? 'emp_${widget.employeeId}' : 'current_user';
    final controller =
        Get.isRegistered<MarketerDashboardController>(tag: tag)
            ? Get.find<MarketerDashboardController>(tag: tag)
            : Get.put(
              MarketerDashboardController(
                employeeIdOverride: widget.employeeId,
              ),
              tag: tag,
            );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F1),
      appBar: AppBar(
        title: const Text(
          'Route & Target History',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_rounded, color: Colors.green),
            onPressed: () async {
              final pickedRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange: controller.selectedHistoryDateRange.value,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.green.shade600,
                        onPrimary: Colors.white,
                        surface: Colors.white,
                        onSurface: Colors.black87,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedRange != null) {
                controller.fetchHistoryForRange(pickedRange);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isHistoryLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.green),
          );
        }

        if (controller.rangeDaysList.isEmpty) {
          return const Center(
            child: Text("No records found for the selected range."),
          );
        }

        final selectedRange = controller.selectedHistoryDateRange.value;
        final isMultiDay = controller.rangeDaysList.length > 1;

        return Column(
          children: [
            // Active Range Pill Info
            if (selectedRange != null)
              Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.today_rounded,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${DateFormat('yyyy-MM-dd').format(selectedRange.start)}   to   ${DateFormat('yyyy-MM-dd').format(selectedRange.end)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),

            _buildMultiDaySummaryCard(context, controller),

            // Horizontal Days List if multi-day selected
            if (isMultiDay) ...[
              SizedBox(
                height: 110,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: controller.rangeDaysList.length,
                  itemBuilder: (context, index) {
                    final dayData = controller.rangeDaysList[index];
                    final date = dayData['date'] as DateTime;
                    final isSelected =
                        controller.selectedSpecificDay.value != null &&
                        DateFormat(
                              'yyyy-MM-dd',
                            ).format(controller.selectedSpecificDay.value!) ==
                            DateFormat('yyyy-MM-dd').format(date);

                    final targetFarm = dayData['target_farm'] ?? 0;
                    final targetStore = dayData['target_store'] ?? 0;
                    final completedFarm = dayData['completed_farm'] ?? 0;
                    final completedStore = dayData['completed_store'] ?? 0;
                    final distance = dayData['travel_meter'] ?? 0;
                    final ws = dayData['work_session'];
                    final hasSession = ws != null && ws['start_time'] != null;

                    Color cardBgColor = Colors.white;
                    Color cardBorderColor = Colors.grey.shade200;
                    if (!hasSession) {
                      cardBgColor =
                          isSelected ? Colors.red.shade50 : Colors.grey.shade50;
                      cardBorderColor =
                          isSelected
                              ? Colors.red.shade400
                              : Colors.red.shade100;
                    } else {
                      cardBgColor =
                          isSelected ? Colors.green.shade50 : Colors.white;
                      cardBorderColor =
                          isSelected
                              ? Colors.green.shade500
                              : Colors.grey.shade200;
                    }

                    return GestureDetector(
                      onTap: () => controller.selectSpecificDay(date),
                      child: Container(
                        width: 140,
                        margin: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: cardBorderColor,
                            width: isSelected ? 1.8 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEE, d MMM').format(date),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color:
                                    !hasSession
                                        ? (isSelected
                                            ? Colors.red.shade900
                                            : Colors.grey.shade600)
                                        : (isSelected
                                            ? Colors.green.shade800
                                            : Colors.black87),
                              ),
                            ),
                            if (!hasSession) ...[
                              const SizedBox(height: 2),
                              Text(
                                "No Session",
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              "Dist: $distance km",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              "Farm: $completedFarm/$targetFarm",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              "Store: $completedStore/$targetStore",
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Main Details Section for selected day
            Expanded(
              child:
                  controller.specificDayDetails.isEmpty
                      ? const Center(
                        child: Text("Select a day to view details"),
                      )
                      : _buildDayDetails(
                        context,
                        controller.specificDayDetails,
                      ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDayDetails(BuildContext context, Map<String, dynamic> dayData) {
    final workSession = dayData['work_session'];
    final travelMeter = dayData['travel_meter'] ?? 0;
    final locations = dayData['locations'] as List<dynamic>? ?? [];
    final visits = dayData['visits'] as List<dynamic>? ?? [];

    // Parse coordinates
    final List<LatLng> routePoints = [];

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

    // Filter and Sort Visits in Ascending Time order
    final sortedVisits = List<dynamic>.from(visits);
    sortedVisits.sort((a, b) {
      final aTime =
          a['created_at'] != null
              ? DateTime.parse(a['created_at'])
              : DateTime.now();
      final bTime =
          b['created_at'] != null
              ? DateTime.parse(b['created_at'])
              : DateTime.now();
      return aTime.compareTo(bTime);
    });

    final filteredVisits =
        sortedVisits.where((v) {
          if (selectedFilter == 'ALL') return true;
          return v['type'] == selectedFilter;
        }).toList();

    // Parse session times
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

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Info stats card (login/logout, distance)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatPill(
                  "Distance",
                  "$travelMeter km",
                  Icons.directions_walk_rounded,
                  Colors.purple,
                ),
                _buildStatPill(
                  "Login",
                  loginTime,
                  Icons.login_rounded,
                  Colors.green,
                ),
                _buildStatPill(
                  "Logout",
                  logoutTime,
                  Icons.logout_rounded,
                  Colors.red,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Map view
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                children: [
                  FlutterMap(
                    key: ValueKey(
                      'history-map-${routePoints.length}-${dayData['date']}',
                    ),
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: mapCenter,
                      initialZoom: routePoints.isNotEmpty ? 14.5 : 5.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.partener_app',
                      ),
                      if (routePoints.isNotEmpty)
                        RoadPolylineLayer(
                          rawPoints: routePoints,
                          color: Colors.green.shade600,
                          strokeWidth: 4.5,
                        ),
                      MarkerLayer(
                        markers: [
                          // Start location marker
                          if (routePoints.isNotEmpty)
                            Marker(
                              point: routePoints.first,
                              width: 30,
                              height: 30,
                              child: GestureDetector(
                                onTap:
                                    () => RoutingService.launchGoogleMapsRoute([
                                      routePoints.first,
                                    ]),
                                child: const Icon(
                                  Icons.trip_origin_rounded,
                                  color: Colors.green,
                                  size: 20,
                                ),
                              ),
                            ),
                          // Current location marker
                          if (_currentLocation != null)
                            Marker(
                              point: _currentLocation!,
                              width: 30,
                              height: 30,
                              child: GestureDetector(
                                onTap:
                                    () => RoutingService.launchGoogleMapsRoute([
                                      _currentLocation!,
                                    ]),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade600,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.blue.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.my_location_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          // Visit pins
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
                              width: 38,
                              height: 38,
                              child: GestureDetector(
                                onTap:
                                    () => RoutingService.launchGoogleMapsRoute([
                                      LatLng(lat, lon),
                                    ]),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color:
                                        isFarm
                                            ? Colors.green.shade600
                                            : Colors.orange.shade600,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    isFarm
                                        ? Icons.agriculture_rounded
                                        : Icons.storefront_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
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
                              _mapController.move(
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
          const SizedBox(height: 20),

          // Visits feed section with Toggle filters
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Marked Visits",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  _buildFilterChip("All", 'ALL'),
                  const SizedBox(width: 6),
                  _buildFilterChip("Farm", 'FARM_VISIT'),
                  const SizedBox(width: 6),
                  _buildFilterChip("Store", 'CUSTOMER_VISIT'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Ascending list of visits
          if (filteredVisits.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: Text(
                "No visits recorded for this day matching filter.",
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredVisits.length,
              itemBuilder: (context, index) {
                final v = filteredVisits[index];
                final isFarm = v['type'] == 'FARM_VISIT';
                final time =
                    v['created_at'] != null
                        ? DateFormat(
                          'hh:mm a',
                        ).format(DateTime.parse(v['created_at']).toLocal())
                        : 'N/A';
                final payload = v['payload'] as Map<String, dynamic>? ?? {};

                final name =
                    payload['customer_name']?.toString() ?? 'Unknown Customer';
                final phone = payload['mobile_no']?.toString() ?? 'N/A';
                final crop = payload['crop_name']?.toString();

                return Card(
                  color: Colors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                            isFarm
                                ? Colors.green.shade50
                                : Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFarm
                            ? Icons.agriculture_rounded
                            : Icons.storefront_rounded,
                        color:
                            isFarm
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      isFarm
                          ? "Farm Visit • $crop\nPhone: $phone"
                          : "Store Visit\nPhone: $phone",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    trailing: Text(
                      time,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.green,
                      ),
                    ),
                  ),
                );
              },
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildStatPill(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.shade600 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.green.shade600 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildMultiDaySummaryCard(
    BuildContext context,
    MarketerDashboardController controller,
  ) {
    final selectedRange = controller.selectedHistoryDateRange.value;
    if (selectedRange == null) return const SizedBox.shrink();

    final isMultiDay =
        selectedRange.start.year != selectedRange.end.year ||
        selectedRange.start.month != selectedRange.end.month ||
        selectedRange.start.day != selectedRange.end.day;

    if (!isMultiDay) return const SizedBox.shrink();

    double totalDistance = 0.0;
    int totalMinutes = 0;
    for (var d in controller.rangeDaysList) {
      final distVal = d['travel_meter'];
      if (distVal != null) {
        totalDistance += double.tryParse(distVal.toString()) ?? 0.0;
      }
      final ws = d['work_session'];
      if (ws != null && ws['start_time'] != null) {
        totalMinutes +=
            int.tryParse(ws['working_minutes']?.toString() ?? '') ?? 0;
      }
    }

    final totalHours = totalMinutes ~/ 60;
    final remainingMinutes = totalMinutes % 60;
    final String workingTimeStr =
        totalHours > 0
            ? "${totalHours}h ${remainingMinutes}m"
            : "${remainingMinutes}m";

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Travel & Distance Summary",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Icon(
                    Icons.directions_walk_rounded,
                    color: Colors.green.shade700,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${totalDistance.toStringAsFixed(1)} km",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green.shade900,
                    ),
                  ),
                  const Text(
                    "Total Distance",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(height: 30, width: 1, color: Colors.grey.shade200),
              Column(
                children: [
                  Icon(
                    Icons.timer_rounded,
                    color: Colors.green.shade700,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    workingTimeStr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green.shade900,
                    ),
                  ),
                  const Text(
                    "Total Working Time",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
