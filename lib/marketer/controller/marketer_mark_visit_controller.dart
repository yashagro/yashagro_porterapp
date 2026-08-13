import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:partener_app/marketer/repo/marketer_dashboard_service.dart';
import 'package:partener_app/services/shared_prefs.dart';

class MarketerMarkVisitController extends GetxController {
  final MarketerDashboardService _service = MarketerDashboardService();

  var isLoading = false.obs;
  var isFetching = false.obs;
  var visits = <dynamic>[].obs;
  
  var selectedType = 'FARM_VISIT'.obs; // FARM_VISIT or CUSTOMER_VISIT
  var remarksController = TextEditingController();
  
  // Farm Visit fields
  var farmCustomerNameController = TextEditingController();
  var farmMobileNumberController = TextEditingController();
  var farmCropNameController = TextEditingController();
  var farmVarietyController = TextEditingController();
  var farmPlotAgeController = TextEditingController();

  // Store Visit fields
  var storeOwnerNameController = TextEditingController();
  var storeContactNumberController = TextEditingController();
  var storeSizeController = TextEditingController();

  // Device Contacts lists
  var allContacts = <Contact>[].obs;
  var filteredContacts = <Contact>[].obs;
  var isContactsPermissionGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVisits();
    fetchDeviceContacts();
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

  Future<void> fetchDeviceContacts() async {
    try {
      final hasPermission = await FlutterContacts.permissions.has(PermissionType.read);
      if (hasPermission || (await FlutterContacts.permissions.request(PermissionType.read)) == PermissionStatus.granted) {
        isContactsPermissionGranted.value = true;
        final contacts = await FlutterContacts.getAll(
          properties: {ContactProperty.name, ContactProperty.phone},
        );
        allContacts.assignAll(contacts);
      } else {
        isContactsPermissionGranted.value = false;
      }
    } catch (e) {
      log('Error reading device contacts: $e');
    }
  }

  void filterContacts(String query) {
    if (query.trim().isEmpty) {
      filteredContacts.clear();
      return;
    }
    
    final lowercaseQuery = query.toLowerCase();
    final matches = allContacts.where((contact) {
      final name = (contact.displayName ?? '').toLowerCase();
      final hasMatchingPhone = contact.phones.any((phone) {
        final normalizedPhone = phone.number.replaceAll(RegExp(r'\D'), '');
        return normalizedPhone.contains(lowercaseQuery);
      });
      return name.contains(lowercaseQuery) || hasMatchingPhone;
    }).toList();

    filteredContacts.assignAll(matches.take(8));
  }

  Future<bool> submitVisit() async {
    isLoading.value = true;
    try {
      int? employeeId = await SharedPrefs.getUserId();
      if (employeeId == null) {
        Get.snackbar('Error', 'Employee ID not found');
        return false;
      }

      Position position = await _determinePosition();
      
      Map<String, dynamic> payload = {};
      if (selectedType.value == 'FARM_VISIT') {
        payload['customer_name'] = farmCustomerNameController.text.trim();
        payload['mobile_no'] = farmMobileNumberController.text.trim();
        payload['crop_name'] = farmCropNameController.text.trim();
        payload['variety'] = farmVarietyController.text.trim();
        payload['plot_age'] = farmPlotAgeController.text.trim();
      } else {
        payload['customer_name'] = storeOwnerNameController.text.trim();
        payload['mobile_no'] = storeContactNumberController.text.trim();
        payload['size_of_store'] = storeSizeController.text.trim();
      }

      String remarkText = remarksController.text.trim();
      if (remarkText.isEmpty) {
        remarkText = "Visit Marked";
      }

      Map<String, dynamic> requestData = {
        'employee_id': employeeId,
        'latitude': position.latitude.toString(),
        'longitude': position.longitude.toString(),
        'type': selectedType.value,
        'remarks': remarkText,
        'payload': payload
      };

      final response = await _service.createMarketerVisit(requestData);
      
      if (response['success'] == true || response['data'] != null) {
        remarksController.clear();
        farmCustomerNameController.clear();
        farmMobileNumberController.clear();
        farmCropNameController.clear();
        farmVarietyController.clear();
        farmPlotAgeController.clear();
        storeOwnerNameController.clear();
        storeContactNumberController.clear();
        storeSizeController.clear();
        
        fetchVisits();
        return true;
      } else {
        Get.snackbar('Error', 'Failed to mark visit');
      }

    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
    return false;
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

    return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
  }
}
