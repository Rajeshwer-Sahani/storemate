import 'package:flutter/material.dart';

class PaymentCard extends StatefulWidget {
  const PaymentCard({
    super.key,
    required this.paymentMethod,
    required this.paidAmount,
    required this.grandTotal,
    required this.dueAmount,
    this.onPaymentMethodTap,
    this.onPaidAmountChanged,
  });

  final String paymentMethod;
  final double paidAmount;
  final double dueAmount;
  final double grandTotal;

  final VoidCallback? onPaymentMethodTap;
  final ValueChanged<String>? onPaidAmountChanged;

  @override
  State<PaymentCard> createState() => _PaymentCardState();
}

class _PaymentCardState extends State<PaymentCard> {
  late final TextEditingController _paidController;

  @override
  void initState() {
    super.initState();

    _paidController = TextEditingController(
      text: widget.paidAmount == 0 ? '' : widget.paidAmount.toStringAsFixed(0),
    );
  }

  @override
  void didUpdateWidget(covariant PaymentCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    final text = widget.paidAmount == 0
        ? ''
        : widget.paidAmount.toStringAsFixed(0);

    if (_paidController.text != text) {
      _paidController.text = text;
    }
  }

  @override
  void dispose() {
    _paidController.dispose();
    super.dispose();
  }

  IconData _paymentIcon() {
    switch (widget.paymentMethod) {
      case 'Cash':
        return Icons.payments_rounded;

      case 'UPI':
        return Icons.qr_code_scanner_rounded;

      case 'Card':
        return Icons.credit_card_rounded;

      case 'Bank Transfer':
        return Icons.account_balance_rounded;

      case 'Cheque':
        return Icons.receipt_long_rounded;

      default:
        return Icons.wallet_rounded;
    }
  }

  String _paymentSubtitle() {
    switch (widget.paymentMethod) {
      case 'Cash':
        return 'Physical cash payment';

      case 'UPI':
        return 'PhonePe, Google Pay, Paytm';

      case 'Card':
        return 'Credit or Debit Card';

      case 'Bank Transfer':
        return 'NEFT, IMPS, RTGS';

      case 'Cheque':
        return 'Cheque payment';

      default:
        return 'Any other payment';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final dueAmount = widget.dueAmount;

    final bool hasChange = widget.paidAmount > widget.grandTotal;

    final bool isPaid = widget.paidAmount == widget.grandTotal;

    final double changeAmount = hasChange
        ? widget.paidAmount - widget.grandTotal
        : 0;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onPaymentMethodTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: .6),
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_paymentIcon(), color: colorScheme.primary),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.paymentMethod,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 2),

                            Text(
                              _paymentSubtitle(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.expand_more_rounded),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            TextFormField(
              controller: _paidController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              onChanged: widget.onPaidAmountChanged,
              decoration: InputDecoration(
                labelText: 'Paid Amount',
                prefixText: '₹ ',
                hintText: 'Enter received amount',
                prefixIcon: Icon(
                  Icons.currency_rupee_rounded,
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 18),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: hasChange
                    ? colorScheme.primary.withValues(alpha: .08)
                    : isPaid
                    ? Colors.green.withValues(alpha: .08)
                    : colorScheme.errorContainer.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hasChange
                      ? Colors.blue.withValues(alpha: .35)
                      : isPaid
                      ? Colors.green.withValues(alpha: .35)
                      : colorScheme.error.withValues(alpha: .20),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    hasChange
                        ? Icons.currency_exchange_rounded
                        : isPaid
                        ? Icons.check_circle_rounded
                        : Icons.warning_amber_rounded,
                    size: 34,
                    color: hasChange
                        ? colorScheme.primary
                        : isPaid
                        ? Colors.green
                        : colorScheme.error,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    hasChange
                        ? 'Change to Return'
                        : isPaid
                        ? 'Payment Completed'
                        : 'Remaining Due',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: hasChange
                          ? colorScheme.primary
                          : isPaid
                          ? Colors.green
                          : colorScheme.error,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    hasChange
                        ? '₹${changeAmount.toStringAsFixed(2)}'
                        : '₹${dueAmount.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasChange
                          ? colorScheme.primary
                          : isPaid
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
