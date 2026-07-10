import 'package:flutter/material.dart';
import 'package:storemate/app/theme/app_dimensions.dart';

abstract final class AppCardTheme {
  static CardThemeData get cardTheme {
    return CardThemeData(
      elevation: 0,

      margin: EdgeInsets.zero,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          AppDimensions.radiusLarge,
        ),
      ),

      clipBehavior: Clip.antiAlias,
    );
  }
}