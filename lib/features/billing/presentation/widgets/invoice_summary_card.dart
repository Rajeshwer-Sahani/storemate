import 'package:flutter/material.dart';

class InvoiceSummaryCard extends StatelessWidget {
  const InvoiceSummaryCard({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.grandTotal,
  });

  final double subtotal;
  final double discount;
  final double tax;
  final double grandTotal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            _SummaryRow(
              label: 'Subtotal',
              value: subtotal,
            ),

            const SizedBox(height: 14),

            _SummaryRow(
              label: 'Discount',
              value: discount,
              valueColor: colorScheme.error,
              prefix: '- ',
            ),

            const SizedBox(height: 14),

            _SummaryRow(
              label: 'Tax',
              value: tax,
              valueColor: colorScheme.primary,
              prefix: '+ ',
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Divider(
                color: colorScheme.outlineVariant,
                height: 1,
              ),
            ),

            _SummaryRow(
              label: 'Grand Total',
              value: grandTotal,
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.prefix = '',
    this.isTotal = false,
    this.valueColor,
  });

  final String label;
  final double value;
  final String prefix;
  final bool isTotal;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final textStyle = isTotal
        ? theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          )
        : theme.textTheme.bodyLarge;

    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: textStyle,
          ),
        ),
        Text(
          '$prefix₹${value.toStringAsFixed(2)}',
          style: textStyle?.copyWith(
            color: valueColor,
          ),
        ),
      ],
    );
  }
}