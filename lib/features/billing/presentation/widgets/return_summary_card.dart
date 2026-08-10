import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storemate/features/billing/data/models/invoice_return_item_model.dart';

class ReturnSummaryCard extends StatelessWidget {
  const ReturnSummaryCard({
    super.key,
    required this.selectedItems,
    required this.totalQuantity,
    required this.refundAmount,
    required this.returnReason,
    required this.onProcessReturn,
    this.isLoading = false,
  });

  final int selectedItems;
  final int totalQuantity;
  final double refundAmount;
  final ReturnReason? returnReason;
  final VoidCallback onProcessReturn;
  final bool isLoading;

  String _formatReturnReason(ReturnReason? reason) {
    if (reason == null) return "-";

    switch (reason) {
      case ReturnReason.damaged:
        return "Damaged";

      case ReturnReason.wrongItem:
        return "Wrong Item";

      case ReturnReason.customerChangedMind:
        return "Customer Changed Mind";

      case ReturnReason.defective:
        return "Defective";

      case ReturnReason.other:
        return "Other";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final currencyFormatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //-----------------------------------------
            // Title
            //-----------------------------------------
            Row(
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  color: theme.colorScheme.primary,
                ),

                const SizedBox(width: 10),

                Text(
                  "Return Summary",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _SummaryRow(
              title: "Selected Items",
              value: selectedItems.toString(),
            ),

            const SizedBox(height: 12),

            _SummaryRow(
              title: "Total Quantity",
              value: totalQuantity.toString(),
            ),

            const SizedBox(height: 12),

            _SummaryRow(
              title: "Return Reason",
              value: returnReason != null
                  ? _formatReturnReason(returnReason!)
                  : "-",
            ),

            const Divider(height: 32),

            Row(
              children: [
                Expanded(
                  child: Text(
                    "Refund Amount",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                Text(
                  currencyFormatter.format(refundAmount),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: isLoading ? null : onProcessReturn,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.assignment_return),

                label: Text(isLoading ? "Processing..." : "Process Return"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),

        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
