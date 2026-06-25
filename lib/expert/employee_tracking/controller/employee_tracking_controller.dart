import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:partener_app/expert/chats/controller/web_socket_controller.dart';
import 'package:partener_app/expert/employee_tracking/repo/employee_tracking_service.dart';

class EmployeeTrackingController extends GetxController {
  final EmployeeTrackingService _service = EmployeeTrackingService();
  final Battery _battery = Battery();

  RxBool isWorking = false.obs;
  RxBool isLoading = false.obs;
  Timer? _locationTimer;

  @override
  void onInit() {
    super.onInit();
    _checkInitialStatus();
  }

  @override
  void onClose() {
    _locationTimer?.cancel();
    super.onClose();
  }

  Future<void> _checkInitialStatus() async {
    bool status = await _service.checkCurrentStatus();
    isWorking.value = status;
    if (status) {
      _startLocationTimer();
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

    if (isWorking.value) {
      // End work
      bool success = await _service.endWork(locationString);
      if (success) {
        isWorking.value = false;
        _stopLocationTimer();
        Get.snackbar(
          "Success",
          "Work ended successfully",
          backgroundColor: Colors.green.shade100,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to end work",
          backgroundColor: Colors.red.shade100,
        );
      }
    } else {
      // Start work
      bool success = await _service.startWork(locationString);
      if (success) {
        isWorking.value = true;
        _startLocationTimer();
        Get.snackbar(
          "Success",
          "Work started successfully",
          backgroundColor: Colors.green.shade100,
        );
      } else {
        Get.snackbar(
          "Error",
          "Failed to start work",
          backgroundColor: Colors.red.shade100,
        );
      }
    }
    isLoading.value = false;
  }

  void _startLocationTimer() {
    _locationTimer?.cancel();
    _locationTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _sendLocationUpdate();
    });
  }

  void _stopLocationTimer() {
    _locationTimer?.cancel();
  }

  Future<void> _sendLocationUpdate() async {
    Position? position = await _getCurrentPosition();
    if (position == null) {
      log(
        "❌ Skipping location sync because current position is unavailable.",
        name: 'employee_tracking',
      );
      return;
    }

    int batteryLevel = await _battery.batteryLevel;
    final location = "${position.latitude},${position.longitude}";

    log(
      "📍 Preparing location sync. location=$location, accuracy=${position.accuracy}, battery=$batteryLevel, speed=${position.speed}",
      name: 'employee_tracking',
    );

    final webSocketController =
        Get.isRegistered<WebSocketController>()
            ? Get.find<WebSocketController>()
            : Get.put(WebSocketController());

    final syncedViaSocket = await webSocketController.sendLocationUpdate(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      batteryPercentage: batteryLevel,
      speed: position.speed,
    );

    if (syncedViaSocket) {
      log("✅ Location synced via websocket.", name: 'employee_tracking');
      return;
    }

    log(
      "⚠️ Websocket sync failed. Falling back to location API.",
      name: 'employee_tracking',
    );

    final syncedViaApi = await _service.updateLocation(
      location: location,
      accuracy: position.accuracy,
      batteryPercentage: batteryLevel,
      speed: position.speed,
    );

    if (syncedViaApi) {
      log("✅ Location synced via API fallback.", name: 'employee_tracking');
    } else {
      log(
        "❌ Location sync failed on both websocket and API.",
        name: 'employee_tracking',
      );
    }
  }

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
