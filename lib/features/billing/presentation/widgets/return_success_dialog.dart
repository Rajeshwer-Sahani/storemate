import 'package:flutter/material.dart';

class ReturnSuccessDialog extends StatelessWidget {
  const ReturnSuccessDialog({
    super.key,
    required this.returnNumber,
    required this.refundAmount,
    required this.onDone,
  });

  final String returnNumber;
  final double refundAmount;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            //------------------------------------
            // Success Icon
            //------------------------------------

            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 54,
              ),
            ),

            const SizedBox(height: 24),

            Text(
              "Return Processed",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "The invoice return has been processed successfully and inventory has been updated.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 28),

            //------------------------------------
            // Information Card
            //------------------------------------

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [

                  _InfoRow(
                    label: "Return Number",
                    value: returnNumber,
                  ),

                  const SizedBox(height: 14),

                  _InfoRow(
                    label: "Refund Amount",
                    value:
                        "₹${refundAmount.toStringAsFixed(2)}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: onDone,
                icon: const Icon(Icons.check_rounded),
                label: const Text("Done"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [

        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium,
          ),
        ),

        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}