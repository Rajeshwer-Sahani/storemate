import 'package:flutter/material.dart';

abstract final class AppTextTheme {
  static TextTheme get textTheme {
    return const TextTheme(
      // Large screen headings
      displayLarge: TextStyle(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.2,
      ),

      // Main page headings
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),

      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),

      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),

      // Section headings
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),

      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),

      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),

      // Normal content
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),

      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.5,
      ),

      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
      ),

      // Buttons and labels
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
      ),

      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.25,
      ),

      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.25,
      ),
    );
  }
}