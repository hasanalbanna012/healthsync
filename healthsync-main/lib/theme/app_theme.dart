import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_constants.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppConstants.primaryColor,
        brightness: Brightness.light,
        primary: const Color.fromARGB(255, 238, 147, 11),
        onPrimary: Colors.white,
        secondary: const Color.fromARGB(255, 247, 124, 9),
        onSecondary: Colors.white,
        error: AppConstants.errorColor,
        onError: Colors.white,
        surface: AppConstants.surfaceColor,
        onSurface: AppConstants.textPrimaryColor,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: AppConstants.elevationLow,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card Theme
      cardTheme: const CardThemeData(
        color: AppConstants.cardColor,
        elevation: AppConstants.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
              Radius.circular(AppConstants.borderRadiusMedium)),
        ),
        margin: EdgeInsets.all(AppConstants.spacingSmall),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: Colors.white,
          elevation: AppConstants.elevationLow,
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color.fromARGB(255, 231, 73, 11),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMedium,
            vertical: AppConstants.spacingSmall,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.primaryColor,
          side: const BorderSide(color: AppConstants.primaryColor),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLarge,
            vertical: AppConstants.spacingMedium,
          ),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: AppConstants.primaryColor,
        unselectedItemColor: AppConstants.textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: AppConstants.elevationMedium,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: AppConstants.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppConstants.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppConstants.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide: const BorderSide(color: AppConstants.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          borderSide:
              const BorderSide(color: AppConstants.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.spacingMedium),
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppConstants.dividerColor,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppConstants.textSecondaryColor,
        size: 24,
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: TextStyle(
          color: AppConstants.textSecondaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: 16,
          fontWeight: FontWeight.normal,
        ),
        bodyMedium: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        bodySmall: TextStyle(
          color: AppConstants.textSecondaryColor,
          fontSize: 12,
          fontWeight: FontWeight.normal,
        ),
        labelLarge: TextStyle(
          color: AppConstants.textPrimaryColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          color: AppConstants.textSecondaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: TextStyle(
          color: AppConstants.textDisabledColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),

      // SnackBar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppConstants.textPrimaryColor,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Custom color extensions for easy access
extension AppColorsExtension on BuildContext {
  Color get primaryColor => AppConstants.primaryColor;
  Color get accentColor => AppConstants.accentColor;
  Color get successColor => AppConstants.successColor;
  Color get errorColor => AppConstants.errorColor;
  Color get warningColor => AppConstants.warningColor;
  Color get backgroundColor => AppConstants.backgroundColor;
  Color get cardColor => AppConstants.cardColor;
}
