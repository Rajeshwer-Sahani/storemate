import 'package:flutter/material.dart';

class InvoiceSummaryCard extends StatelessWidget {
  const InvoiceSummaryCard({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.originalTotal,
    required this.returnedAmount,
    required this.netInvoiceAmount,
  });

  final double subtotal;
  final double discount;
  final double tax;

  /// Original invoice total at the time the invoice was created.
  final double originalTotal;

  /// Total value of goods returned.
  final double returnedAmount;

  /// Original total after subtracting returned amount.
  final double netInvoiceAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final hasReturns = returnedAmount > 0;

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

            // -----------------------------------------------------------
            // Original Invoice Total
            // -----------------------------------------------------------
            _SummaryRow(
              label: 'Original Total',
              value: originalTotal,
              isTotal: !hasReturns,
            ),

            // -----------------------------------------------------------
            // Return-aware financial information
            // -----------------------------------------------------------
            if (hasReturns) ...[
              const SizedBox(height: 14),

              _SummaryRow(
                label: 'Returned Amount',
                value: returnedAmount,
                valueColor: colorScheme.error,
                prefix: '- ',
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Divider(
                  color: colorScheme.outlineVariant,
                  height: 1,
                ),
              ),

              _SummaryRow(
                label: 'Net Invoice Total',
                value: netInvoiceAmount,
                isTotal: true,
                valueColor: colorScheme.primary,
              ),
            ],
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
    final colorScheme = theme.colorScheme;

    final textStyle = isTotal
        ? theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
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
            color: valueColor ??
                (isTotal ? colorScheme.primary : null),
          ),
        ),
      ],
    );
  }
}