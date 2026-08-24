import 'package:flutter/material.dart';

class EmiPaymentCard extends StatelessWidget {
  const EmiPaymentCard({
    super.key,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.reference,
    this.onTap,
    this.isLatest = false,
  });

  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? reference;
  final VoidCallback? onTap;
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final cardContent = Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -----------------------------------------------------------------
          // Payment Icon
          // -----------------------------------------------------------------
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.payments_rounded,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(width: 14),

          // -----------------------------------------------------------------
          // Payment Information
          // -----------------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        isLatest ? 'Latest Payment' : 'EMI Payment',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    if (isLatest)
                      _LatestBadge(
                        color: colorScheme.primary,
                      ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                // -----------------------------------------------------------------
                // Payment Method
                // -----------------------------------------------------------------
                Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant,
                    ),

                    const SizedBox(width: 6),

                    Flexible(
                      child: Text(
                        paymentMethod,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // -----------------------------------------------------------------
                // Payment Date
                // -----------------------------------------------------------------
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),

                    const SizedBox(width: 6),

                    Text(
                      _formatDate(paymentDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),

                // -----------------------------------------------------------------
                // Reference
                // -----------------------------------------------------------------
                if (reference != null && reference!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),

                  Row(
                    children: [
                      Icon(
                        Icons.tag_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),

                      const SizedBox(width: 6),

                      Expanded(
                        child: Text(
                          reference!,
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
              ],
            ),
          ),

          // -----------------------------------------------------------------
          // Action
          // -----------------------------------------------------------------
          if (onTap != null) ...[
            const SizedBox(width: 8),

            IconButton(
              onPressed: onTap,
              tooltip: 'View payment',
              icon: const Icon(
                Icons.chevron_right_rounded,
              ),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return Card(
        margin: EdgeInsets.zero,
        child: cardContent,
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: cardContent,
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')} '
        '${months[localDate.month - 1]} '
        '${localDate.year}';
  }
}

// =============================================================================
// Latest Badge
// =============================================================================

class _LatestBadge extends StatelessWidget {
  const _LatestBadge({
    required this.color,
  });

  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        'Latest',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}