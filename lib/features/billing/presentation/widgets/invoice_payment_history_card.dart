import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:storemate/features/billing/data/models/payment_history_model.dart';

class InvoicePaymentHistoryCard extends StatelessWidget {
  const InvoicePaymentHistoryCard({super.key, required this.payment});

  final PaymentHistoryModel payment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //------------------------------------------------------------
            // Icon
            //------------------------------------------------------------
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.payments_rounded, color: Colors.green),
            ),

            const SizedBox(width: 16),

            //------------------------------------------------------------
            // Information
            //------------------------------------------------------------
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //------------------------------------------------------
                  // Amount
                  //------------------------------------------------------
                  Text(
                    '₹${payment.amount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  //------------------------------------------------------
                  // Method
                  //------------------------------------------------------
                  Row(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 16,
                      ),

                      const SizedBox(width: 6),

                      Text(
                        payment.paymentMethod,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  //------------------------------------------------------
                  // Date
                  //------------------------------------------------------
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 16),

                      const SizedBox(width: 6),

                      Text(
                        DateFormat(
                          'dd MMM yyyy • hh:mm a',
                        ).format(payment.createdAt.toLocal()),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),

                  //------------------------------------------------------
                  // Notes
                  //------------------------------------------------------
                  if (payment.notes != null &&
                      payment.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 14),

                    Divider(
                      height: 1,
                      color: theme.dividerColor.withValues(alpha: .30),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Notes',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(payment.notes!, style: theme.textTheme.bodyMedium),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
