import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'HealthSync';
  static const String appVersion = '1.0.0';

  // Primary Brand Colors (Healthcare green-inspired palette)
  static const Color primaryColor = Color(0xFF218D66); // Primary green
  static const Color primaryLightColor = Color(0xFF4CAF7A); // Light green
  static const Color primaryDarkColor = Color(0xFF1B6B4F); // Dark green
  
  // Secondary Colors
  static const Color accentColor = Color(0xFF2E7D5A); // Complementary green
  static const Color accentLightColor = Color(0xFF66BB8A); // Light accent green
  static const Color accentDarkColor = Color(0xFF1A5A42); // Dark accent green
  
  // Status Colors
  static const Color successColor = Color(0xFF2E7D5A); // Success green (matching theme)
  static const Color warningColor = Color(0xFFFF9800); // Orange
  static const Color errorColor = Color(0xFFE53935); // Red
  static const Color infoColor = Color(0xFF218D66); // Info green (primary)
  
  // Neutral Colors
  static const Color backgroundColor = Color(0xFFF7FBF9); // Very light green-tinted background
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  static const Color cardColor = Color(0xFFFAFDFC); // Very light green-tinted card
  static const Color dividerColor = Color(0xFFE8F2EE); // Light green-tinted divider
  
  // Text Colors
  static const Color textPrimaryColor = Color(0xFF1A4A38); // Dark green-gray
  static const Color textSecondaryColor = Color(0xFF4A6B5D); // Medium green-gray
  static const Color textDisabledColor = Color(0xFF8FA99A); // Light green-gray
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLightColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, accentLightColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Spacing
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;

  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;
  
  // Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Image Settings
  static const int imageQuality = 80;
  static const double imageMaxWidth = 1024;
  static const double imageMaxHeight = 1024;

  // Box Names
  static const String prescriptionsBox = 'prescriptions';
  static const String testReportsBox = 'test_reports';

  // Messages
  static const String prescriptionAddedMessage =
      'Prescription added successfully';
  static const String testReportAddedMessage = 'Test report added successfully';
  static const String imagePickErrorMessage = 'Error picking image';
  static const String noTextDetectedMessage = 'No text detected';

  // Feature Messages
  static const String notificationsComingSoon =
      'Notifications feature coming soon!';
  static const String hospitalComingSoon =
      'Nearby Hospitals feature coming soon!';
  static const String profileComingSoon = 'Profile feature coming soon!';

  // API Keys (consider securing these for production)
  static const String googleMapsApiKey = 'AIzaSyBTVCjXm4JLZeVSmdwkgKqzwk86uVjcQEI';
}

class AppStrings {
  // Navigation
  static const String home = 'Home';
  static const String notifications = 'Notifications';
  static const String nearbyHospital = 'Nearby Hospital';
  static const String me = 'Me';

  // Sections
  static const String medicine = 'Medicine';
  static const String alarm = 'Alarm';
  static const String doctors = 'Doctors';
  static const String testReports = 'Test Reports';
  static const String prescriptions = 'Prescriptions';
  static const String healthIndex = 'Health Index';

  // Actions
  static const String takePhoto = 'Take Photo';
  static const String chooseFromGallery = 'Choose from Gallery';
  static const String detectedText = 'Detected Text';
}
