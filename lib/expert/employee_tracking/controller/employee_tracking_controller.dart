import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:partener_app/expert/employee_tracking/repo/employee_tracking_service.dart';
import 'package:partener_app/expert/employee_tracking/view/work_image_capture_screen.dart';
import 'package:partener_app/services/background_location_service.dart';
import 'package:partener_app/services/shared_prefs.dart';

class EmployeeTrackingController extends GetxController {
  final EmployeeTrackingService _service = EmployeeTrackingService();

  RxBool isWorking = false.obs;
  RxBool isLoading = false.obs;
  RxBool isInitialStatusLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _checkInitialStatus();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> _checkInitialStatus() async {
    isInitialStatusLoading.value = true;
    try {
      bool status = await _service.checkCurrentStatus();
      isWorking.value = status;
      // Background service is managed by main.dart on app start.
      // If working, the service is already running (or was restored by _restoreBackgroundTrackingIfNeeded).
    } finally {
      isInitialStatusLoading.value = false;
    }
  }

  Future<void> toggleWorkStatus() async {
    isLoading.value = true;

    bool hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      isLoading.value = false;
      return;
    }

    Position? position = await _getCurrentPosition();
    if (position == null) {
      Get.snackbar(
        "Error",
        "Could not get current location.",
        backgroundColor: Colors.red.shade100,
      );
      isLoading.value = false;
      return;
    }

    String locationString = "${position.latitude},${position.longitude}";
    final resultData = await Get.to(() => WorkImageCaptureScreen(isStartingWork: !isWorking.value)) as Map<String, dynamic>?;
    
    if (resultData == null || resultData['images'] == null || (resultData['images'] as List).isEmpty) {
      Get.snackbar(
        "Notice",
        "Please select at least one image.",
        backgroundColor: Colors.orange.shade100,
      );
      isLoading.value = false;
      return;
    }

    final images = resultData['images'] as List<File>;
    final travelMeter = resultData['travel_meter'] as int? ?? 0;

    if (isWorking.value) {
      // End work
      final result = await _service.endWork(locationString, images, travelMeter);
      if (result.success) {
        isWorking.value = false;
        // ✅ Stop background service
        await stopBackgroundTracking();
        Get.snackbar(
          "Success",
          result.message,
          backgroundColor: Colors.green.shade100,
        );
      } else {
        Get.snackbar(
          "Error",
          result.message,
          backgroundColor: Colors.red.shade100,
        );
      }
    } else {
      // Start work
      final result = await _service.startWork(locationString, images, travelMeter);
      if (result.success) {
        isWorking.value = true;
        // ✅ Start background service (survives app close)
        final token = await SharedPrefs.getUserToken();
        if (token != null) {
          await startBackgroundTracking(token);
        }
        Get.snackbar(
          "Success",
          result.message,
          backgroundColor: Colors.green.shade100,
        );
      } else {
        Get.snackbar(
          "Error",
          result.message,
          backgroundColor: Colors.red.shade100,
        );
      }
    }
    
    isLoading.value = false;
  }

  // Location uploads are now handled by the background service (background_location_service.dart).
  // The background service runs in a separate isolate and survives app close.
  // WebSocket updates (when app is open) are handled by the background service's HTTP fallback.
  // If you need real-time WebSocket sync while the app is in the foreground,
  // the WebSocketController still handles it via its own connect/disconnect logic.

  Future<Position?> _getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (e) {
      log("❌ Error getting location: $e", name: 'employee_tracking');
      return null;
    }
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        "Notice",
        "Location services are disabled. Please enable them.",
        backgroundColor: Colors.orange.shade100,
      );
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          "Notice",
          "Location permissions are denied.",
          backgroundColor: Colors.orange.shade100,
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        "Notice",
        "Location permissions are permanently denied, we cannot request permissions.",
        backgroundColor: Colors.orange.shade100,
      );
      return false;
    }

    return true;
  }
}
