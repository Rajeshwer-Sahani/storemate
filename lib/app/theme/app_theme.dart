import 'package:flutter/material.dart';
import 'package:storemate/app/theme/app_colors.dart';
import 'package:storemate/app/theme/app_text_theme.dart';

abstract final class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.info,
        surface: AppColors.lightSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.lightBackground,

      // StoreMate typography
      textTheme: AppTextTheme.textTheme,
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.info,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.darkBackground,

      // StoreMate typography
      textTheme: AppTextTheme.textTheme,
    );
  }
}