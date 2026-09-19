import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storemate/features/billing/data/models/returnable_item_model.dart';

import 'return_quantity_selector.dart';

class ReturnItemCard extends StatelessWidget {
  const ReturnItemCard({
    super.key,
    required this.item,
    required this.selected,
    required this.selectedQuantity,
    required this.onSelected,
    required this.onQuantityChanged,
    this.selectedDeviceCount = 0,
    this.onSelectDevices,
  });

  final ReturnableItemModel item;
  final bool selected;
  final int selectedQuantity;

  final ValueChanged<bool> onSelected;
  final ValueChanged<int> onQuantityChanged;

  final int selectedDeviceCount;
  final VoidCallback? onSelectDevices;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    final isDeviceTracked = item.isDeviceTracked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          width: selected ? 1.5 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: .08),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (value) {
                    onSelected(value ?? false);
                  },
                  visualDensity: VisualDensity.compact,
                ),

                const SizedBox(width: 8),

                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    isDeviceTracked
                        ? Icons.phone_android_rounded
                        : Icons.inventory_2_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Row(
                        children: [
                          if (isDeviceTracked)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Device Tracked',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                          if (!isDeviceTracked)
                            Text(
                              'Quantity Product',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sell_outlined,
                    size: 18,
                    color: colorScheme.primary,
                  ),

                  const SizedBox(width: 9),

                  Text(
                    'Unit Price',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    currencyFormatter.format(item.unitPrice),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _buildStatistics(context),

            if (selected && !isDeviceTracked) ...[
              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Return Quantity',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Maximum ${item.remainingQuantity}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ReturnQuantitySelector(
                      quantity: selectedQuantity,
                      maxQuantity: item.remainingQuantity,
                      onChanged: onQuantityChanged,
                    ),
                  ],
                ),
              ),
            ],

            if (selected && isDeviceTracked) ...[
              const SizedBox(height: 18),
              _buildDeviceSelection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: 'Sold',
            value: item.soldQuantity.toString(),
            icon: Icons.shopping_bag_outlined,
            color: colorScheme.primary,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _StatBox(
            label: 'Returned',
            value: item.returnedQuantity.toString(),
            icon: Icons.assignment_return_outlined,
            color: colorScheme.tertiary,
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _StatBox(
            label: 'Available',
            value: item.remainingQuantity.toString(),
            icon: Icons.check_circle_outline_rounded,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildDeviceSelection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final isComplete = selectedDeviceCount == selectedQuantity;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isComplete
              ? colorScheme.primary.withValues(alpha: .25)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.devices_rounded,
                  size: 20,
                  color: colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Return Device',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$selectedQuantity '
                      '${selectedQuantity == 1 ? 'device' : 'devices'} '
                      'must be selected',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            'Select the exact physical device sold on this invoice.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: onSelectDevices,
              icon: const Icon(Icons.devices_other_rounded),
              label: Text(
                selectedDeviceCount == 0
                    ? 'Select Device'
                    : 'Change Selected Device',
              ),
            ),
          ),

          if (selectedDeviceCount > 0) ...[
            const SizedBox(height: 10),

            Row(
              children: [
                Icon(
                  isComplete
                      ? Icons.check_circle_rounded
                      : Icons.info_outline_rounded,
                  size: 17,
                  color: isComplete ? colorScheme.primary : colorScheme.error,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    '$selectedDeviceCount of '
                    '$selectedQuantity '
                    '${selectedQuantity == 1 ? 'device' : 'devices'} '
                    'selected',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isComplete
                          ? colorScheme.primary
                          : colorScheme.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: color),

          const SizedBox(height: 7),

          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 1),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
