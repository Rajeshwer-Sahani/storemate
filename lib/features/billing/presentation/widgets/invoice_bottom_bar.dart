import 'package:flutter/material.dart';

class InvoiceBottomBar extends StatelessWidget {
  const InvoiceBottomBar({
    super.key,
    required this.grandTotal,
    required this.onPressed,
    this.isLoading = false,
    this.buttonText = 'Create Invoice',
    this.buttonIcon = Icons.receipt_long_outlined,
  });

  final double grandTotal;

  /// Callback for the action button.
  final VoidCallback? onPressed;

  final bool isLoading;

  /// Button title.
  final String buttonText;

  /// Button icon.
  final IconData buttonIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Material(
        elevation: 16,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        color: colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grand Total',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      '₹${grandTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
const SizedBox(width: 20),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: isLoading ? null : onPressed,
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
                      : Icon(buttonIcon),
                  label: Text(isLoading ? 'Please wait...' : buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
