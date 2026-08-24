import 'package:flutter/material.dart';

class EmiSummaryCard extends StatelessWidget {
  const EmiSummaryCard({
    super.key,
    required this.totalPayable,
    required this.paidAmount,
    required this.monthlyEmi,
    required this.paidInstallments,
    required this.totalInstallments,
    required this.status,
  });

  /// Total amount the customer is expected to pay
  /// over the complete EMI plan.
  final double totalPayable;

  /// Total amount already received from the customer.
  final double paidAmount;

  /// Scheduled EMI amount per installment.
  final double monthlyEmi;

  /// Number of installments that have been fully paid.
  final int paidInstallments;

  /// Total number of installments in the plan.
  final int totalInstallments;

  /// Current EMI plan status.
  ///
  /// Examples:
  /// - Active
  /// - Completed
  /// - Overdue
  /// - Cancelled
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final safeTotalPayable = totalPayable < 0 ? 0.0 : totalPayable;
    final safePaidAmount = paidAmount.clamp(0.0, safeTotalPayable);
    final remainingAmount =
        (safeTotalPayable - safePaidAmount).clamp(0.0, double.infinity);

    final safeTotalInstallments =
        totalInstallments < 0 ? 0 : totalInstallments;

    final safePaidInstallments = safeTotalInstallments == 0
        ? 0
        : paidInstallments.clamp(0, safeTotalInstallments);

    final amountProgress = safeTotalPayable <= 0
        ? 0.0
        : (safePaidAmount / safeTotalPayable).clamp(0.0, 1.0);

    final installmentProgress = safeTotalInstallments == 0
        ? 0.0
        : (safePaidInstallments / safeTotalInstallments).clamp(0.0, 1.0);

    final progressPercentage = (amountProgress * 100).round();

    final statusColor = _statusColor(
      context,
      status,
      remainingAmount,
    );

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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EMI Summary',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Payment progress and outstanding balance',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                _StatusChip(
                  label: status,
                  color: statusColor,
                ),
              ],
            ),

            const SizedBox(height: 22),

            // -----------------------------------------------------------------
            // Financial Summary
            // -----------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: _AmountItem(
                    label: 'Total Payable',
                    amount: safeTotalPayable,
                    icon: Icons.account_balance_wallet_rounded,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AmountItem(
                    label: 'Paid',
                    amount: safePaidAmount,
                    icon: Icons.payments_rounded,
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            _RemainingAmountCard(
              amount: remainingAmount,
              colorScheme: colorScheme,
              theme: theme,
            ),

            const SizedBox(height: 20),

            // -----------------------------------------------------------------
            // Payment Progress
            // -----------------------------------------------------------------
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Payment Progress',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '$progressPercentage%',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: amountProgress,
                minHeight: 9,
                backgroundColor: colorScheme.surfaceContainerHighest,
              ),
            ),

            const SizedBox(height: 18),

            // -----------------------------------------------------------------
            // EMI + Installment Information
            // -----------------------------------------------------------------
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(
                    alpha: .55,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.calendar_month_rounded,
                      label: 'Monthly EMI',
                      value: '₹${monthlyEmi.toStringAsFixed(2)}',
                      color: colorScheme.primary,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 42,
                    color: colorScheme.outlineVariant.withValues(
                      alpha: .55,
                    ),
                  ),
                  Expanded(
                    child: _InfoItem(
                      icon: Icons.format_list_numbered_rounded,
                      label: 'Installments',
                      value:
                          '$safePaidInstallments / $safeTotalInstallments',
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // -----------------------------------------------------------------
            // Installment Progress
            // -----------------------------------------------------------------
            if (safeTotalInstallments > 0)
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Installment Progress',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  Text(
                    '${(installmentProgress * 100).round()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(
    BuildContext context,
    String status,
    double remainingAmount,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final normalizedStatus = status.trim().toLowerCase();

    switch (normalizedStatus) {
      case 'completed':
      case 'paid':
        return colorScheme.tertiary;

      case 'overdue':
      case 'defaulted':
        return colorScheme.error;

      case 'cancelled':
      case 'canceled':
        return colorScheme.outline;

      case 'active':
      case 'ongoing':
        return colorScheme.primary;

      default:
        return remainingAmount <= 0
            ? colorScheme.tertiary
            : colorScheme.primary;
    }
  }
}

// =============================================================================
// Amount Item
// =============================================================================

class _AmountItem extends StatelessWidget {
  const _AmountItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(
            alpha: .55,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Remaining Amount
// =============================================================================

class _RemainingAmountCard extends StatelessWidget {
  const _RemainingAmountCard({
    required this.amount,
    required this.colorScheme,
    required this.theme,
  });

  final double amount;
  final ColorScheme colorScheme;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isCompleted = amount <= 0.01;

    final color = isCompleted
        ? colorScheme.tertiary
        : colorScheme.primary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: .22),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.account_balance_wallet_rounded,
              color: color,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCompleted ? 'EMI Completed' : 'Remaining Amount',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isCompleted
                      ? 'All scheduled payments have been received.'
                      : 'Amount still payable by the customer.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Information Item
// =============================================================================

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 7),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Status Chip
// =============================================================================

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color.withValues(alpha: .20),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}