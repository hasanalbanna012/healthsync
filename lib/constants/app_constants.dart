import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import 'design_tokens.dart';

class AppConstants {
  // App Info
  static const String appName = 'HealthSync';
  static const String appVersion = '1.0.0';

  // Color palette (change values in AppPalette.defaultPalette)
  static AppPalette palette = AppPalette.defaultPalette;

  // Primary Brand Colors (Healthcare green-inspired palette)
  static Color get primaryColor => palette.primary;
  static Color get primaryLightColor => palette.primaryLight;
  static Color get primaryDarkColor => palette.primaryDark;

  // Secondary Colors
  static Color get accentColor => palette.secondary;
  static Color get accentLightColor => palette.secondaryLight;
  static Color get accentDarkColor => palette.secondaryDark;

  // Status Colors
  static Color get successColor => palette.success;
  static Color get warningColor => palette.warning;
  static Color get errorColor => palette.error;
  static Color get infoColor => palette.info;

  // Neutral Colors
  static Color get backgroundColor => palette.background;
  static Color get surfaceColor => palette.surface;
  static Color get cardColor => palette.card;
  static Color get dividerColor => palette.divider;

  // Text Colors
  static Color get textPrimaryColor => palette.textPrimary;
  static Color get textSecondaryColor => palette.textSecondary;
  static Color get textDisabledColor => palette.textDisabled;

  // Gradient Colors
  static LinearGradient get primaryGradient => LinearGradient(
        colors: [primaryColor, primaryLightColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get accentGradient => LinearGradient(
        colors: [accentColor, accentLightColor],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Spacing
  static const double spacingSmall = DesignTokens.spacingSmall;
  static const double spacingMedium = DesignTokens.spacingMedium;
  static const double spacingLarge = DesignTokens.spacingLarge;
  static const double spacingXLarge = DesignTokens.spacingXLarge;

  // Border Radius
  static const double borderRadiusSmall = DesignTokens.borderRadiusSmall;
  static const double borderRadiusMedium = DesignTokens.borderRadiusMedium;
  static const double borderRadiusLarge = DesignTokens.borderRadiusLarge;
  static const double borderRadiusXLarge = DesignTokens.borderRadiusXLarge;

  // Elevation
  static const double elevationLow = DesignTokens.elevationLow;
  static const double elevationMedium = DesignTokens.elevationMedium;
  static const double elevationHigh = DesignTokens.elevationHigh;

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
  static const String googleMapsApiKey =
      'AIzaSyBTVCjXm4JLZeVSmdwkgKqzwk86uVjcQEI';
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
