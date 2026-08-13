import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/managers/controller/manager_employee_details_controller.dart';
import 'package:partener_app/marketer/controller/marketer_dashboard_controller.dart';
import 'package:partener_app/models/user_model.dart';

class ManagerEmployeeDetailsScreen extends StatefulWidget {
  final UserModel employee;

  const ManagerEmployeeDetailsScreen({super.key, required this.employee});

  @override
  State<ManagerEmployeeDetailsScreen> createState() =>
      _ManagerEmployeeDetailsScreenState();
}

class _ManagerEmployeeDetailsScreenState
    extends State<ManagerEmployeeDetailsScreen> {
  late ManagerEmployeeDetailsController controller;
  late MarketerDashboardController marketerController;
  String selectedFilter = 'ALL'; // ALL, FARM_VISIT, CUSTOMER_VISIT

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      ManagerEmployeeDetailsController(),
      tag: widget.employee.id.toString(),
    );
    if (widget.employee.id != null) {
      controller.fetchEmployeeData(widget.employee.id!);
    }

    // Instantiating MarketerDashboardController with employeeIdOverride to load range histories
    marketerController = Get.put(
      MarketerDashboardController(employeeIdOverride: widget.employee.id),
      tag: 'details_emp_${widget.employee.id}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9F9),
      appBar: AppBar(
        title: Text(widget.employee.name ?? 'Employee Details'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_rounded, color: Colors.white),
            onPressed: () {
              if (widget.employee.mobileNo != null) {
                launchUrl(Uri.parse('tel:${widget.employee.mobileNo}'));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
            onPressed: () {
              if (widget.employee.mobileNo != null) {
                launchUrl(
                  Uri.parse('https://wa.me/${widget.employee.mobileNo}'),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.date_range_rounded, color: Colors.white),
            onPressed: () async {
              final pickedRange = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                initialDateRange:
                    marketerController.selectedHistoryDateRange.value,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.blue.shade700,
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
                marketerController.fetchHistoryForRange(pickedRange);
              }
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value ||
            marketerController.isHistoryLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            if (widget.employee.id != null) {
              await controller.fetchEmployeeData(widget.employee.id!);
              final currentRange =
                  marketerController.selectedHistoryDateRange.value;
              if (currentRange != null) {
                await marketerController.fetchHistoryForRange(currentRange);
              }
            }
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildActiveRangeDisplay(),
              const SizedBox(height: 12),
              _buildMultiDaySummaryCard(),
              _buildHorizontalDaysTimeline(),
              const SizedBox(height: 16),
              _buildSelectedDayDetails(context),
              const SizedBox(height: 80),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade900.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'emp_${widget.employee.id}',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: Colors.blue.shade50,
                backgroundImage:
                    (widget.employee.image != null &&
                            widget.employee.image!.isNotEmpty)
                        ? NetworkImage(widget.employee.image!)
                        : null,
                child:
                    (widget.employee.image == null ||
                            widget.employee.image!.isEmpty)
                        ? Icon(
                          Icons.person,
                          size: 36,
                          color: Colors.blue.shade400,
                        )
                        : null,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.employee.name ?? "Unknown",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.badge_outlined,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "ID: ${widget.employee.id ?? 'N/A'}",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.employee.mobileNo ?? "No Phone",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
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
  }

  Widget _buildActiveRangeDisplay() {
    final selectedRange = marketerController.selectedHistoryDateRange.value;
    if (selectedRange == null) return const SizedBox.shrink();

    final isSingleDay =
        selectedRange.start.year == selectedRange.end.year &&
        selectedRange.start.month == selectedRange.end.month &&
        selectedRange.start.day == selectedRange.end.day;

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.today_rounded, size: 16, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              isSingleDay
                  ? DateFormat('yyyy-MM-dd').format(selectedRange.start)
                  : "${DateFormat('yyyy-MM-dd').format(selectedRange.start)}   to   ${DateFormat('yyyy-MM-dd').format(selectedRange.end)}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalDaysTimeline() {
    final isMultiDay = marketerController.rangeDaysList.length > 1;
    if (!isMultiDay) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: marketerController.rangeDaysList.length,
        itemBuilder: (context, index) {
          final dayData = marketerController.rangeDaysList[index];
          final date = dayData['date'] as DateTime;
          final isSelected =
              marketerController.selectedSpecificDay.value != null &&
              DateFormat(
                    'yyyy-MM-dd',
                  ).format(marketerController.selectedSpecificDay.value!) ==
                  DateFormat('yyyy-MM-dd').format(date);

          final targetFarm = dayData['target_farm'] ?? 0;
          final targetStore = dayData['target_store'] ?? 0;
          final completedFarm = dayData['completed_farm'] ?? 0;
          final completedStore = dayData['completed_store'] ?? 0;
          final distance = dayData['travel_meter'] ?? 0;

          return GestureDetector(
            onTap: () => marketerController.selectSpecificDay(date),
            child: Container(
              width: 130,
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      isSelected ? Colors.blue.shade500 : Colors.grey.shade200,
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
                      fontSize: 12,
                      color: isSelected ? Colors.blue.shade800 : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Dist: $distance km",
                    style: const TextStyle(fontSize: 10, color: Colors.black54),
                  ),
                  Text(
                    "Farm: $completedFarm/$targetFarm",
                    style: const TextStyle(fontSize: 9, color: Colors.black54),
                  ),
                  Text(
                    "Store: $completedStore/$targetStore",
                    style: const TextStyle(fontSize: 9, color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectedDayDetails(BuildContext context) {
    if (marketerController.specificDayDetails.isEmpty) {
      return const Center(
        child: Text("No tracking records found for this day."),
      );
    }

    final dayData = marketerController.specificDayDetails;
    final workSession = dayData['work_session'];
    final travelMeter = dayData['travel_meter'] ?? 0;
    final locations = dayData['locations'] as List<dynamic>? ?? [];
    final visits = dayData['visits'] as List<dynamic>? ?? [];

    // Parse coordinates
    final List<LatLng> routePoints = [];
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

    // Parse odometer photos
    final startImages =
        workSession != null
            ? workSession['start_work_images'] as List<dynamic>? ?? []
            : [];
    final endImages =
        workSession != null
            ? workSession['end_work_images'] as List<dynamic>? ?? []
            : [];

    final startMeter =
        workSession != null ? workSession['start_work_meter'] ?? 'N/A' : 'N/A';
    final endMeter =
        workSession != null ? workSession['end_work_meter'] ?? 'N/A' : 'N/A';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Stats
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildStatPill(
                  "Distance",
                  "$travelMeter km",
                  Icons.directions_walk_rounded,
                  Colors.purple,
                ),
                const SizedBox(width: 16),
                _buildStatPill(
                  "Login Time",
                  loginTime,
                  Icons.login_rounded,
                  Colors.green,
                ),
                const SizedBox(width: 16),
                _buildStatPill(
                  "Login KM",
                  "$startMeter km",
                  Icons.speed_rounded,
                  Colors.teal,
                ),
                const SizedBox(width: 16),
                _buildStatPill(
                  "Logout Time",
                  logoutTime,
                  Icons.logout_rounded,
                  Colors.red,
                ),
                const SizedBox(width: 16),
                _buildStatPill(
                  "Logout KM",
                  "$endMeter km",
                  Icons.flag_rounded,
                  Colors.indigo,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Target Progress card
        Builder(
          builder: (context) {
            final selectedDate =
                marketerController.selectedSpecificDay.value ?? DateTime.now();
            final daySummary = marketerController.rangeDaysList
                .firstWhereOrNull(
                  (d) =>
                      DateFormat('yyyy-MM-dd').format(d['date'] as DateTime) ==
                      DateFormat('yyyy-MM-dd').format(selectedDate),
                );

            final targetFarm =
                daySummary != null ? daySummary['target_farm'] ?? 0 : 0;
            final completedFarm =
                daySummary != null ? daySummary['completed_farm'] ?? 0 : 0;
            final targetStore =
                daySummary != null ? daySummary['target_store'] ?? 0 : 0;
            final completedStore =
                daySummary != null ? daySummary['completed_store'] ?? 0 : 0;

            return _buildTargetProgressCard(
              completedFarm,
              targetFarm,
              completedStore,
              targetStore,
            );
          },
        ),
        const SizedBox(height: 16),

        // Route Map
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(20),
            ),
            child: FlutterMap(
              key: ValueKey(
                'details-map-${routePoints.length}-${dayData['date']}',
              ),
              options: MapOptions(
                initialCenter: mapCenter,
                initialZoom: routePoints.isNotEmpty ? 14.5 : 5.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.partener_app',
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
                    if (routePoints.isNotEmpty)
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
                          onTap: () => _showVisitDetailsBottomSheet(context, v),
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  isFarm
                                      ? Colors.green.shade600
                                      : Colors.orange.shade600,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
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
          ),
        ),
        const SizedBox(height: 16),

        // Odometer Photos Cards
        if (startImages.isNotEmpty || endImages.isNotEmpty) ...[
          Builder(
            builder: (context) {
              final List<String> galleryPhotos = [];
              for (var img in startImages) {
                galleryPhotos.add('${ApiRoutes.baseUri}${img['url']}');
              }
              for (var img in endImages) {
                galleryPhotos.add('${ApiRoutes.baseUri}${img['url']}');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (startImages.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0, top: 4.0),
                      child: Text(
                        "Login / Odometer Start Photos",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(startImages.length, (idx) {
                        final img = startImages[idx];
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                              right: idx < startImages.length - 1 ? 8 : 0,
                            ),
                            child: GestureDetector(
                              onTap:
                                  () => _showGalleryDialog(
                                    context,
                                    galleryPhotos,
                                    idx,
                                  ),
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child: Image.network(
                                        '${ApiRoutes.baseUri}${img['url']}',
                                        height: 100,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  height: 100,
                                                  color: Colors.grey.shade100,
                                                  child: const Icon(
                                                    Icons.broken_image_rounded,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      child: Text(
                                        "Login Photo ${idx + 1}",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (endImages.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Logout / Odometer End Photos",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(endImages.length, (idx) {
                        final img = endImages[idx];
                        final globalIdx = startImages.length + idx;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(
                              right: idx < endImages.length - 1 ? 8 : 0,
                            ),
                            child: GestureDetector(
                              onTap:
                                  () => _showGalleryDialog(
                                    context,
                                    galleryPhotos,
                                    globalIdx,
                                  ),
                              child: Card(
                                color: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(16),
                                      ),
                                      child: Image.network(
                                        '${ApiRoutes.baseUri}${img['url']}',
                                        height: 100,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  height: 100,
                                                  color: Colors.grey.shade100,
                                                  child: const Icon(
                                                    Icons.broken_image_rounded,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      child: Text(
                                        "Logout Photo ${idx + 1}",
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 16),
        ],

        // Marked Visits Title and Tabs
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Marked Visits",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                _buildFilterChip("All", 'ALL'),
                const SizedBox(width: 4),
                _buildFilterChip("Farm", 'FARM_VISIT'),
                const SizedBox(width: 4),
                _buildFilterChip("Store", 'CUSTOMER_VISIT'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Visits timeline
        if (filteredVisits.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            child: Text(
              "No visits recorded matching filter.",
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
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          isFarm ? Colors.green.shade50 : Colors.orange.shade50,
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
                      size: 20,
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    isFarm
                        ? "Farm Visit • $crop\nPhone: $phone"
                        : "Store Visit\nPhone: $phone",
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (phone != 'N/A' && phone.isNotEmpty) ...[
                        IconButton(
                          icon: const Icon(
                            Icons.phone_rounded,
                            color: Colors.green,
                            size: 18,
                          ),
                          onPressed: () => launchUrl(Uri.parse('tel:$phone')),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chat_bubble_rounded,
                            color: Colors.blue,
                            size: 18,
                          ),
                          onPressed:
                              () =>
                                  launchUrl(Uri.parse('https://wa.me/$phone')),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                        ),
                      ],
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade700 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTargetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Assigned Targets",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.targets.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Center(
                child: Text(
                  "No targets assigned yet",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.targets.length,
            itemBuilder: (context, index) {
              final target = controller.targets[index];

              final type = target['type']?.toString().toLowerCase() ?? '';
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
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(typeIcon, color: typeColor, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type.capitalizeFirst ?? 'Unknown Type',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                              ),
                              if (target['target_description'] != null &&
                                  target['target_description']
                                      .toString()
                                      .isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    target['target_description'],
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: typeColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.flag,
                                    color: Colors.white70,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${target['target_count'] ?? 0}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 4),
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.grey,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showUpdateTargetDialog(context, target);
                                } else if (value == 'delete') {
                                  _showDeleteTargetDialog(context, target);
                                }
                              },
                              itemBuilder:
                                  (BuildContext context) =>
                                      <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'edit',
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            title: Text('Edit Target'),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'delete',
                                          child: ListTile(
                                            leading: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            title: Text('Delete Target'),
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ],
                            ),
                          ],
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
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Date: ${target['start_date'] ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }

  void _showAssignTargetDialog(BuildContext context) {
    final farmController = TextEditingController();
    final storeController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Assign Daily Targets',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date selection options
                    const Text(
                      "Select Target Date",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(DateTime.now()) ==
                                          dateStr
                                      ? Colors.blue.shade700
                                      : Colors.grey.shade100,
                              foregroundColor:
                                  DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(DateTime.now()) ==
                                          dateStr
                                      ? Colors.white
                                      : Colors.black87,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedDate = DateTime.now();
                              });
                            },
                            child: const Text(
                              "Today",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  DateFormat('yyyy-MM-dd').format(
                                            DateTime.now().add(
                                              const Duration(days: 1),
                                            ),
                                          ) ==
                                          dateStr
                                      ? Colors.blue.shade700
                                      : Colors.grey.shade100,
                              foregroundColor:
                                  DateFormat('yyyy-MM-dd').format(
                                            DateTime.now().add(
                                              const Duration(days: 1),
                                            ),
                                          ) ==
                                          dateStr
                                      ? Colors.white
                                      : Colors.black87,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                selectedDate = DateTime.now().add(
                                  const Duration(days: 1),
                                );
                              });
                            },
                            child: const Text(
                              "Tomorrow",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 30),
                                ),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedDate = picked;
                                });
                              }
                            },
                            child: const Text(
                              "Calendar",
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        "Target Date: ${DateFormat('EEE, d MMMM yyyy').format(selectedDate)}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Farm Visit input
                    TextField(
                      controller: farmController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Farm Visits Target Count',
                        hintText: 'e.g. 3',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(
                          Icons.agriculture_rounded,
                          color: Colors.green,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Store Visit input
                    TextField(
                      controller: storeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Store/Shop Visits Target Count',
                        hintText: 'e.g. 4',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        prefixIcon: const Icon(
                          Icons.storefront_rounded,
                          color: Colors.orange,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final farmVal = int.tryParse(farmController.text) ?? 0;
                    final storeVal = int.tryParse(storeController.text) ?? 0;
                    if (farmVal == 0 && storeVal == 0) {
                      Get.snackbar(
                        'Error',
                        'Please enter at least one target count',
                      );
                      return;
                    }
                    if (widget.employee.id == null) {
                      Get.snackbar('Error', 'Invalid employee ID');
                      return;
                    }

                    final success = await controller.assignDailyTargets(
                      employeeId: widget.employee.id!,
                      farmTargetCount: farmVal,
                      storeTargetCount: storeVal,
                      targetDate: dateStr,
                    );

                    if (success) {
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Assign Targets'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateTargetDialog(
    BuildContext context,
    Map<String, dynamic> targetData,
  ) {
    final typeController = TextEditingController(
      text: targetData['type'] ?? 'farm',
    );
    final countController = TextEditingController(
      text: targetData['target_count']?.toString() ?? '',
    );
    final descController = TextEditingController(
      text: targetData['target_description'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Update Target',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value:
                          [
                                'farm',
                                'visit',
                                'sales',
                              ].contains(typeController.text.toLowerCase())
                              ? typeController.text.toLowerCase()
                              : 'farm',
                      decoration: InputDecoration(
                        labelText: 'Type',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'farm', child: Text('Farm')),
                        DropdownMenuItem(value: 'visit', child: Text('Visit')),
                        DropdownMenuItem(value: 'sales', child: Text('Sales')),
                      ],
                      onChanged: (value) {
                        if (value != null) typeController.text = value;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: countController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Target Count',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (countController.text.isEmpty) {
                      Get.snackbar('Error', 'Please enter target count');
                      return;
                    }
                    if (widget.employee.id == null ||
                        targetData['id'] == null) {
                      Get.snackbar('Error', 'Invalid data');
                      return;
                    }

                    final success = await controller.updateTarget(
                      employeeId: widget.employee.id!,
                      targetId: targetData['id'],
                      type: typeController.text,
                      targetCount: int.tryParse(countController.text) ?? 0,
                      targetDescription: descController.text,
                    );

                    if (success) {
                      if (context.mounted) Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Update Target'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteTargetDialog(
    BuildContext context,
    Map<String, dynamic> targetData,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade400,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Target',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to permanently delete this target? This action cannot be undone.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black87),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                if (widget.employee.id == null || targetData['id'] == null) {
                  Get.snackbar('Error', 'Invalid data');
                  return;
                }

                final success = await controller.deleteTarget(
                  employeeId: widget.employee.id!,
                  targetId: targetData['id'],
                );

                if (success) {
                  if (context.mounted) Navigator.pop(context);
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showFullImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                InteractiveViewer(
                  panEnabled: true,
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            padding: const EdgeInsets.all(20),
                            color: Colors.white,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.broken_image_rounded,
                                  size: 48,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 8),
                                Text("Failed to load image"),
                              ],
                            ),
                          ),
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showGalleryDialog(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    final pageController = PageController(initialPage: initialIndex);
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.black,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: imageUrls.length,
                  itemBuilder: (context, index) {
                    return InteractiveViewer(
                      panEnabled: true,
                      minScale: 0.5,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          imageUrls[index],
                          fit: BoxFit.contain,
                          errorBuilder:
                              (context, error, stackTrace) => Container(
                                padding: const EdgeInsets.all(20),
                                color: Colors.white,
                                child: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.broken_image_rounded,
                                      size: 48,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 8),
                                    Text("Failed to load image"),
                                  ],
                                ),
                              ),
                        ),
                      ),
                    );
                  },
                ),
                // Close button
                Positioned(
                  top: 40,
                  right: 20,
                  child: CircleAvatar(
                    backgroundColor: Colors.white24,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                // Swipe Indicator
                if (imageUrls.length > 1)
                  Positioned(
                    bottom: 40,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ListenableBuilder(
                        listenable: pageController,
                        builder: (context, child) {
                          final currentPage =
                              (pageController.hasClients
                                  ? pageController.page?.round()
                                  : initialIndex) ??
                              initialIndex;
                          return Text(
                            "${currentPage + 1} / ${imageUrls.length}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
    );
  }

  Widget _buildTargetProgressCard(
    int compFarm,
    int totalFarm,
    int compStore,
    int totalStore,
  ) {
    return Container(
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
            "Today's Target Progress",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _buildProgressItem("Farm Visits", compFarm, totalFarm, Colors.green),
          const SizedBox(height: 12),
          _buildProgressItem(
            "Store/Shop Visits",
            compStore,
            totalStore,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(
    String label,
    int completed,
    int total,
    Color color,
  ) {
    final double percent =
        total > 0 ? (completed / total).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            Text(
              "$completed / $total",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: color.withOpacity(0.1),
            color: color,
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  void _showVisitDetailsBottomSheet(
    BuildContext context,
    Map<String, dynamic> visit,
  ) {
    final isFarm = visit['type'] == 'FARM_VISIT';
    final payload = visit['payload'] as Map<String, dynamic>? ?? {};
    final name = payload['customer_name']?.toString() ?? 'Unknown Customer';
    final phone = payload['mobile_no']?.toString() ?? 'N/A';
    final crop = payload['crop_name']?.toString() ?? 'N/A';
    final remarks = visit['remarks']?.toString() ?? 'No remarks';
    final time =
        visit['created_at'] != null
            ? DateFormat(
              'hh:mm a, d MMM yyyy',
            ).format(DateTime.parse(visit['created_at']).toLocal())
            : 'N/A';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isFarm ? Colors.green.shade50 : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      isFarm ? "Farm Visit" : "Store Visit",
                      style: TextStyle(
                        color:
                            isFarm
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (phone != 'N/A') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      "Phone: $phone",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(
                        Icons.phone_rounded,
                        color: Colors.green,
                        size: 20,
                      ),
                      onPressed: () => launchUrl(Uri.parse('tel:$phone')),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.blue,
                        size: 20,
                      ),
                      onPressed:
                          () => launchUrl(Uri.parse('https://wa.me/$phone')),
                    ),
                  ],
                ),
              ],
              if (isFarm) ...[
                const SizedBox(height: 8),
                Text(
                  "Crop: $crop",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ],
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                "Remarks",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                remarks,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMultiDaySummaryCard() {
    final selectedRange = marketerController.selectedHistoryDateRange.value;
    if (selectedRange == null) return const SizedBox.shrink();

    final isMultiDay =
        selectedRange.start.year != selectedRange.end.year ||
        selectedRange.start.month != selectedRange.end.month ||
        selectedRange.start.day != selectedRange.end.day;

    print(
      "DEBUG selectedRange: ${selectedRange.start} to ${selectedRange.end}",
    );
    print("DEBUG isMultiDay: $isMultiDay");
    print(
      "DEBUG rangeDaysList length: ${marketerController.rangeDaysList.length}",
    );

    if (!isMultiDay) return const SizedBox.shrink();

    double totalDistance = 0.0;
    int totalMinutes = 0;
    for (var d in marketerController.rangeDaysList) {
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
      margin: const EdgeInsets.only(bottom: 16),
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
                    color: Colors.blue.shade700,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${totalDistance.toStringAsFixed(1)} km",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue.shade900,
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
                    color: Colors.blue.shade700,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    workingTimeStr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue.shade900,
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
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            "Daily Breakdown",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: marketerController.rangeDaysList.length,
            separatorBuilder:
                (context, index) =>
                    Divider(color: Colors.grey.shade100, height: 1),
            itemBuilder: (context, index) {
              final dayData = marketerController.rangeDaysList[index];
              final date = dayData['date'] as DateTime;
              final dist = dayData['travel_meter'] ?? 0;
              final ws = dayData['work_session'];
              final hasSession = ws != null;
              final mins = hasSession
                  ? int.tryParse(ws['working_minutes']?.toString() ?? '') ?? 0
                  : 0;
              final hrs = mins ~/ 60;
              final remMins = mins % 60;
              final timeStr = hrs > 0 ? "${hrs}h ${remMins}m" : "${remMins}m";

              final isSelected =
                  marketerController.selectedSpecificDay.value != null &&
                  DateFormat(
                        'yyyy-MM-dd',
                      ).format(marketerController.selectedSpecificDay.value!) ==
                      DateFormat('yyyy-MM-dd').format(date);

              Color dateColor = isSelected ? Colors.blue.shade700 : Colors.black87;
              Color timeColor = isSelected ? Colors.blue.shade700 : Colors.grey.shade600;
              if (!hasSession) {
                dateColor = isSelected ? Colors.red.shade700 : Colors.grey.shade500;
                timeColor = isSelected ? Colors.red.shade700 : Colors.red.shade300;
              }

              return InkWell(
                onTap: () => marketerController.selectSpecificDay(date),
                child: Container(
                  color: !hasSession && !isSelected ? Colors.grey.shade50.withOpacity(0.5) : Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: !hasSession 
                                ? (isSelected ? Colors.red.shade700 : Colors.grey)
                                : (isSelected ? Colors.blue.shade700 : Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('EEE, d MMM').format(date),
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: dateColor,
                              fontSize: 12,
                            ),
                          ),
                          if (!hasSession) ...[
                            const SizedBox(width: 6),
                            Text(
                              "(No Session)",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: isSelected ? Colors.red.shade900 : Colors.red.shade400,
                              ),
                            ),
                          ],
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            "$dist km",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: !hasSession ? Colors.grey.shade500 : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            width: 1,
                            height: 10,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: timeColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
