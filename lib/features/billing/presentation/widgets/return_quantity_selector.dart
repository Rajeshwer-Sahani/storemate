import 'package:flutter/material.dart';

class ReturnQuantitySelector extends StatelessWidget {
  const ReturnQuantitySelector({
    super.key,
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
  });

  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity > 1
                ? () => onChanged(quantity - 1)
                : null,
            icon: const Icon(Icons.remove),
          ),
          SizedBox(
            width: 36,
            child: Center(
              child: Text(
                quantity.toString(),
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            onPressed: quantity < maxQuantity
                ? () => onChanged(quantity + 1)
                : null,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}