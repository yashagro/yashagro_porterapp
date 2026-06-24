import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/constants.dart';
import 'package:partener_app/expert/lab_report/view/lab_report_view.dart';
import 'package:partener_app/expert/farmer_details/controller/farmer_plot_controller.dart';
import 'package:partener_app/expert/chats/model/chat_room_model.dart';
import 'package:partener_app/expert/work_diary/view/workdiary_table_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDetailsScreen extends StatelessWidget {
  final ChatRoomModel chatRoom;
  final FarmerPlotController controller = Get.put(FarmerPlotController());

  UserDetailsScreen({super.key, required this.chatRoom}) {
    if (chatRoom.plot?.id != null) {
      controller.loadPlotDetails(chatRoom.plot!.id!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFFAF9F6),
        elevation: 0,
        title: const Text(
          "User Details",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshAll,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (chatRoom.user?.image != null)
                    _buildProfileImage(chatRoom.user!.image!),

                  const SizedBox(height: 16),
                  _buildCard(
                    title: "👤 Farmer Details",
                    children: [
                      _buildDetailRow(
                        Icons.person,
                        "Name",
                        chatRoom.user?.name,
                      ),
                      _buildMobileRow(chatRoom.user?.mobileNo),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildCard(
                    title: "🌾 Plot Details",
                    children:
                        controller.plotModel == null
                            ? [
                              const Center(
                                child: Text("No plot details available"),
                              ),
                            ]
                            : _buildPlotDetails(),
                  ),
                  const SizedBox(height: 20),
                  const SizedBox(height: 16),

                  _buildCard(
                    title: "🧪 Lab Reports",
                    children: [
                      LabReportListWidget(plotId: chatRoom.plot?.id ?? 0),
                    ],
                  ),

                  const SizedBox(height: 20),
                  _buildCard(
                    title: "📖 Work Diary",
                    children: [
                      WorkDiaryTableWidget(
                        plotId: chatRoom.plot?.id ?? 0,
                        userId: chatRoom.user?.id ?? 0,
                        plotName: chatRoom.plot?.name ?? '',
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => _showVisitRequestDialog(context),
                    icon: const Icon(Icons.schedule, color: Colors.white),
                    label: const Text(
                      "Request Plot Visit",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.green.shade700, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.green.shade200,
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: CircleAvatar(radius: 50, backgroundImage: NetworkImage(ApiRoutes.baseUri + imageUrl)),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.green.shade700),
          const SizedBox(width: 10),
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              safeString(value),
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileRow(String? mobile) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.phone, color: Colors.green.shade700),
          const SizedBox(width: 10),
          const Text(
            "Mobile:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              safeString(mobile),
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (mobile != null && mobile.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _makePhoneCall(mobile),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationRow(String? location) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.green.shade700),
          const SizedBox(width: 10),
          const Text(
            "Location:",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => _openMap(location),
              child: Text(
                safeString(location),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (location != null && location.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.map, color: Colors.green),
              onPressed: () => _openMap(location),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildPlotDetails() {
    final plot = controller.plotModel!;
  
    return [
      _buildDetailRow(Icons.landscape, "Plot Name", plot.plotName),
      _buildDetailRow(Icons.grass, "Crop", plot.crop?.cropName ?? "N/A"),
      _buildDetailRow(Icons.grass, "Variety", plot.variety?.variety ?? "N/A"),
      _buildDetailRow(
        Icons.cut,
        "Pruning Type",
        plot.pruning?.pruningType ?? "N/A",
      ),
      _buildDetailRow(
        Icons.date_range,
        "Pruning Date",
        _formatDate(plot.prunningDate),
      ),
      _buildDetailRow(
        Icons.date_range,
        "Plantation Year",
        _formatDate(plot.plantationYear),
      ),
      // _buildDetailRow(
      //   Icons.calendar_today,
      //   "Plantation Type",
      //   _formatDate(plot.plantation),
      // ),
      _buildDetailRow(
        Icons.date_range,
        "Planting Date",
        _formatDate(plot.plantingDate),
      ),
      _buildDetailRow(
        Icons.square_foot,
        "Area",
        "${safeString(plot.area)} ${safeString(plot.areaUnit)}",
      ),
      _buildDetailRow(
        Icons.local_florist,
        "Soil Type",
        safeString(plot.soilType),
      ),
      _buildDetailRow(Icons.thermostat, "Soil pH", safeString(plot.soilPh)),
      _buildDetailRow(
        Icons.water_drop,
        "Irrigation Type",
        safeString(plot.irrigationType),
      ),
      _buildDetailRow(Icons.house, "Structure", safeString(plot.structure)),
      _buildLocationRow(plot.location),
    ];
  }

  Future<void> _makePhoneCall(String mobileNumber) async {
    final Uri callUri = Uri(scheme: 'tel', path: mobileNumber);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not launch dialer',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _openMap(String? location) async {
    if (location == null || location.isEmpty) {
      Get.snackbar(
        'Error',
        'Location not available',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    List<String> parts = location.split(',');
    if (parts.length != 2) {
      Get.snackbar(
        'Invalid Location',
        'Incorrect format.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    String lat = parts[0].trim();
    String lon = parts[1].trim();

    try {
      double.parse(lat);
      double.parse(lon);
    } catch (_) {
      Get.snackbar(
        'Error',
        'Coordinates must be numeric',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final Uri mapUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lon',
    );

    if (await canLaunchUrl(mapUrl)) {
      await launchUrl(mapUrl, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'Error',
        'Could not open map',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }

  String safeString(dynamic value) {
    if (value == null || value.toString().isEmpty) return "N/A";
    return value.toString();
  }

  String _formatDate(dynamic date, {bool includeTime = false}) {
    if (date == null || date.toString().isEmpty) return "N/A";
    try {
      final parsed = DateTime.parse(date.toString());
      if (includeTime) {
        return "${parsed.day.toString().padLeft(2, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.year} ${parsed.hour.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')} (${parsed.hour >= 12 ? 'PM' : 'AM'})";
      }
      return "${parsed.day.toString().padLeft(2, '0')}-${parsed.month.toString().padLeft(2, '0')}-${parsed.year}";
    } catch (e) {
      return "N/A";
    }
  }

  void _showVisitRequestDialog(BuildContext context) {
    if (chatRoom.user?.id == null || chatRoom.plot?.id == null) {
      Get.snackbar(
        'Error',
        'Missing user or plot information',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    final TextEditingController remarksController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Request Plot Visit",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Date Picker
                  ListTile(
                    title: Text(selectedDate == null ? "Select Date" : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}"),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() => selectedDate = date);
                      }
                    },
                  ),
                  
                  // Time Picker
                  ListTile(
                    title: Text(selectedTime == null ? "Select Time" : selectedTime!.format(context)),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() => selectedTime = time);
                      }
                    },
                  ),
                  
                  const SizedBox(height: 10),
                  TextField(
                    controller: remarksController,
                    decoration: const InputDecoration(
                      labelText: "Remarks",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      onPressed: () async {
                        if (selectedDate == null || selectedTime == null || remarksController.text.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please fill all details',
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }

                        final scheduledAt = DateTime(
                          selectedDate!.year,
                          selectedDate!.month,
                          selectedDate!.day,
                          selectedTime!.hour,
                          selectedTime!.minute,
                        );

                        Get.back(); // close bottom sheet
                        Get.dialog(
                          const Center(child: CircularProgressIndicator()),
                          barrierDismissible: false,
                        );

                        final success = await controller.requestVisit(
                          farmerId: chatRoom.user!.id!,
                          plotId: chatRoom.plot!.id!,
                          scheduledAt: scheduledAt,
                          remarks: remarksController.text,
                        );

                        Get.back(); // close loading dialog

                        if (success) {
                          Get.snackbar(
                            'Success',
                            'Visit request submitted successfully',
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        } else {
                          Get.snackbar(
                            'Error',
                            'Failed to submit visit request',
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                        }
                      },
                      child: const Text(
                        "Submit Request",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
