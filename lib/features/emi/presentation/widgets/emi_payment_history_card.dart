import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/emi_payment_model.dart';

class EmiPaymentHistoryCard extends StatelessWidget {
  const EmiPaymentHistoryCard({
    super.key,
    required this.payment,
    required this.paymentNumber,
  });

  final EmiPaymentModel payment;
  final int paymentNumber;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -----------------------------------------------------------------
            // Header
            // -----------------------------------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PaymentIcon(
                  color: colorScheme.primary,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment #$paymentNumber',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _formattedPaymentDate(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                Text(
                  '₹${payment.amount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                   color: Colors.green.shade600,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // -----------------------------------------------------------------
            // Payment Details
            // -----------------------------------------------------------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.45,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Payment Method',
                    value: payment.paymentMethod,
                  ),

                  if (payment.reference != null &&
                      payment.reference!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),

                    _DetailRow(
                      icon: Icons.tag_rounded,
                      label: 'Reference',
                      value: payment.reference!,
                    ),
                  ],

                  if (payment.notes != null &&
                      payment.notes!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),

                    _DetailRow(
                      icon: Icons.notes_rounded,
                      label: 'Notes',
                      value: payment.notes!,
                    ),
                  ],
                ],
              ),
            ),

            // -----------------------------------------------------------------
            // Recorded At
            // -----------------------------------------------------------------
            const SizedBox(height: 14),

            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),

                const SizedBox(width: 6),

                Text(
                  'Recorded ${DateFormat(
                    'dd MMM yyyy • hh:mm a',
                  ).format(payment.createdAt.toLocal())}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formattedPaymentDate() {
    return DateFormat(
      'dd MMM yyyy',
    ).format(payment.paymentDate.toLocal());
  }
}

// =============================================================================
// Payment Icon
// =============================================================================

class _PaymentIcon extends StatelessWidget {
  const _PaymentIcon({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.payments_rounded,
        color: color,
      ),
    );
  }
}

// =============================================================================
// Detail Row
// =============================================================================

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.onSurfaceVariant,
        ),

        const SizedBox(width: 10),

        SizedBox(
          width: 105,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}