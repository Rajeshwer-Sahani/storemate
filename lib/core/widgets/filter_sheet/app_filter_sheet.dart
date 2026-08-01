import 'package:flutter/material.dart';

import 'package:storemate/core/widgets/filter_sheet/app_filter_actions.dart';
import 'package:storemate/core/widgets/filter_sheet/app_filter_header.dart';

class AppFilterSheet extends StatelessWidget {
  const AppFilterSheet({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.onReset,
    required this.onApply,
    this.icon = Icons.filter_alt_rounded,
    this.resetText = 'Reset',
    this.applyText = 'Apply Filters',
    this.isApplyEnabled = true,
    this.isLoading = false,
  });

  /// Header
  final String title;
  final String subtitle;
  final IconData icon;

  /// Filter content
  final Widget body;

  /// Footer actions
  final VoidCallback onReset;
  final VoidCallback onApply;

  final String resetText;
  final String applyText;

  final bool isApplyEnabled;
  final bool isLoading;

  //--------------------------------------------------------------------------
  // Show Bottom Sheet
  //--------------------------------------------------------------------------

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool useSafeArea = true,
    bool enableDrag = true,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      useSafeArea: useSafeArea,
      enableDrag: enableDrag,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (_) => child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return FractionallySizedBox(
      heightFactor: .88,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        child: Material(
          color: colorScheme.surface,
          child: Column(
            children: [
              //----------------------------------------------------------------
              // Header
              //----------------------------------------------------------------

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  0,
                ),
                child: AppFilterHeader(
                  title: title,
                  subtitle: subtitle,
                  icon: icon,
                ),
              ),

              //----------------------------------------------------------------
              // Body
              //----------------------------------------------------------------

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    0,
                    24,
                    24,
                  ),
                  child: body,
                ),
              ),

              //----------------------------------------------------------------
              // Footer
              //----------------------------------------------------------------

              AppFilterActions(
                onReset: onReset,
                onApply: onApply,
                resetText: resetText,
                applyText: applyText,
                isApplyEnabled: isApplyEnabled,
                isLoading: isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}