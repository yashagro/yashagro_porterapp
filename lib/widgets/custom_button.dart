import 'package:flutter/material.dart';
import '../utils/constants.dart'; // ✅ Import constants

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final bool isLoading;

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.borderRadius = 25.0, // ✅ Default border radius
    this.padding = const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 12,
    ), // ✅ Default padding
    this.color, // ✅ Custom color support
    this.isLoading = false, // ✅ Loading state support
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? () {} : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              color ?? AppColors.buttonColor, // ✅ Use default or custom color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius,
            ), // ✅ Apply border radius
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: TextStyle(fontSize: 16, color: AppColors.white),
              ),
      ),
    );
  }
}
