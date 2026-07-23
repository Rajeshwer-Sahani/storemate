import 'package:flutter/material.dart';

const paymentMethods = [
  ('Cash', Icons.payments_rounded, 'Physical cash payment'),
  ('UPI', Icons.qr_code_scanner_rounded, 'PhonePe, Google Pay, Paytm'),
  ('Card', Icons.credit_card_rounded, 'Credit or Debit Card'),
  ('Bank Transfer', Icons.account_balance_rounded, 'NEFT, IMPS, RTGS'),
  ('Cheque', Icons.receipt_long_rounded, 'Cheque payment'),
  ('Other', Icons.wallet_rounded, 'Any other payment'),
];

class PaymentMethodBottomSheet extends StatelessWidget {
  const PaymentMethodBottomSheet({super.key, this.selectedMethod});

  final String? selectedMethod;

  static Future<String?> show(BuildContext context, {String? selectedMethod}) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PaymentMethodBottomSheet(selectedMethod: selectedMethod),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.78,
      minChildSize: 0.60,
      maxChildSize: 0.90,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),

              Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Payment Method',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choose how the customer paid.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: paymentMethods.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = paymentMethods[index];

                    return _PaymentMethodTile(
                      title: item.$1,
                      subtitle: item.$3,
                      icon: item.$2,
                      selected: selectedMethod == item.$1,
                      onTap: () => Navigator.pop(context, item.$1),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: .08)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: .10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: colorScheme.primary),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: selected
                      ? Icon(
                          Icons.check_circle,
                          key: const ValueKey('selected'),
                          color: colorScheme.primary,
                        )
                      : Icon(
                          Icons.chevron_right_rounded,
                          key: const ValueKey('normal'),
                          color: colorScheme.onSurfaceVariant,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
