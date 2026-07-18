import 'package:flutter/material.dart';

class AppModuleHeader extends StatelessWidget {
  const AppModuleHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionButton,
    this.menuButton,
    this.padding,
  });

  final String title;
  final String subtitle;

  /// Usually a FilledButton, FilledButton.icon, etc.
  final Widget? actionButton;

  /// Usually a PopupMenuButton.
  final Widget? menuButton;

  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          if (actionButton != null || menuButton != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (actionButton != null) actionButton!,

                  if (menuButton != null) ...[
                    const SizedBox(width: 12),
                    menuButton!,
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}
