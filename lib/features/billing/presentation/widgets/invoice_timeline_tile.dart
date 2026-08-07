import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/models/invoice_timeline_model.dart';

class InvoiceTimelineTile extends StatelessWidget {
  const InvoiceTimelineTile({
    super.key,
    required this.timeline,
    this.isLast = false,
  });

  final InvoiceTimelineModel timeline;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final iconData = _iconForEvent(timeline.eventType);
    final iconColor = _colorForEvent(context, timeline.eventType);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //------------------------------------------------------------------
          // Timeline Indicator
          //------------------------------------------------------------------
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: .12),
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.surface, width: 2),
                  ),
                  child: Icon(iconData, size: 12, color: iconColor),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: colorScheme.outlineVariant.withValues(alpha: .45),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          //------------------------------------------------------------------
          // Content
          //------------------------------------------------------------------
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: .45),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //----------------------------------------------------------
                  // Header
                  //----------------------------------------------------------
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        timeline.eventTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        _subtitleForEvent(timeline.eventType),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        DateFormat(
                          'dd MMM yyyy • hh:mm a',
                        ).format(timeline.createdAt),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  //----------------------------------------------------------
                  // Description
                  //----------------------------------------------------------
                  Text(
                    timeline.eventDescription,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),

                  //----------------------------------------------------------
                  // Amount
                  //----------------------------------------------------------
                  if (timeline.amount != null) ...[
                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '₹${timeline.amount!.toStringAsFixed(2)}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: iconColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],

                  //----------------------------------------------------------
                  // Payment Method
                  //----------------------------------------------------------
                  if (timeline.paymentMethod != null &&
                      timeline.paymentMethod!.isNotEmpty) ...[
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 18,
                          color: colorScheme.primary,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          timeline.paymentMethod!,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //---------------------------------------------------------------------------
  // Event Icons
  //---------------------------------------------------------------------------

  IconData _iconForEvent(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'invoice_created':
        return Icons.receipt_long_rounded;

      case 'payment_received':
        return Icons.payments_rounded;

      case 'payment_updated':
        return Icons.edit_rounded;

      case 'invoice_returned':
        return Icons.assignment_return_rounded;

      case 'invoice_cancelled':
        return Icons.cancel_rounded;

      default:
        return Icons.history_rounded;
    }
  }

  //---------------------------------------------------------------------------
  // Event Colors
  //---------------------------------------------------------------------------

  Color _colorForEvent(BuildContext context, String eventType) {
    final colors = Theme.of(context).colorScheme;

    switch (eventType.toLowerCase()) {
      case 'invoice_created':
        return colors.primary;

      case 'payment_received':
        return Colors.green;

      case 'payment_updated':
        return Colors.orange;

      case 'invoice_returned':
        return Colors.deepPurple;

      case 'invoice_cancelled':
        return Colors.red;

      default:
        return colors.secondary;
    }
  }

  String _subtitleForEvent(String type) {
    switch (type.toLowerCase()) {
      case 'invoice_created':
        return 'Created Successfully';

      case 'payment_received':
        return 'Payment Received';

      case 'payment_updated':
        return 'Payment Updated';

      case 'invoice_returned':
        return 'Invoice Returned';

      case 'invoice_cancelled':
        return 'Invoice Cancelled';

      default:
        return 'Timeline Event';
    }
  }
}
