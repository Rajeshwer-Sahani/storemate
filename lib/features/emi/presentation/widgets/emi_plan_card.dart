import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/emi_plan_model.dart';

class EmiPlanCard extends StatelessWidget {
  const EmiPlanCard({super.key, required this.plan, this.onTap});

  final EmiPlanModel plan;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final progress = plan.paidPercentage;
    final isCompleted = plan.isCompleted;
    final isCancelled = plan.isCancelled;

    final statusColor = _statusColor(context, plan.status);

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =============================================================
              // Header
              // =============================================================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: .08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: colorScheme.primary,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'EMI Plan',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          'Tenure: ${plan.tenureMonths} months',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  _StatusBadge(
                    label: _statusLabel(plan.status),
                    color: statusColor,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // =============================================================
              // Identity
              // =============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: .10),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: 18,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            plan.displayCustomerName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 18,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            plan.displayInvoiceNumber,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // =============================================================
              // Financial Summary
              // =============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: .45),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _AmountItem(
                            label: 'Financed',
                            amount: plan.financedAmount,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 42,
                          color: colorScheme.outlineVariant.withValues(
                            alpha: .45,
                          ),
                        ),
                        Expanded(
                          child: _AmountItem(
                            label: 'Total Payable',
                            amount: plan.totalPayableAmount,
                            alignment: CrossAxisAlignment.end,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _AmountItem(
                            label: 'Paid',
                            amount: plan.paidAmount,
                            amountColor: Colors.green,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 42,
                          color: colorScheme.outlineVariant.withValues(
                            alpha: .45,
                          ),
                        ),
                        Expanded(
                          child: _AmountItem(
                            label: 'Remaining',
                            amount: plan.remainingAmount,
                            amountColor: plan.hasRemainingAmount
                                ? colorScheme.error
                                : Colors.green,
                            alignment: CrossAxisAlignment.end,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // =============================================================
              // Payment Progress
              // =============================================================
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Payment Progress',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCompleted ? Colors.green : colorScheme.primary,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // =============================================================
              // Plan Details
              // =============================================================
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _InfoChip(
                    icon: Icons.calendar_today_rounded,
                    label: 'Starts ${_formatDate(plan.startDate)}',
                  ),
                  _InfoChip(
                    icon: Icons.event_available_rounded,
                    label: 'First due ${_formatDate(plan.firstDueDate)}',
                  ),
                  _InfoChip(
                    icon: Icons.percent_rounded,
                    label:
                        '${plan.interestRate.toStringAsFixed(2)}% ${_interestTypeLabel(plan.interestType)}',
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // =============================================================
              // Interest + Processing Fee
              // =============================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _CompactFinancialItem(
                        label: 'Interest',
                        value: '₹${plan.interestAmount.toStringAsFixed(2)}',
                      ),
                    ),
                    Expanded(
                      child: _CompactFinancialItem(
                        label: 'Processing Fee',
                        value: '₹${plan.processingFee.toStringAsFixed(2)}',
                        alignment: CrossAxisAlignment.end,
                      ),
                    ),
                  ],
                ),
              ),

              // =============================================================
              // Navigation Hint
              // =============================================================
              if (onTap != null && !isCancelled) ...[
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'View Details',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ],
          ),
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
      case 'active':
        return 'Active';

      case 'completed':
        return 'Completed';

      case 'cancelled':
        return 'Cancelled';

      case 'overdue':
        return 'Overdue';

      case 'pending':
        return 'Pending';

      default:
        return status.isEmpty
            ? 'Unknown'
            : status[0].toUpperCase() + status.substring(1);
    }
  }

  Color _statusColor(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status.toLowerCase()) {
      case 'active':
        return colorScheme.primary;

      case 'completed':
        return Colors.green;

      case 'cancelled':
        return colorScheme.error;

      case 'overdue':
        return Colors.orange;

      case 'pending':
        return colorScheme.secondary;

      default:
        return colorScheme.onSurfaceVariant;
    }
  }

  String _interestTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'flat':
        return 'Flat';

      case 'reducing':
      case 'reducing_balance':
        return 'Reducing';

      case 'none':
        return 'No Interest';

      default:
        return type;
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
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Compact Financial Item
// =============================================================================

class _CompactFinancialItem extends StatelessWidget {
  const _CompactFinancialItem({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Info Chip
// =============================================================================

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
