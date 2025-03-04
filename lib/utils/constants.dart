import 'package:flutter/material.dart';

/// **App Colors**
class AppColors {
  // Main Green
  static const Color primary = Color(0xFF1D6B4F);
  // Light Green Accent
  static const Color secondary = Color(0xFFA7F2CF);
  static const Color background = Color(0xFF1D6B4F);
  // Dark Green Text
  static const Color textPrimary = Color(0xFF0A4222);
  // Muted Green
  static const Color textSecondary = Color(0xFF4F795A);
  // Soft Green Background
  static const Color cardBackground = Color(0xFF1D6B4F);
  // Light Greyish Green
  static const Color borderColor = Color(0xFFD3E0DC);
  // Green Button
  static const Color buttonColor = Color(0xFF2E7D32);
  // ✅ Highlighted Teal Color
  static const Color accent = Color(0xFF00796B);
  // Grey Disabled Color
  static const Color disabled = Color(0xFFB0BEC5);
  static const Color white = Colors.white;
  // ✅ Light Grey Fill for TextField
  static const Color textFieldFill = Color(0xFFE0E0E0);
  // ✅ Slightly Darker Grey on Click
  static const Color textFieldFocus = Color(0xFFBDBDBD);
}

/// **App Fonts**
class AppFonts {
  static const String primaryFont = "CircularStd";
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
    color: AppColors.white,
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
    color: AppColors.white,
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

  static const TextStyle highlightedText = TextStyle(
    fontFamily: AppFonts.primaryFont,
    fontSize: 16,
    fontWeight: FontWeightManager.bold,
    color: AppColors.accent, // ✅ Highlighted Teal Color
  );
}

/// **API Endpoints**
class ApiConstants {
  static const String baseUrl = "https://api.yourapp.com/";
  static const String login = "${baseUrl}auth/login";
  static const String register = "${baseUrl}auth/register";
  static const String fetchUserData = "${baseUrl}user/profile";
  static const String getTasks = "${baseUrl}tasks";
}

/// **SharedPreferences Keys**
class PrefsKeys {
  static const String isLoggedIn = "is_logged_in";
  static const String userRole = "user_role";
  static const String authToken = "auth_token";
}

/// **Image Paths**
class AppImages {
  static const String logo = "assets/images/logo.png";
  static const String profilePlaceholder =
      "assets/images/profile_placeholder.png";
  static const String weatherIcon = "assets/images/weather_icon.png";
}

/// **Default UI Values**
class Defaults {
  static const double borderRadius = 12.0;
  static const double padding = 16.0;
  static const double iconSize = 24.0;
}
