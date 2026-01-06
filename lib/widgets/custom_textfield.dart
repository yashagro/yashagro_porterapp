import 'package:flutter/material.dart';
import '../utils/constants.dart';
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final double borderRadius;
  final bool obscureText;

  const CustomTextField({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.borderRadius = 30.0,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 15,
    color: Colors.black,
  ),
      decoration: InputDecoration(

        /// ✅ USE HINT INSTEAD OF LABEL
        hintText: label,
        hintStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          fontSize: 14,
        ),

        filled: true,
        fillColor: AppColors.textFieldFill,

        contentPadding: const EdgeInsets.all(14),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: AppColors.textFieldFocus,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
