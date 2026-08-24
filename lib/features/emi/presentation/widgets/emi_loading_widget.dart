import 'package:flutter/material.dart';

class EmiLoadingWidget extends StatelessWidget {
  const EmiLoadingWidget({
    super.key,
    this.message = 'Loading EMI details...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // -----------------------------------------------------------------
            // Loading Indicator
            // -----------------------------------------------------------------
            SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
            ),

            const SizedBox(height: 18),

            // -----------------------------------------------------------------
            // Loading Message
            // -----------------------------------------------------------------
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}