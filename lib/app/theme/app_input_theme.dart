import 'package:flutter/material.dart';
import 'package:storemate/app/theme/app_dimensions.dart';

abstract final class AppInputTheme {
  static InputDecorationTheme inputDecorationTheme(
    ColorScheme colorScheme,
  ) {
    return InputDecorationTheme(
      filled: true,

      // Theme-aware field background
      fillColor: colorScheme.surface,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium,
        vertical: AppDimensions.spacingMedium,
      ),

      // Default border
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMedium,
        ),
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: 1,
        ),
      ),

      // Normal border
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMedium,
        ),
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: 1,
        ),
      ),

      // Border when the field is selected
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMedium,
        ),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 1.5,
        ),
      ),

      // Error border
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMedium,
        ),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 1,
        ),
      ),

      // Error border when the field is selected
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMedium,
        ),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 1.5,
        ),
      ),

      // Label styling
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurfaceVariant,
      ),

      // Floating label styling
      floatingLabelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: colorScheme.primary,
      ),

      // Hint styling
      hintStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: colorScheme.onSurfaceVariant,
      ),

      // Prefix and suffix icon colors
      prefixIconColor: colorScheme.onSurfaceVariant,
      suffixIconColor: colorScheme.onSurfaceVariant,

      // Error styling
      errorStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: colorScheme.error,
      ),
    );
  }
}