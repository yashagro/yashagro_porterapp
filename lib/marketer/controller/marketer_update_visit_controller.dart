import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:partener_app/marketer/repo/marketer_dashboard_service.dart';
import 'package:partener_app/marketer/controller/marketer_mark_visit_controller.dart';
import 'package:partener_app/services/shared_prefs.dart';

class MarketerUpdateVisitController extends GetxController {
  final Map<String, dynamic> visitData;
  final MarketerDashboardService _service = MarketerDashboardService();

  MarketerUpdateVisitController({required this.visitData});

  var isLoading = false.obs;
  late RxString selectedType;
  var remarksController = TextEditingController();
  
  // Farm Visit fields
  var farmNameController = TextEditingController();
  var cropsController = TextEditingController(); // Comma separated

  // Customer Visit fields
  var customerNameController = TextEditingController();
  var amountController = TextEditingController();

  var selectedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    selectedType = (visitData['type']?.toString() ?? 'FARM_VISIT').obs;
    remarksController.text = visitData['remarks']?.toString() ?? '';
    
    final payload = visitData['payload'];
    if (payload != null && payload is Map) {
      if (selectedType.value == 'FARM_VISIT') {
        farmNameController.text = payload['farm_name']?.toString() ?? '';
        final crops = payload['crops'];
        if (crops != null) {
          if (crops is List) {
             cropsController.text = crops.join(', ');
          } else {
             cropsController.text = crops.toString();
          }
        }
      } else {
        customerNameController.text = payload['customer_name']?.toString() ?? '';
        amountController.text = payload['amount']?.toString() ?? '';
      }
    }
  }

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

  Future<void> submitUpdate() async {
    if (remarksController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter remarks');
      return;
    }

    isLoading.value = true;
    try {
      final id = visitData['id'];
      if (id == null) {
        throw Exception("Visit ID is missing");
      }

      int? employeeId = await SharedPrefs.getUserId();
      if (employeeId == null) {
        Get.snackbar('Error', 'Employee ID not found');
        return;
      }
      
      Map<String, dynamic> payload = {};
      if (selectedType.value == 'FARM_VISIT') {
        if (farmNameController.text.trim().isNotEmpty) {
          payload['farm_name'] = farmNameController.text.trim();
        }
        final crops = cropsController.text.split(',').map((e) => e.trim()).where((c) => c.isNotEmpty).toList();
        if (crops.isNotEmpty) {
          payload['crops'] = crops;
        }
        
        List<String> images = selectedImages.map((e) => e.path.split('/').last).toList();
        if (images.isEmpty) {
           final existingPayload = visitData['payload'];
           if (existingPayload is Map && existingPayload['images'] != null) {
              images = List<String>.from(existingPayload['images']);
           }
        }
        payload['images'] = images;
      } else {
        if (customerNameController.text.trim().isNotEmpty) {
          payload['customer_name'] = customerNameController.text.trim();
        }
        if (amountController.text.trim().isNotEmpty) {
          payload['amount'] = int.tryParse(amountController.text.trim()) ?? 0;
        }
        
        List<String> photos = selectedImages.map((e) => e.path.split('/').last).toList();
        if (photos.isEmpty) {
           final existingPayload = visitData['payload'];
           if (existingPayload is Map && existingPayload['photos'] != null) {
              photos = List<String>.from(existingPayload['photos']);
           }
        }
        payload['photos'] = photos;
      }

      Map<String, dynamic> requestData = {
        'employee_id': visitData['employee_id'] ?? employeeId,
        'latitude': visitData['latitude']?.toString() ?? '0.0',
        'longitude': visitData['longitude']?.toString() ?? '0.0',
        'type': selectedType.value,
        'remarks': remarksController.text.trim(),
        'payload': payload
      };

      final response = await _service.updateMarketerVisit(id, requestData);
      
      if (response['success'] == true || response['data'] != null) {
        Get.back(); // close update screen
        Get.snackbar(
          'Success', 
          'Visit updated successfully', 
          backgroundColor: Colors.green, 
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        // Refresh visits list in the main screen
        try {
          Get.find<MarketerMarkVisitController>().fetchVisits();
        } catch (e) {
           // Controller not found, ignore
        }
      } else {
        Get.snackbar('Error', 'Failed to update visit');
      }

    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
