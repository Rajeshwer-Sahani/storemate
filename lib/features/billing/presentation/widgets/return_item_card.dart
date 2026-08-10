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
  });

  final ReturnableItemModel item;
  final bool selected;
  final int selectedQuantity;

  final ValueChanged<bool> onSelected;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return Card(
      elevation: selected ? 2 : 0,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
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
            //---------------------------------------------
            // Top Row
            //---------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (value) =>
                      onSelected(value ?? false),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productName,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "Product ID: ${item.productId}",
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            //---------------------------------------------
            // Details
            //---------------------------------------------
            _InfoRow(
              title: "Sold Quantity",
              value: item.soldQuantity.toString(),
            ),

            const SizedBox(height: 8),

            _InfoRow(
              title: "Already Returned",
              value: item.returnedQuantity.toString(),
            ),

            const SizedBox(height: 8),

            _InfoRow(
              title: "Available to Return",
              value: item.remainingQuantity.toString(),
            ),

            const SizedBox(height: 8),

            _InfoRow(
              title: "Unit Price",
              value: currencyFormatter.format(
                item.unitPrice,
              ),
            ),

            //---------------------------------------------
            // Quantity Selector
            //---------------------------------------------
            if (selected) ...[
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
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.bodyMedium,
          ),
        ),
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