import 'package:flutter/material.dart';
import 'package:storemate/app/theme/app_dimensions.dart';

abstract final class AppButtonTheme {
  // Elevated button theme
  static ElevatedButtonThemeData elevatedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          AppDimensions.buttonHeight,
        ),

        // Theme-aware colors
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.onSurface.withValues(
          alpha: 0.12,
        ),
        disabledForegroundColor: colorScheme.onSurface.withValues(
          alpha: 0.38,
        ),

        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMedium,
          ),
        ),

        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Outlined button theme
  static OutlinedButtonThemeData outlinedButtonTheme(
    ColorScheme colorScheme,
  ) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(
          double.infinity,
          AppDimensions.buttonHeight,
        ),

        // Theme-aware text and border colors
        foregroundColor: colorScheme.primary,

        side: BorderSide(
          color: colorScheme.primary,
          width: 1.2,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusMedium,
          ),
        ),

        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // Text button theme
  static TextButtonThemeData textButtonTheme(
    ColorScheme colorScheme,
  ) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(
          48,
          44,
        ),

        // Theme-aware text color
        foregroundColor: colorScheme.primary,

        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppDimensions.radiusSmall,
          ),
        ),
      ),
    );
  }
}