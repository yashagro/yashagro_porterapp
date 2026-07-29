import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:partener_app/marketer/repo/marketer_dashboard_service.dart';
import 'package:partener_app/services/shared_prefs.dart';

class MarketerMarkVisitController extends GetxController {
  final MarketerDashboardService _service = MarketerDashboardService();

  var isLoading = false.obs;
  var isFetching = false.obs;
  var visits = <dynamic>[].obs;
  
  var selectedType = 'FARM_VISIT'.obs;
  var remarksController = TextEditingController();
  
  @override
  void onInit() {
    super.onInit();
    fetchVisits();
  }

  Future<void> fetchVisits() async {
    isFetching.value = true;
    try {
      final data = await _service.getMarketerVisits();
      visits.value = data;
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch visits');
    } finally {
      isFetching.value = false;
    }
  }

  // Farm Visit fields
  var farmNameController = TextEditingController();
  var cropsController = TextEditingController(); // Comma separated

  // Customer Visit fields
  var customerNameController = TextEditingController();
  var amountController = TextEditingController();

  var selectedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  Future<void> pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      selectedImages.addAll(images.map((e) => File(e.path)));
    }
  }
  
  Future<void> captureImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      selectedImages.add(File(image.path));
    }
  }

  void removeImage(int index) {
    selectedImages.removeAt(index);
  }

  Future<void> submitVisit() async {
    if (remarksController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter remarks');
      return;
    }

    isLoading.value = true;
    try {
      int? employeeId = await SharedPrefs.getUserId();
      if (employeeId == null) {
        Get.snackbar('Error', 'Employee ID not found');
        return;
      }

      Position position = await _determinePosition();
      
      Map<String, dynamic> payload = {};
      if (selectedType.value == 'FARM_VISIT') {
        if (farmNameController.text.trim().isNotEmpty) {
          payload['farm_name'] = farmNameController.text.trim();
        }
        final crops = cropsController.text.split(',').map((e) => e.trim()).where((c) => c.isNotEmpty).toList();
        if (crops.isNotEmpty) {
          payload['crops'] = crops;
        }
        payload['images'] = selectedImages.map((e) => e.path.split('/').last).toList();
      } else {
        if (customerNameController.text.trim().isNotEmpty) {
          payload['customer_name'] = customerNameController.text.trim();
        }
        if (amountController.text.trim().isNotEmpty) {
          payload['amount'] = int.tryParse(amountController.text.trim()) ?? 0;
        }
        payload['photos'] = selectedImages.map((e) => e.path.split('/').last).toList();
      }

      Map<String, dynamic> requestData = {
        'employee_id': employeeId,
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'type': selectedType.value,
        'remarks': remarksController.text.trim(),
        'payload': payload
      };

      final response = await _service.createMarketerVisit(requestData);
      
      if (response['success'] == true || response['data'] != null) {
        Get.snackbar(
          'Success', 
          'Visit marked successfully', 
          backgroundColor: Colors.green, 
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        // Clear fields
        remarksController.clear();
        farmNameController.clear();
        cropsController.clear();
        customerNameController.clear();
        amountController.clear();
        selectedImages.clear();
        
        // Refresh visits list
        fetchVisits();
      } else {
        Get.snackbar('Error', 'Failed to mark visit');
      }

    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When LocationAccuracy.high is used, it might take a while. We can just use medium or low for speed, but high is fine.
    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
  }
}
