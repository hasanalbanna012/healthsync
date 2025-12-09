import 'package:flutter/material.dart';

class AppPalette {
  final Color primary;
  final Color primaryLight;
  final Color primaryDark;
  final Color secondary;
  final Color secondaryLight;
  final Color secondaryDark;
  final Color background;
  final Color surface;
  final Color card;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const AppPalette({
    required this.primary,
    required this.primaryLight,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryLight,
    required this.secondaryDark,
    required this.background,
    required this.surface,
    required this.card,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  static const AppPalette defaultPalette = AppPalette(
    primary: Color.fromARGB(255, 32, 143, 102),
    primaryLight: Color(0xFF4CAF7A),
    primaryDark: Color(0xFF1B6B4F),
    secondary: Color(0xFF2E7D5A),
    secondaryLight: Color(0xFF66BB8A),
    secondaryDark: Color(0xFF1A5A42),
    background: Color.fromARGB(255, 251, 251, 247),
    surface: Color(0xFFFFFFFF),
    card: Color.fromARGB(255, 255, 255, 255),
    divider: Color(0xFFE8F2EE),
    textPrimary: Color(0xFF1A4A38),
    textSecondary: Color(0xFF4A6B5D),
    textDisabled: Color(0xFF8FA99A),
    success: Color(0xFF2E7D5A),
    warning: Color(0xFFFF9800),
    error: Color(0xFFE53935),
    info: Color(0xFF218D66),
  );

  AppPalette copyWith({
    Color? primary,
    Color? primaryLight,
    Color? primaryDark,
    Color? secondary,
    Color? secondaryLight,
    Color? secondaryDark,
    Color? background,
    Color? surface,
    Color? card,
    Color? divider,
    Color? textPrimary,
    Color? textSecondary,
    Color? textDisabled,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return AppPalette(
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      primaryDark: primaryDark ?? this.primaryDark,
      secondary: secondary ?? this.secondary,
      secondaryLight: secondaryLight ?? this.secondaryLight,
      secondaryDark: secondaryDark ?? this.secondaryDark,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      card: card ?? this.card,
      divider: divider ?? this.divider,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textDisabled: textDisabled ?? this.textDisabled,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  AppPalette lerp(AppPalette other, double t) {
    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t) ?? a;

    return AppPalette(
      primary: lerpColor(primary, other.primary),
      primaryLight: lerpColor(primaryLight, other.primaryLight),
      primaryDark: lerpColor(primaryDark, other.primaryDark),
      secondary: lerpColor(secondary, other.secondary),
      secondaryLight: lerpColor(secondaryLight, other.secondaryLight),
      secondaryDark: lerpColor(secondaryDark, other.secondaryDark),
      background: lerpColor(background, other.background),
      surface: lerpColor(surface, other.surface),
      card: lerpColor(card, other.card),
      divider: lerpColor(divider, other.divider),
      textPrimary: lerpColor(textPrimary, other.textPrimary),
      textSecondary: lerpColor(textSecondary, other.textSecondary),
      textDisabled: lerpColor(textDisabled, other.textDisabled),
      success: lerpColor(success, other.success),
      warning: lerpColor(warning, other.warning),
      error: lerpColor(error, other.error),
      info: lerpColor(info, other.info),
    );
  }
}

class AppPaletteExtension extends ThemeExtension<AppPaletteExtension> {
  final AppPalette palette;

  const AppPaletteExtension(this.palette);

  @override
  AppPaletteExtension copyWith({AppPalette? palette}) {
    return AppPaletteExtension(palette ?? this.palette);
  }

  @override
  AppPaletteExtension lerp(AppPaletteExtension? other, double t) {
    if (other == null) return this;
    return AppPaletteExtension(palette.lerp(other.palette, t));
  }
}
