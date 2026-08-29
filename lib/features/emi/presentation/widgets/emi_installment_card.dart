import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/emi_installment_model.dart';

class EmiInstallmentCard extends StatelessWidget {
  const EmiInstallmentCard({super.key, required this.installment, this.onTap});

  final EmiInstallmentModel installment;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final statusColor = _statusColor(context, installment.status);

    final statusLabel = _statusLabel(installment.status);

    final normalizedStatus = installment.status.toLowerCase();

    final isPaid = normalizedStatus == 'paid';

    final isCancelled =
        normalizedStatus == 'cancelled' || normalizedStatus == 'canceled';

    final canRecordPayment =
        onTap != null &&
        !isPaid &&
        !isCancelled &&
        installment.remainingAmount > 0.01;

    final paidAmountColor = switch (normalizedStatus) {
      'paid' => Colors.green.shade600,
      'partially_paid' || 'partially paid' => Colors.amber.shade700,
      _ => colorScheme.tertiary,
    };

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // =============================================================
            // Header
            // =============================================================
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InstallmentNumber(
                  number: installment.installmentNumber,
                  color: statusColor,
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Installment #${installment.installmentNumber}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              'Due ${_formatDate(installment.dueDate)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                _StatusBadge(label: statusLabel, color: statusColor),
              ],
            ),

            const SizedBox(height: 18),

            // =============================================================
            // Amount Summary
            // =============================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: .45),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _AmountItem(
                      label: 'Scheduled',
                      amount: installment.scheduledAmount,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 42,
                    color: colorScheme.outlineVariant.withValues(alpha: .45),
                  ),

                  Expanded(
                    child: _AmountItem(
                      label: 'Paid',
                      amount: installment.paidAmount,
                      amountColor: paidAmountColor,
                      alignment: CrossAxisAlignment.center,
                    ),
                  ),

                  Container(
                    width: 1,
                    height: 42,
                    color: colorScheme.outlineVariant.withValues(alpha: .45),
                  ),

                  Expanded(
                    child: _AmountItem(
                      label: 'Remaining',
                      amount: installment.remainingAmount,
                      amountColor: installment.remainingAmount > 0.01
                          ? colorScheme.error
                          : colorScheme.tertiary,
                      alignment: CrossAxisAlignment.end,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // =============================================================
            // Payment Progress
            // =============================================================
            _PaymentProgress(
              scheduledAmount: installment.scheduledAmount,
              paidAmount: installment.paidAmount,
              isPaid: isPaid,
              isCancelled: isCancelled,
            ),

            // =============================================================
            // Record Payment
            // =============================================================
            //
            // This button is intentionally shown only when the parent
            // screen identifies this installment as the current/next
            // payable installment and provides onTap.
            //
            if (canRecordPayment) ...[
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.payments_outlined, size: 18),
                  label: const Text('Record Payment'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // Helpers
  // =========================================================================

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date.toLocal());
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'upcoming':
        return 'Upcoming';

      case 'due':
        return 'Due';

      case 'partially_paid':
      case 'partially paid':
        return 'Partially Paid';

      case 'paid':
        return 'Paid';

      case 'overdue':
        return 'Overdue';

      case 'cancelled':
      case 'canceled':
        return 'Cancelled';

      default:
        if (status.isEmpty) {
          return 'Unknown';
        }

        return status[0].toUpperCase() + status.substring(1);
    }
  }

  Color _statusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status.toLowerCase()) {
      case 'upcoming':
        return colorScheme.secondary;

      case 'due':
        return colorScheme.primary;

      case 'partially_paid':
      case 'partially paid':
        return Colors.amber.shade700;

      case 'paid':
        return Colors.green.shade600;

      case 'overdue':
        return colorScheme.error;

      case 'cancelled':
      case 'canceled':
        return colorScheme.onSurfaceVariant;

      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}
// =============================================================================
// Installment Number
// =============================================================================

class _InstallmentNumber extends StatelessWidget {
  const _InstallmentNumber({required this.number, required this.color});

  final int number;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      alignment: Alignment.center,
      child: Text(
        '$number',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// =============================================================================
// Amount Item
// =============================================================================

class _AmountItem extends StatelessWidget {
  const _AmountItem({
    required this.label,
    required this.amount,
    this.amountColor,
    this.alignment = CrossAxisAlignment.start,
  });

  final String label;
  final double amount;
  final Color? amountColor;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Payment Progress
// =============================================================================

class _PaymentProgress extends StatelessWidget {
  const _PaymentProgress({
    required this.scheduledAmount,
    required this.paidAmount,
    required this.isPaid,
    required this.isCancelled,
  });

  final double scheduledAmount;
  final double paidAmount;
  final bool isPaid;
  final bool isCancelled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final progress = scheduledAmount <= 0
        ? 0.0
        : (paidAmount / scheduledAmount).clamp(0.0, 1.0);

    final progressColor = isCancelled
        ? colorScheme.onSurfaceVariant
        : isPaid
        ? colorScheme.tertiary
        : colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Payment Progress',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: progressColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Status Badge
// =============================================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .20)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
