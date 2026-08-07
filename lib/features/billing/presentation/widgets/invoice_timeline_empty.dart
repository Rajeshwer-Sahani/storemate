import 'package:flutter/material.dart';

class InvoiceTimelineEmpty extends StatelessWidget {
  const InvoiceTimelineEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //------------------------------------------------------------------
          // Icon
          //------------------------------------------------------------------

          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: .08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timeline_rounded,
              size: 36,
              color: colorScheme.primary,
            ),
          ),

          const SizedBox(height: 18),

          //------------------------------------------------------------------
          // Title
          //------------------------------------------------------------------

          Text(
            'No Timeline Available',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          //------------------------------------------------------------------
          // Subtitle
          //------------------------------------------------------------------

          Text(
            'Activity related to this invoice will appear here once actions are performed.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}