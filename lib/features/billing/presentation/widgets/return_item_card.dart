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

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    final isDeviceTracked = item.isDeviceTracked;

    return Card(
      elevation: selected ? 2 : 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        'Product ID: ${item.productId}',
                        style: theme.textTheme.bodySmall,
                      ),

                      if (isDeviceTracked) ...[
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Device Tracked',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _InfoRow(
              title: 'Sold Quantity',
              value: item.soldQuantity.toString(),
            ),

            const SizedBox(height: 8),

            _InfoRow(
              title: 'Already Returned',
              value: item.returnedQuantity.toString(),
            ),

            const SizedBox(height: 8),

            _InfoRow(
              title: 'Available to Return',
              value: item.remainingQuantity.toString(),
            ),

            const SizedBox(height: 8),

            _InfoRow(
              title: 'Unit Price',
              value: currencyFormatter.format(item.unitPrice),
            ),

            if (selected && !isDeviceTracked) ...[
              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: ReturnQuantitySelector(
                  quantity: selectedQuantity,
                  maxQuantity: item.remainingQuantity,
                  onChanged: onQuantityChanged,
                ),
              ),
            ],

            if (selected && isDeviceTracked) ...[
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Return Quantity', style: theme.textTheme.labelLarge),

                    const SizedBox(height: 4),

                    Text(
                      '$selectedQuantity device(s)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Select the exact device(s) sold on this invoice.',
                      style: theme.textTheme.bodySmall,
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onSelectDevices,
                        icon: const Icon(Icons.devices_rounded),
                        label: Text(
                          selectedDeviceCount == 0
                              ? 'Select Devices'
                              : 'Change Devices',
                        ),
                      ),
                    ),

                    if (selectedDeviceCount > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '$selectedDeviceCount of '
                        '$selectedQuantity device(s) selected',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: selectedDeviceCount == selectedQuantity
                              ? theme.colorScheme.primary
                              : theme.colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.bodyMedium)),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
