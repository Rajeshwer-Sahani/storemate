import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:storemate/core/widgets/app_summary_card.dart';

class BillingSummary extends StatelessWidget {
   BillingSummary({
    super.key,
    required this.totalSales,
    required this.totalInvoices,
    required this.pendingAmount,
  });

  final double totalSales;
  final int totalInvoices;
  final double pendingAmount;


  final NumberFormat _currencyFormatter = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: AppSummaryCard(
              icon: Icons.payments_outlined,
              value: _currencyFormatter.format(totalSales),
              label: "Today's Sales",
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: AppSummaryCard(
              icon: Icons.receipt_long_outlined,
              value: totalInvoices.toString(),
              label: "Today's Bills",
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: AppSummaryCard(
              icon: Icons.pending_actions_rounded,
             value: _currencyFormatter.format(pendingAmount),
              label: 'Pending Due',
              iconColor: colorScheme.error,
              iconBackgroundColor: colorScheme.error.withValues(alpha: 0.10),
            ),
          ),
        ],
      ),
    );
  }
}
