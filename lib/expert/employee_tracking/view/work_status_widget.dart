import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:partener_app/expert/employee_tracking/controller/employee_tracking_controller.dart';

class WorkStatusWidget extends StatelessWidget {
  const WorkStatusWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Put controller if not already present
    final controller = Get.put(EmployeeTrackingController());

    return Obx(() {
      final isWorking = controller.isWorking.value;
      final isLoading = controller.isLoading.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : ElevatedButton.icon(
                onPressed: () => controller.toggleWorkStatus(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isWorking ? Colors.red.shade600 : Colors.green.shade600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                ),
                icon: Icon(
                  isWorking ? Icons.stop_circle_outlined : Icons.play_circle_outline,
                  size: 18,
                ),
                label: Text(
                  isWorking ? "End Work" : "Start Work",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
      );
    });
  }
}
