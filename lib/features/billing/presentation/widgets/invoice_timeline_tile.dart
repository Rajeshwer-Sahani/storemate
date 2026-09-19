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

  bool get _isReturnEvent =>
      timeline.eventType.toLowerCase() == 'invoice_returned';

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
          // -----------------------------------------------------------------
          // Timeline indicator
          // -----------------------------------------------------------------
          SizedBox(
            width: 32,
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
                  child: Icon(iconData, size: 15, color: iconColor),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: .45,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // -----------------------------------------------------------------
          // Event content
          // -----------------------------------------------------------------
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 18),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _isReturnEvent
                      ? iconColor.withValues(alpha: .22)
                      : colorScheme.outlineVariant.withValues(alpha: .45),
                ),
              ),
              child: _isReturnEvent
                  ? _buildReturnEvent(context, iconColor)
                  : _buildStandardEvent(context, iconColor),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // STANDARD EVENT
  // ===========================================================================

  Widget _buildStandardEvent(BuildContext context, Color iconColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -------------------------------------------------------------------
        // Header
        // -------------------------------------------------------------------
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
          ).format(timeline.createdAt.toLocal()),
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 10),

        // -------------------------------------------------------------------
        // Description
        // -------------------------------------------------------------------
        Text(
          timeline.eventDescription,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
        ),

        // -------------------------------------------------------------------
        // Amount
        // -------------------------------------------------------------------
        if (timeline.amount != null) ...[
          const SizedBox(height: 14),
          _buildAmountChip(
            context,
            iconColor,
            label: '₹${timeline.amount!.toStringAsFixed(2)}',
          ),
        ],

        // -------------------------------------------------------------------
        // Payment method
        // -------------------------------------------------------------------
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
              Text(timeline.paymentMethod!, style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // RETURN EVENT
  // ===========================================================================

  Widget _buildReturnEvent(BuildContext context, Color iconColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final parsed = _parseReturnDescription(timeline.eventDescription);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -------------------------------------------------------------------
        // Header
        // -------------------------------------------------------------------
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeline.eventTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Return Processed',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.assignment_return_rounded,
                size: 20,
                color: iconColor,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Text(
          DateFormat(
            'dd MMM yyyy • hh:mm a',
          ).format(timeline.createdAt.toLocal()),
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 18),

        // -------------------------------------------------------------------
        // Returned items
        // -------------------------------------------------------------------
        if (parsed.returnNumber != null)
          Text(
            parsed.returnNumber!,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),

        if (parsed.returnedItemLines.isNotEmpty) ...[
          if (parsed.returnNumber != null) const SizedBox(height: 10),

          _buildReturnedItemsSection(
            context,
            parsed.returnedItemLines,
            iconColor,
          ),
        ],

        // -------------------------------------------------------------------
        // Refund
        // -------------------------------------------------------------------
        if (timeline.amount != null) ...[
          const SizedBox(height: 14),

          _buildRefundCard(context, iconColor, timeline.amount!),
        ],

        // -------------------------------------------------------------------
        // Return reason
        // -------------------------------------------------------------------
        if (parsed.reason != null) ...[
          const SizedBox(height: 14),

          _buildReturnMetaRow(
            context,
            icon: Icons.assignment_return_outlined,
            label: 'Return Reason',
            value: parsed.reason!,
            color: iconColor,
          ),
        ],

        // -------------------------------------------------------------------
        // Notes
        // -------------------------------------------------------------------
        if (parsed.notes != null) ...[
          const SizedBox(height: 12),

          _buildReturnMetaRow(
            context,
            icon: Icons.notes_rounded,
            label: 'Notes',
            value: parsed.notes!,
            color: colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }

  // ===========================================================================
  // RETURNED ITEMS SECTION
  // ===========================================================================

  Widget _buildReturnedItemsSection(
    BuildContext context,
    List<String> lines,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: .45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 18,
                  color: accentColor,
                ),
              ),

              const SizedBox(width: 10),

              Text(
                'Returned Items',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          ...lines.map(
            (line) => _buildReturnDescriptionLine(context, line, accentColor),
          ),
        ],
      ),
    );
  }

  Widget _buildReturnDescriptionLine(
    BuildContext context,
    String line,
    Color accentColor,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isIdentifierLine(line)) {
      final separatorIndex = line.indexOf(':');

      if (separatorIndex != -1) {
        final label = line.substring(0, separatorIndex).trim();
        final value = line.substring(separatorIndex + 1).trim();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 2),

              SelectableText(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: .2,
                ),
              ),
            ],
          ),
        );
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        line,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
          height: 1.35,
        ),
      ),
    );
  }

  // ===========================================================================
  // REFUND CARD
  // ===========================================================================

  Widget _buildRefundCard(
    BuildContext context,
    Color accentColor,
    double amount,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: .16)),
      ),
      child: Row(
        children: [
          Icon(Icons.currency_rupee_rounded, size: 20, color: accentColor),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Refund',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: accentColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // RETURN META ROW
  // ===========================================================================

  Widget _buildReturnMetaRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19, color: color),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // AMOUNT CHIP
  // ===========================================================================

  Widget _buildAmountChip(
    BuildContext context,
    Color color, {
    required String label,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ===========================================================================
  // RETURN DESCRIPTION PARSER
  // ===========================================================================

  _ParsedReturnDescription _parseReturnDescription(String description) {
    final lines = description
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    String? returnNumber;
    String? reason;
    String? notes;

    final returnedItemLines = <String>[];

    for (final line in lines) {
      // -------------------------------------------------------------------------
      // Return ID
      // -------------------------------------------------------------------------
      if (line.startsWith('Return ID:')) {
        returnNumber = line;
        continue;
      }

      // -------------------------------------------------------------------------
      // Backward compatibility for older timeline events
      // Example:
      // "Return RET-20260918-000013 processed."
      // -------------------------------------------------------------------------
      if (line.startsWith('Return ') &&
          line.endsWith(' processed.') &&
          !line.startsWith('Return items')) {
        final legacyReturnNumber = line
            .substring('Return '.length)
            .replaceFirst(' processed.', '')
            .trim();

        returnNumber = 'Return ID: $legacyReturnNumber';
        continue;
      }

      // -------------------------------------------------------------------------
      // Ignore legacy/system-only lines
      // -------------------------------------------------------------------------
      if (line.startsWith('Refunded:')) {
        continue;
      }

      if (line.startsWith('Reason:')) {
        reason = line.substring('Reason:'.length).trim();
        continue;
      }

      if (line.startsWith('Notes:')) {
        notes = line.substring('Notes:'.length).trim();
        continue;
      }

      if (line == 'Return items processed.') {
        continue;
      }

      if (line == 'Return items processed') {
        continue;
      }

      if (line.startsWith('Returned:')) {
        continue;
      }

      // -------------------------------------------------------------------------
      // Everything else is treated as returned-item information
      // -------------------------------------------------------------------------
      returnedItemLines.add(line);
    }

    return _ParsedReturnDescription(
      returnNumber: returnNumber,
      returnedItemLines: returnedItemLines,
      reason: reason,
      notes: notes,
    );
  }

  bool _isIdentifierLine(String line) {
    return line.startsWith('IMEI 1:') ||
        line.startsWith('IMEI 2:') ||
        line.startsWith('Serial Number:');
  }

  // ===========================================================================
  // EVENT ICONS
  // ===========================================================================

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

  // ===========================================================================
  // EVENT COLORS
  // ===========================================================================

  Color _colorForEvent(BuildContext context, String eventType) {
    final colors = Theme.of(context).colorScheme;

    switch (eventType.toLowerCase()) {
      case 'invoice_created':
        return colors.primary;

      case 'payment_received':
        return colors.tertiary;

      case 'payment_updated':
        return colors.secondary;

      case 'invoice_returned':
        return colors.error;

      case 'invoice_cancelled':
        return colors.error;

      default:
        return colors.secondary;
    }
  }

  // ===========================================================================
  // EVENT SUBTITLES
  // ===========================================================================

  String _subtitleForEvent(String type) {
    switch (type.toLowerCase()) {
      case 'invoice_created':
        return 'Created Successfully';

      case 'payment_received':
        return 'Payment Received';

      case 'payment_updated':
        return 'Payment Updated';

      case 'invoice_returned':
        return 'Return Processed';

      case 'invoice_cancelled':
        return 'Invoice Cancelled';

      default:
        return 'Timeline Event';
    }
  }
}

// =============================================================================
// Parsed return description
// =============================================================================

class _ParsedReturnDescription {
  const _ParsedReturnDescription({
    required this.returnNumber,
    required this.returnedItemLines,
    required this.reason,
    required this.notes,
  });

  final String? returnNumber;
  final List<String> returnedItemLines;
  final String? reason;
  final String? notes;
}
