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
      customerName != null &&
      customerName!.trim().isNotEmpty;

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
              CircleAvatar(
                radius: 26,
                backgroundColor: _hasCustomer
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
                child: Icon(
                  _hasCustomer
                      ? Icons.person
                      : Icons.person_add_alt_1,
                  color: _hasCustomer
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hasCustomer
                          ? customerName!
                          : 'Select Customer',
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
                          : 'Tap to choose a customer',
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

              FilledButton.tonal(
                onPressed: onTap,
                child: Text(
                  _hasCustomer ? 'Change' : 'Select',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}