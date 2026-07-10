import 'package:flutter/material.dart';
import 'package:storemate/app/theme/app_dimensions.dart';

abstract final class AppInputTheme {
  static InputDecorationTheme get inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium,
        vertical: AppDimensions.spacingMedium,
      ),

      // Default border
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMedium,
        ),
        borderSide: BorderSide.none,
      ),

      // Normal border
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMedium,
        ),
        borderSide: const BorderSide(
          width: 1,
        ),
      ),

      // Border when the user selects the field
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMedium,
        ),
        borderSide: const BorderSide(
          width: 1.5,
        ),
      ),

      // Error border
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMedium,
        ),
        borderSide: const BorderSide(
          width: 1,
        ),
      ),

      // Error border when the field is selected
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusMedium,
        ),
        borderSide: const BorderSide(
          width: 1.5,
        ),
      ),

      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),

      hintStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),

      errorStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}