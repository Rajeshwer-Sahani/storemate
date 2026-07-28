import 'package:flutter/material.dart';

class InvoiceBottomBar extends StatelessWidget {
  const InvoiceBottomBar({
    super.key,
    required this.grandTotal,
    required this.onCreateInvoice,
    this.isLoading = false,
    this.buttonText = 'Create Invoice',
  });

  final double grandTotal;
  final VoidCallback? onCreateInvoice;
  final bool isLoading;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SafeArea(
      top: false,
      child: Material(
        elevation: 8,
        color: colorScheme.surface,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Grand Total',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '₹${grandTotal.toStringAsFixed(2)}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : onCreateInvoice,
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
                      : const Icon(Icons.receipt_long_outlined),
                  label: Text(isLoading ? 'Creating Invoice...' : buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
