import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/app_summary_card.dart';

class BillingSummary extends StatelessWidget {
  const BillingSummary({
    super.key,
    required this.totalSales,
    required this.totalInvoices,
    required this.pendingAmount,
  });

  final String totalSales;
  final String totalInvoices;
  final String pendingAmount;

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
              value: totalSales,
              label: "Today's Sales",
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: AppSummaryCard(
              icon: Icons.receipt_long_outlined,
              value: totalInvoices,
              label: "Today's Bills",
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: AppSummaryCard(
              icon: Icons.pending_actions_rounded,
              value: pendingAmount,
              label: 'Pending Due',
              iconColor: colorScheme.error,
              iconBackgroundColor:
                  colorScheme.error.withValues(alpha: 0.10),
            ),
          ),
        ],
      ),
    );
  }
}