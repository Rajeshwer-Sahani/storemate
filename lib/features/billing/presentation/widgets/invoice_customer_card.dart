import 'package:flutter/material.dart';

class InvoiceCustomerCard extends StatelessWidget {
  const InvoiceCustomerCard({
    super.key,
    this.customerName,
    this.customerPhone,
    this.onTap,
  });

  final String? customerName;
  final String? customerPhone;
  final VoidCallback? onTap;

  bool get _hasCustomer =>
      customerName != null && customerName!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _hasCustomer
                      ? Icons.person_rounded
                      : Icons.person_add_alt_1_rounded,
                  color: colorScheme.primary,
                  size: 26,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasCustomer ? customerName! : 'Select Customer',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _hasCustomer
                          ? (customerPhone ?? '')
                          : 'Select a customer for this invoice',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              FilledButton.icon(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(90, 44),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: Icon(
                  _hasCustomer
                      ? Icons.swap_horiz_rounded
                      : Icons.person_search_rounded,
                  size: 18,
                ),
                label: Text(
                  _hasCustomer ? 'Change' : 'Select',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
