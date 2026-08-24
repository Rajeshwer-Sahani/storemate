import 'package:flutter/material.dart';

class MoreModuleCard extends StatelessWidget {
  const MoreModuleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
    this.trailing,
  });

  /// Icon representing the module.
  final IconData icon;

  /// Main module title.
  final String title;

  /// Short description of the module.
  final String subtitle;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Optional custom icon color.
  ///
  /// If not provided, the primary theme color is used.
  final Color? iconColor;

  /// Optional widget displayed before the arrow.
  ///
  /// Useful for badges such as "New", "Coming Soon", etc.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final resolvedIconColor = iconColor ?? colorScheme.primary;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // -----------------------------------------------------------------
              // Module Icon
              // -----------------------------------------------------------------
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: resolvedIconColor.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: 25,
                  color: resolvedIconColor,
                ),
              ),

              const SizedBox(width: 14),

              // -----------------------------------------------------------------
              // Module Information
              // -----------------------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              // -----------------------------------------------------------------
              // Optional Trailing Content
              // -----------------------------------------------------------------
              if (trailing != null) ...[
                const SizedBox(width: 10),
                trailing!,
              ],

              const SizedBox(width: 8),

              // -----------------------------------------------------------------
              // Navigation Arrow
              // -----------------------------------------------------------------
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}