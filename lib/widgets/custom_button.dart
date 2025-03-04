import 'package:flutter/material.dart';
import '../utils/constants.dart'; // ✅ Import constants

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? color;

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.borderRadius = 25.0, // ✅ Default border radius
    this.padding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 12,
    ), // ✅ Default padding
    this.color, // ✅ Custom color support
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              color ?? AppColors.buttonColor, // ✅ Use default or custom color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius,
            ), // ✅ Apply border radius
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 16, color: AppColors.white),
        ),
      ),
    );
  }
}
