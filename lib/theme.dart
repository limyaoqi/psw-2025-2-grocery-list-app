import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4CAF50); // Primary color (green)
  static const Color accent = Color(0xFFFFA726); // Accent color (orange)
  static const Color background = Color(0xFFF9F9F9); // Background color
  static const Color fontPrimary = Color(
    0xFF212121,
  ); // Primary font color (dark)
  static const Color fontSecondary = Color(
    0xFF333333,
  ); // Secondary font color (lighter)
  static const Color completedText = Color(
    0xFF9E9E9E,
  ); // Completed item text color (grey)
  static const Color completedBg = Color(
    0xFFE8F5E9,
  ); // Completed item background (light green)
}

class CompletedItemStyle {
  static const TextStyle textStyle = TextStyle(color: AppColors.completedText);
  static const Color backgroundColor = AppColors.completedBg;
}

ThemeData appTheme() {
  final colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.fontSecondary,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: AppColors.fontPrimary),
      bodyMedium: TextStyle(color: AppColors.fontSecondary),
      headlineMedium: TextStyle(color: AppColors.fontPrimary),
    ),
  );
}
