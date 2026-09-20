
import 'package:flutter/material.dart';

class TrackingModeCard extends StatelessWidget {
  const TrackingModeCard({
    required this.requiresDeviceTracking,
  });

  final bool requiresDeviceTracking;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final icon = requiresDeviceTracking
        ? Icons.smartphone_outlined
        : Icons.inventory_2_outlined;

    final title = requiresDeviceTracking
        ? 'Individual Devices'
        : 'Quantity';

    final description = requiresDeviceTracking
        ? 'Each physical item is tracked using an IMEI or serial number.'
        : 'Stock is tracked using the total quantity of this product.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: requiresDeviceTracking
            ? colorScheme.primary.withValues(alpha: 0.07)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: requiresDeviceTracking
              ? colorScheme.primary.withValues(alpha: 0.35)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: requiresDeviceTracking
                  ? colorScheme.primary.withValues(alpha: 0.12)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: requiresDeviceTracking
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 23,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock Tracking',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: requiresDeviceTracking
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Defined by the selected category',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}