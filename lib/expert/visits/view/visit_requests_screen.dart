import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:partener_app/expert/visits/controller/visit_controller.dart';
import 'package:partener_app/expert/visits/model/visit_model.dart';
import 'package:partener_app/expert/employee_tracking/view/work_status_widget.dart' as import_work_status;

class VisitRequestsScreen extends StatelessWidget {
  final VisitController controller = Get.put(VisitController());

  VisitRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        appBar: AppBar(
          title: const Text(
            "Visit Requests",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          backgroundColor: const Color(0xFFFAF9F6),
          elevation: 0,
          centerTitle: true,
          actions: [
            import_work_status.WorkStatusWidget(),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TabBar(
                isScrollable: true,
                padding: const EdgeInsets.all(4),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.green.shade700,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade700.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                tabs: const [
                  Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Pending"))),
                  Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Today"))),
                  Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("Upcoming"))),
                  Tab(child: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text("All Visits"))),
                ],
              ),
            ),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return TabBarView(
            children: [
              _buildVisitList(controller.pendingRequests, true),
              _buildVisitList(controller.todayVisits, false),
              _buildVisitList(controller.upcomingVisits, false),
              _buildVisitList(controller.myVisits, false),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildVisitList(List<VisitModel> visits, bool isPending) {
    if (visits.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "No visits found",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.fetchAllData,
      color: Colors.green.shade700,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: visits.length,
        itemBuilder: (context, index) {
          final visit = visits[index];
          return _buildVisitCard(context, visit, isPending);
        },
      ),
    );
  }

  Widget _buildVisitCard(BuildContext context, VisitModel visit, bool isPending) {
    final statusColor = _getStatusColor(visit.status);
    final statusIcon = _getStatusIcon(visit.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 15,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.green.shade50,
                        child: Icon(Icons.person, color: Colors.green.shade700),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          visit.farmerName ?? "Farmer ID: ${visit.farmerId}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 14, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        visit.status ?? 'UNKNOWN',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),
            
            // Details
            _buildDetailRow(Icons.calendar_month, "Scheduled At", _formatDateTime(visit.scheduledAt)),
            if (visit.plotName != null && visit.plotName!.isNotEmpty)
              _buildDetailRow(Icons.landscape, "Plot", visit.plotName!),
            if (visit.village != null && visit.village!.isNotEmpty)
              _buildDetailRow(Icons.location_city, "Village", visit.village!),
            if (visit.remarks != null && visit.remarks!.isNotEmpty)
              _buildDetailRow(Icons.comment, "Remarks", visit.remarks!),
            if (visit.reason != null && visit.reason!.isNotEmpty)
              _buildDetailRow(Icons.info_outline, "Reason", visit.reason!),

            const SizedBox(height: 20),
            
            // Actions
            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showRejectDialog(context, visit),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade600,
                        side: BorderSide(color: Colors.red.shade200),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Reject", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showApproveDialog(context, visit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Approve", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.edit_note, color: Colors.white, size: 18),
                      onPressed: () => _showUpdateStatusDialog(context, visit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      label: const Text("Update Status", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.rate_review_outlined, color: Colors.white, size: 18),
                      onPressed: () => _showFeedbackDialog(context, visit),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple.shade600,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      label: const Text("Feedback", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: "$label: ",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
                children: [
                  TextSpan(
                    text: value,
                    style: const TextStyle(fontWeight: FontWeight.normal, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'PENDING': return Colors.orange;
      case 'APPROVED': return Colors.green;
      case 'ON_THE_WAY': return Colors.blue;
      case 'ARRIVED': return Colors.teal;
      case 'ONGOING': return Colors.indigo;
      case 'COMPLETED': return Colors.green.shade800;
      case 'CANCELLED': return Colors.red;
      case 'MISSED': return Colors.red.shade900;
      case 'RESCHEDULED': return Colors.deepOrange;
      default: return Colors.grey;
    }
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'PENDING': return Icons.hourglass_empty;
      case 'APPROVED': return Icons.check_circle_outline;
      case 'ON_THE_WAY': return Icons.directions_car;
      case 'ARRIVED': return Icons.location_on;
      case 'ONGOING': return Icons.play_circle_outline;
      case 'COMPLETED': return Icons.done_all;
      case 'CANCELLED': return Icons.cancel_outlined;
      case 'MISSED': return Icons.error_outline;
      case 'RESCHEDULED': return Icons.schedule;
      default: return Icons.help_outline;
    }
  }

  void _showApproveDialog(BuildContext context, VisitModel visit) {
    final TextEditingController remarksController = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Approve Visit", style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: Text(selectedDate == null ? "Select Date" : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}"),
                        trailing: Icon(Icons.calendar_today, color: Colors.green.shade700),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) => Theme(data: ThemeData.light().copyWith(primaryColor: Colors.green.shade700, colorScheme: ColorScheme.light(primary: Colors.green.shade700)), child: child!),
                          );
                          if (date != null) setState(() => selectedDate = date);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: Text(selectedTime == null ? "Select Time" : selectedTime!.format(context)),
                        trailing: Icon(Icons.access_time, color: Colors.green.shade700),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                            builder: (context, child) => Theme(data: ThemeData.light().copyWith(primaryColor: Colors.green.shade700, colorScheme: ColorScheme.light(primary: Colors.green.shade700)), child: child!),
                          );
                          if (time != null) setState(() => selectedTime = time);
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: remarksController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: "Remarks (Optional)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text("Cancel", style: TextStyle(color: Colors.grey.shade700)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (selectedDate == null || selectedTime == null) {
                      Get.snackbar("Notice", "Please select both date and time", backgroundColor: Colors.orange.shade100);
                      return;
                    }
                    final scheduledAt = DateTime(
                      selectedDate!.year, selectedDate!.month, selectedDate!.day,
                      selectedTime!.hour, selectedTime!.minute,
                    );
                    
                    Get.back();
                    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                    final success = await controller.approveRequest(
                      visit.id!,
                      scheduledAt.toUtc().toIso8601String(),
                      remarksController.text,
                    );
                    Get.back();
                    if (success) {
                      Get.snackbar("Success", "Visit approved successfully", backgroundColor: Colors.green.shade100, colorText: Colors.green.shade900);
                    } else {
                      Get.snackbar("Error", "Failed to approve visit", backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
                    }
                  },
                  child: const Text("Approve", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, VisitModel visit) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Reject Visit", style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: reasonController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: "Reason for rejection",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel", style: TextStyle(color: Colors.grey.shade700)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (reasonController.text.isEmpty) {
                  Get.snackbar("Notice", "Please enter a reason", backgroundColor: Colors.orange.shade100);
                  return;
                }
                Get.back();
                Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                final success = await controller.rejectRequest(visit.id!, reasonController.text);
                Get.back();
                if (success) {
                  Get.snackbar("Success", "Visit request rejected", backgroundColor: Colors.green.shade100, colorText: Colors.green.shade900);
                } else {
                  Get.snackbar("Error", "Failed to reject visit", backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
                }
              },
              child: const Text("Reject", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateStatusDialog(BuildContext context, VisitModel visit) {
    final statuses = [
      'APPROVED', 'ON_THE_WAY', 'ARRIVED', 'ONGOING', 'COMPLETED', 'CANCELLED', 'MISSED', 'RESCHEDULED'
    ];
    String? selectedStatus = statuses.contains(visit.status) ? visit.status : statuses.first;
    final TextEditingController remarksController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("Update Status", style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedStatus,
                    items: statuses.map((e) => DropdownMenuItem(value: e, child: Row(
                      children: [
                        Icon(_getStatusIcon(e), size: 18, color: _getStatusColor(e)),
                        const SizedBox(width: 10),
                        Text(e),
                      ],
                    ))).toList(),
                    onChanged: (val) => setState(() => selectedStatus = val),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      labelText: "Status",
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: remarksController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Remarks (Optional)",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text("Cancel", style: TextStyle(color: Colors.grey.shade700)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (selectedStatus == null) return;
                    Get.back();
                    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
                    final success = await controller.updateStatus(visit.id!, selectedStatus!, remarksController.text);
                    Get.back();
                    if (success) {
                      Get.snackbar("Success", "Status updated successfully", backgroundColor: Colors.green.shade100, colorText: Colors.green.shade900);
                    } else {
                      Get.snackbar("Error", "Failed to update status", backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
                    }
                  },
                  child: const Text("Update", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context, VisitModel visit) {
    final TextEditingController feedbackController = TextEditingController();
    final TextEditingController recommendationController = TextEditingController();
    String selectedCropCondition = 'GOOD';
    DateTime? selectedNextVisitDate;

    final cropConditions = ['GOOD', 'AVERAGE', 'POOR', 'CRITICAL'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Row(
                children: [
                  Icon(Icons.rate_review, color: Colors.deepPurple.shade600),
                  const SizedBox(width: 10),
                  const Text("Visit Feedback", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Crop Condition Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedCropCondition,
                      items: cropConditions.map((e) => DropdownMenuItem(
                        value: e,
                        child: Row(
                          children: [
                            Icon(
                              e == 'GOOD' ? Icons.check_circle :
                              e == 'AVERAGE' ? Icons.info :
                              e == 'POOR' ? Icons.warning :
                              Icons.error,
                              size: 18,
                              color: e == 'GOOD' ? Colors.green :
                                     e == 'AVERAGE' ? Colors.orange :
                                     e == 'POOR' ? Colors.deepOrange :
                                     Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Text(e),
                          ],
                        ),
                      )).toList(),
                      onChanged: (val) => setState(() => selectedCropCondition = val!),
                      decoration: InputDecoration(
                        labelText: "Crop Condition",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Feedback
                    TextField(
                      controller: feedbackController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Feedback *",
                        hintText: "Enter your feedback about the visit...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Recommendation
                    TextField(
                      controller: recommendationController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: "Recommendation *",
                        hintText: "Enter your recommendation for the farmer...",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Next Visit Date Picker
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        title: Text(
                          selectedNextVisitDate == null
                            ? "Select Next Visit Date *"
                            : "Next Visit: ${DateFormat('dd MMM yyyy').format(selectedNextVisitDate!)}",
                          style: TextStyle(
                            color: selectedNextVisitDate == null ? Colors.grey.shade600 : Colors.black87,
                          ),
                        ),
                        trailing: Icon(Icons.calendar_today, color: Colors.deepPurple.shade600),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 7)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                            builder: (context, child) => Theme(
                              data: ThemeData.light().copyWith(
                                primaryColor: Colors.deepPurple.shade600,
                                colorScheme: ColorScheme.light(primary: Colors.deepPurple.shade600),
                              ),
                              child: child!,
                            ),
                          );
                          if (date != null) setState(() => selectedNextVisitDate = date);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text("Cancel", style: TextStyle(color: Colors.grey.shade700)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (feedbackController.text.isEmpty) {
                      Get.snackbar("Notice", "Please enter feedback", backgroundColor: Colors.orange.shade100);
                      return;
                    }
                    if (recommendationController.text.isEmpty) {
                      Get.snackbar("Notice", "Please enter recommendation", backgroundColor: Colors.orange.shade100);
                      return;
                    }
                    if (selectedNextVisitDate == null) {
                      Get.snackbar("Notice", "Please select next visit date", backgroundColor: Colors.orange.shade100);
                      return;
                    }

                    Get.back();
                    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

                    final success = await controller.submitFeedback(
                      visitId: visit.id!,
                      feedback: feedbackController.text,
                      recommendation: recommendationController.text,
                      cropCondition: selectedCropCondition,
                      nextVisitDate: selectedNextVisitDate!.toUtc().toIso8601String(),
                    );

                    Get.back();
                    if (success) {
                      Get.snackbar("Success", "Feedback submitted successfully",
                        backgroundColor: Colors.green.shade100, colorText: Colors.green.shade900);
                    } else {
                      Get.snackbar("Error", "Failed to submit feedback",
                        backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
                    }
                  },
                  child: const Text("Submit", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
