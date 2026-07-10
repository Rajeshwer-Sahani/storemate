import 'package:flutter/material.dart';

abstract final class StoreMateAppBarTheme {
  static AppBarTheme appBarTheme(
    ColorScheme colorScheme,
  ) {
    return AppBarTheme(
      // Theme-aware AppBar background
      backgroundColor: colorScheme.surface,

      // Theme-aware title and icon color
      foregroundColor: colorScheme.onSurface,

      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,

      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),

      iconTheme: IconThemeData(
        size: 24,
        color: colorScheme.onSurface,
      ),

      actionsIconTheme: IconThemeData(
        size: 24,
        color: colorScheme.onSurface,
      ),
    );
  }
}