import 'package:flutter/material.dart';

class InvoiceEmptyProducts extends StatelessWidget {
  const InvoiceEmptyProducts({
    super.key,
    required this.onAddProduct,
  });

  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 24,
        ),
        child: Column(
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: .10),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: .15),
                ),
              ),
              child: Icon(
                Icons.inventory_2_rounded,
                size: 40,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              'No Products Added',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'Add products to start building this invoice.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 28),

            FilledButton.icon(
              onPressed: onAddProduct,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}