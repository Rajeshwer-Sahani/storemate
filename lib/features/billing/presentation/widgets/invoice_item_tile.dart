import 'package:flutter/material.dart';

class InvoiceItemTile extends StatelessWidget {
  const InvoiceItemTile({
    super.key,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.subtitle,
    this.onTap,
    this.onDelete,
    this.leading,
  });

  final String productName;
  final String? subtitle;

  final int quantity;
  final double unitPrice;
  final double totalPrice;

  final Widget? leading;

  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colorScheme.outlineVariant.withOpacity(.45)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //---------------------------------------------------------------
              // TOP SECTION
              //---------------------------------------------------------------
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeading(context),

                  const SizedBox(width: 16),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          productName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),

                        if (subtitle != null &&
                            subtitle!.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),

                          Text(
                            subtitle!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              //---------------------------------------------------------------
              // INFORMATION
              //---------------------------------------------------------------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _InfoTile(
                            title: 'Quantity',
                            value: quantity.toString(),
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 34,
                          color: colorScheme.outlineVariant,
                        ),

                        Expanded(
                          child: _InfoTile(
                            title: 'Unit Price',
                            value: '₹${unitPrice.toStringAsFixed(2)}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              //---------------------------------------------------------------
              // FOOTER
              //---------------------------------------------------------------
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '₹${totalPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  FilledButton.tonalIcon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                    label: const Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child:
          leading ??
          Icon(
            Icons.inventory_2_rounded,
            size: 30,
            color: theme.colorScheme.primary,
          ),
    );
  }
}


class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall
              ?.copyWith(
            color:
                colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall
              ?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}