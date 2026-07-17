import 'package:flutter/material.dart';

class CustomerEmptyState extends StatelessWidget {
  const CustomerEmptyState({
    super.key,
    this.onAddCustomer,
  });

  final VoidCallback? onAddCustomer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 96,
              color: theme.colorScheme.primary.withOpacity(0.8),
            ),

            const SizedBox(height: 24),

            Text(
              'No Customers Yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              'Start building your customer database by adding your first customer.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            FilledButton.icon(
              onPressed: onAddCustomer,
              icon: const Icon(Icons.person_add_alt_1),
              label: const Text('Add Customer'),
            ),
          ],
        ),
      ),
    );
  }
}