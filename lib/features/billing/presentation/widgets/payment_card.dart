import 'package:flutter/material.dart';

class PaymentCard extends StatelessWidget {
  const PaymentCard({
    super.key,
    required this.paymentMethod,
    required this.paidAmount,
    required this.dueAmount,
    this.onPaymentMethodTap,
    this.onPaidAmountChanged,
  });

  final String paymentMethod;
  final double paidAmount;
  final double dueAmount;

  final VoidCallback? onPaymentMethodTap;
  final ValueChanged<String>? onPaidAmountChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            InkWell(
              onTap: onPaymentMethodTap,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        paymentMethod,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            TextFormField(
              initialValue: paidAmount.toStringAsFixed(0),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: onPaidAmountChanged,
              decoration: const InputDecoration(
                labelText: 'Paid Amount',
                prefixText: '₹ ',
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dueAmount <= 0
                    ? Colors.green.withValues(alpha: .08)
                    : colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    dueAmount <= 0
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_rounded,
                    color: dueAmount <= 0
                        ? Colors.green
                        : colorScheme.error,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      dueAmount <= 0
                          ? 'Payment Completed'
                          : 'Remaining Due',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    '₹${dueAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: dueAmount <= 0
                          ? Colors.green
                          : colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}