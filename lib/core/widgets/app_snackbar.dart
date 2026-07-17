import 'package:flutter/material.dart';

class AppSnackbar {
  AppSnackbar._();

  static void success(
    BuildContext context, {
    required String message,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.green,
      icon: Icons.check_circle,
    );
  }

  static void error(
    BuildContext context, {
    required String message,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.red,
      icon: Icons.error,
    );
  }

  static void warning(
    BuildContext context, {
    required String message,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.orange,
      icon: Icons.warning_amber_rounded,
    );
  }

  static void info(
    BuildContext context, {
    required String message,
  }) {
    _show(
      context,
      message: message,
      backgroundColor: Colors.blue,
      icon: Icons.info,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: backgroundColor,
          elevation: 0,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}