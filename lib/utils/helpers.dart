import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// **Show Success Message**
void showSuccessSnackbar(String message) {
  Get.snackbar("Success", message, backgroundColor: Colors.green, colorText: Colors.white);
}

/// **Show Error Message**
void showErrorSnackbar(String message) {
  Get.snackbar("Error", message, backgroundColor: Colors.red, colorText: Colors.white);
}
