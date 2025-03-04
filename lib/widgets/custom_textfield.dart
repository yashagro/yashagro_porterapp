import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final bool obscureText;

  const CustomTextField({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
    this.borderRadius = 25.0, // ✅ Default border radius
    this.padding = const EdgeInsets.symmetric(
      vertical: 10,
    ), // ✅ Default padding
    this.obscureText = false, // ✅ Allow password fields
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText, // ✅ Toggle for password fields
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: AppColors.textFieldFill, // ✅ Light Grey Fill
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: AppColors.textFieldFocus,
            width: 1.5,
          ), // ✅ Slightly Darker on Focus
        ),
      ),
    );
  }
}
