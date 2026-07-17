import 'package:flutter/material.dart';

class HistorySectionHeader extends StatelessWidget {
  const HistorySectionHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Divider(
            color: theme.colorScheme.outlineVariant,
          ),
        ),
      ],
    );
  }
}