import 'package:flutter/material.dart';

class AppFilterHeader extends StatelessWidget {
  const AppFilterHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.filter_alt_rounded,
    this.onClose,
  });

  /// Header title.
  final String title;

  /// Small description below the title.
  final String subtitle;

  /// Leading icon.
  final IconData icon;

  /// Close button callback.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        //----------------------------------------------------------------------
        // Drag Handle
        //----------------------------------------------------------------------

        Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(100),
          ),
        ),

        const SizedBox(height: 24),

        //----------------------------------------------------------------------
        // Header
        //----------------------------------------------------------------------

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //------------------------------------------------------------------
            // Icon
            //------------------------------------------------------------------

            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 26,
              ),
            ),

            const SizedBox(width: 16),

            //------------------------------------------------------------------
            // Title & Subtitle
            //------------------------------------------------------------------

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),

            //------------------------------------------------------------------
            // Close Button
            //------------------------------------------------------------------

            IconButton(
              tooltip: 'Close',
              onPressed: onClose ?? () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Divider(
          height: 1,
          color: colorScheme.outlineVariant.withValues(alpha: .6),
        ),
      ],
    );
  }
}