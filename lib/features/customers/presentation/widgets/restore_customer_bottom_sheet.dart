import 'package:flutter/material.dart';

class RestoreCustomerBottomSheet extends StatelessWidget {
  const RestoreCustomerBottomSheet({super.key, required this.customerName});

  final String customerName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(100),
              ),
            ),

            const SizedBox(height: 28),

            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.restore_outlined,
                size: 42,
                color: theme.colorScheme.primary,
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Restore Customer?',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Are you sure you want to restore "$customerName"?',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              'The customer will appear in your active customer list again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.restore_outlined),
                    label: const Text('Restore'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
