import 'package:flutter/material.dart';

class CustomerAvatar extends StatelessWidget {
  const CustomerAvatar({
    super.key,
    required this.fullName,
    this.radius = 28,
  });

  final String fullName;
  final double radius;

  String get initials {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return '?';
    }

    if (parts.length == 1) {
      return parts.first[0].toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary,
      child: Text(
        initials,
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}