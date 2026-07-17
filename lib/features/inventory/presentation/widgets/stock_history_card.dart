import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:storemate/features/inventory/data/models/stock_adjustment_model.dart';
import 'package:storemate/features/inventory/presentation/utils/stock_history_helpers.dart';
import 'package:storemate/features/inventory/presentation/widgets/stock_value.dart';

class StockHistoryCard extends StatelessWidget {
  const StockHistoryCard({super.key, required this.adjustment});

  final StockAdjustmentModel adjustment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isPositive = adjustment.quantityChange > 0;

    final accentColor = typeColor(adjustment.adjustmentType, colors);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colors.outline.withValues(alpha: .35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //------------------------------------------
          // Header
          //------------------------------------------
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  typeIcon(adjustment.adjustmentType),
                  color: accentColor,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeTitle(adjustment.adjustmentType),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      DateFormat(
                        'hh:mm a',
                      ).format(adjustment.createdAt.toLocal()),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withValues(alpha: .12)
                      : colors.error.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${isPositive ? '+' : ''}${adjustment.quantityChange}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : colors.error,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Divider(color: colors.outline.withValues(alpha: .25)),

          const SizedBox(height: 18),

          //------------------------------------------
          // Previous -> Current
          //------------------------------------------
          Row(
            children: [
              Expanded(
                child: StockValue(
                  title: 'Previous',
                  value: adjustment.previousStock,
                ),
              ),

              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isPositive
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  color: accentColor,
                ),
              ),

              Expanded(
                child: StockValue(
                  title: 'Current',
                  value: adjustment.updatedStock,
                  alignRight: true,
                ),
              ),
            ],
          ),

          if (adjustment.note != null &&
              adjustment.note!.trim().isNotEmpty) ...[
            const SizedBox(height: 20),

            Divider(color: colors.outline.withValues(alpha: .25)),

            const SizedBox(height: 16),

            Text(
              'Note',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(adjustment.note!, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}
