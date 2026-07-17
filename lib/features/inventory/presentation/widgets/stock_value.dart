import 'package:flutter/material.dart';

class StockValue extends StatelessWidget {
  const StockValue({
    super.key,
    required this.title,
    required this.value,
    this.alignRight = false,
  });

  final String title;
  final int value;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
          alignRight
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}