import 'package:flutter/material.dart';

class AppFilterSection extends StatelessWidget {
  const AppFilterSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.padding,
  });

  /// Section title.
  final String title;

  /// Optional helper text below the title.
  final String? subtitle;

  /// Section content (chips, radio list, etc.).
  final Widget child;

  /// Custom padding.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding ??
          const EdgeInsets.symmetric(
            vertical: 20,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //--------------------------------------------------------------------
          // Title
          //--------------------------------------------------------------------

          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          //--------------------------------------------------------------------
          // Subtitle
          //--------------------------------------------------------------------

          if (subtitle != null) ...[
            const SizedBox(height: 4),

            Text(
              subtitle!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],

          const SizedBox(height: 16),

          //--------------------------------------------------------------------
          // Content
          //--------------------------------------------------------------------

          child,
        ],
      ),
    );
  }
}