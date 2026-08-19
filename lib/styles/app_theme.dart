import 'package:flutter/material.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/styles/text_styles.dart';

/// Thème global de l'application
class AppTheme {
  // ── Colors ──────────────────────────────────────
  static const primaryColor = AppColors.blueBic;
  static const secondaryColor = AppColors.yellowColor;
  static const accentColor = AppColors.greenTGTG;
  static const coastalInk = Color(0xFF072E33);
  static const lagoon = Color(0xFF0E5A61);
  static const reef = Color(0xFF16866D);
  static const saffron = Color(0xFFE7B75F);
  static const coral = Color(0xFFE56A54);
  static const errorColor = Color(0xFFD84A3A);
  static const warningColor = Color(0xFFC87925);
  static const mutedSurface = Color(0xFFF5F8F7);
  static const elevatedSurface = Color(0xFFFFFFFF);
  static const softBorder = Color(0xFFDDE8E5);

  static const Color textPrimary = Color(0xFF102D31);
  static const Color textSecondary = Color(0xFF607377);
  static const Color textHint = Color(0xFF9DAEB1);

  static const Color dividerColor = Color(0xFFE1E9E7);
  static const Color backgroundColor = Color(0xFFF7FAF9);

  // ── Spacing ─────────────────────────────────────
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;

  // ── Border Radius ────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXL = 24.0;

  // ── Shadows ──────────────────────────────────────
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: coastalInk.withValues(alpha: 0.14),
      blurRadius: 28,
      offset: const Offset(0, 14),
    ),
  ];

  // ── Material Theme ────────────────────────────────
  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    colorScheme: ColorScheme(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: elevatedSurface,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: coastalInk,
      onSurface: textPrimary,
      onError: Colors.white,
      brightness: Brightness.light,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.subtitleM.copyWith(color: textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      hintStyle: AppTextStyles.hintText,
      contentPadding: const EdgeInsets.symmetric(horizontal: lg, vertical: lg),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: softBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: softBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: reef, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: errorColor, width: 1.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: primaryColor.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(horizontal: lg, vertical: lg),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        elevation: 1,
        textStyle: AppTextStyles.subtitleS.copyWith(color: Colors.white),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: md, vertical: md),
        textStyle: AppTextStyles.captionL,
      ),
    ),
    dividerTheme: const DividerThemeData(color: dividerColor, thickness: 1),
  );
}
