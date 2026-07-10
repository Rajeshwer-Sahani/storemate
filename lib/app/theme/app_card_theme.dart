import 'package:flutter/material.dart';
import 'package:storemate/app/theme/app_dimensions.dart';

abstract final class AppCardTheme {
  static CardThemeData cardTheme(
    ColorScheme colorScheme,
  ) {
    return CardThemeData(
      // Theme-aware card background
      color: colorScheme.surface,

      // Clean, flat appearance
      elevation: 0,

      // Prevent unwanted default spacing
      margin: EdgeInsets.zero,

      // Rounded shape with a subtle theme-aware border
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),

      // Keeps child content inside rounded corners
      clipBehavior: Clip.antiAlias,
    );
  }
}