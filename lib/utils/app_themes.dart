import 'package:flutter/material.dart';

/// **App Colors**
class AppColors {
  static const Color primary = Color(0xFF1D6B4F); // Deep Green
  static const Color secondary = Color.fromARGB(
    255,
    167,
    242,
    207,
  ); // Light Green
  static const Color background = Color(0xFFEFF8F1); // Soft Background Green
  static const Color textPrimary = Color(0xFF0A4222); // Dark Green for Text
  static const Color textSecondary = Color(0xFF4F795A); // Medium Green Text
  static const Color cardBackground = Color(0xFFF5FFF8); // Softest Green
  static const Color borderColor = Color(0xFFD3E0DC); // Greyish Green
  static const Color buttonColor = Color(0xFF2E7D32);
  static const Color accent = Color(0xFF388E3C); // Slightly Brighter Green
  static const Color disabled = Color(0xFFB0BEC5); // Muted Greyish-Green
  static const Color baground = Colors.white;
}

/// **App Fonts**
class AppFonts {
  static const String primaryFont = "CircularStd"; // Adjust if needed
}

/// **Font Weights**
class FontWeightManager {
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;
}

/// **Text Styles**
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: 22,
    fontWeight: FontWeightManager.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subHeading = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: 18,
    fontWeight: FontWeightManager.medium,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: 16,
    fontWeight: FontWeightManager.regular,
    color: AppColors.textSecondary,
  );

  static const TextStyle smallText = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: 14,
    fontWeight: FontWeightManager.light,
    color: AppColors.textSecondary,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: 16,
    fontWeight: FontWeightManager.medium,
    color: Colors.white,
  );
}

/// **App Theme**
ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  primaryColor: AppColors.primary,
  fontFamily: AppFonts.primaryFont,

  /// **AppBar Theme**
  appBarTheme: AppBarTheme(
    color: AppColors.primary,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: AppTextStyles.heading.copyWith(color: Colors.white),
  ),

  /// **Text Theme**
  textTheme: TextTheme(
    bodyLarge: AppTextStyles.bodyText,
    bodyMedium: AppTextStyles.smallText,
    titleLarge: AppTextStyles.heading,
    titleMedium: AppTextStyles.subHeading,
  ),

  /// **Button Theme**
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.buttonColor,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      textStyle: AppTextStyles.buttonText,
    ),
  ),

  /// **Input Field Theme**
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: AppColors.cardBackground,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: AppColors.accent),
    ),
  ),

  /// **Bottom Navigation Bar**
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
    showSelectedLabels: true,
    showUnselectedLabels: true,
  ),
);
