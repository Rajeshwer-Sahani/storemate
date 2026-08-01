import 'package:flutter/material.dart';

class AppFilterActions extends StatelessWidget {
  const AppFilterActions({
    super.key,
    required this.onReset,
    required this.onApply,
    this.resetText = 'Reset',
    this.applyText = 'Apply Filters',
    this.isApplyEnabled = true,
    this.isLoading = false,
  });

  /// Reset button callback.
  final VoidCallback onReset;

  /// Apply button callback.
  final VoidCallback onApply;

  /// Reset button title.
  final String resetText;

  /// Apply button title.
  final String applyText;

  /// Enables/disables Apply button.
  final bool isApplyEnabled;

  /// Shows loading indicator.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: colorScheme.outlineVariant.withValues(alpha: .5),
            ),
          ),
        ),
        child: Row(
          children: [
            //------------------------------------------------------------------
            // Reset Button
            //------------------------------------------------------------------

            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onReset,
                child: Text(resetText),
              ),
            ),

            const SizedBox(width: 16),

            //------------------------------------------------------------------
            // Apply Button
            //------------------------------------------------------------------

            Expanded(
              flex: 2,
              child: FilledButton.icon(
                onPressed: isLoading || !isApplyEnabled
                    ? null
                    : onApply,
                icon: isLoading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(
                  isLoading ? 'Applying...' : applyText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}