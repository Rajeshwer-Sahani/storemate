import 'package:flutter/material.dart';

import 'package:storemate/app/theme/app_bar_theme.dart';
import 'package:storemate/app/theme/app_button_theme.dart';
import 'package:storemate/app/theme/app_card_theme.dart';
import 'package:storemate/app/theme/app_colors.dart';
import 'package:storemate/app/theme/app_input_theme.dart';
import 'package:storemate/app/theme/app_text_theme.dart';

abstract final class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.info,
      surface: AppColors.lightSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.lightTextPrimary,
      onError: Colors.white,

      // Theme-aware component colors
      outline: AppColors.lightBorder,
      outlineVariant: AppColors.lightBorder,
      onSurfaceVariant: AppColors.lightTextSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // StoreMate light color scheme
      colorScheme: colorScheme,

      // Main screen background
      scaffoldBackgroundColor: AppColors.lightBackground,

      // StoreMate typography
      textTheme: AppTextTheme.textTheme,

      // StoreMate component themes
      elevatedButtonTheme:
          AppButtonTheme.elevatedButtonTheme(colorScheme),

      outlinedButtonTheme:
          AppButtonTheme.outlinedButtonTheme(colorScheme),

      textButtonTheme:
          AppButtonTheme.textButtonTheme(colorScheme),

      inputDecorationTheme:
          AppInputTheme.inputDecorationTheme(colorScheme),

      cardTheme:
          AppCardTheme.cardTheme(colorScheme),

     appBarTheme:
    StoreMateAppBarTheme.appBarTheme(colorScheme),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.info,
      surface: AppColors.darkSurface,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.darkTextPrimary,
      onError: Colors.white,

      // Theme-aware component colors
      outline: AppColors.darkBorder,
      outlineVariant: AppColors.darkBorder,
      onSurfaceVariant: AppColors.darkTextSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // StoreMate dark color scheme
      colorScheme: colorScheme,

      // Main screen background
      scaffoldBackgroundColor: AppColors.darkBackground,

      // StoreMate typography
      textTheme: AppTextTheme.textTheme,

      // StoreMate component themes
      elevatedButtonTheme:
          AppButtonTheme.elevatedButtonTheme(colorScheme),

      outlinedButtonTheme:
          AppButtonTheme.outlinedButtonTheme(colorScheme),

      textButtonTheme:
          AppButtonTheme.textButtonTheme(colorScheme),

      inputDecorationTheme:
          AppInputTheme.inputDecorationTheme(colorScheme),

      cardTheme:
          AppCardTheme.cardTheme(colorScheme),

      appBarTheme:
          StoreMateAppBarTheme.appBarTheme(colorScheme),
    );
  }
}