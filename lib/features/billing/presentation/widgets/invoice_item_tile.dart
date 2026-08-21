import 'package:flutter/material.dart';

class InvoiceItemTile extends StatelessWidget {
  const InvoiceItemTile({
    super.key,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.returnedQuantity = 0,
    this.originalPrice,
    this.returnedAmount,
    this.netAmount,
    this.subtitle,
    this.onTap,
    this.onDelete,
    this.leading,
    this.onIncrease,
    this.onDecrease,
    this.editable = true,
  });

  final String productName;
  final String? subtitle;

  final int quantity;
  final double unitPrice;
  final double totalPrice;

  /// Quantity already returned by the customer.
  ///
  /// Defaults to 0 so Create Invoice and Edit Invoice remain unchanged.
  final int returnedQuantity;

  /// Original item amount before returns.
  ///
  /// Only used by the non-editable Invoice Details view.
  final double? originalPrice;

  /// Value of the returned quantity.
  ///
  /// Only used by the non-editable Invoice Details view.
  final double? returnedAmount;

  /// Final item amount after return.
  ///
  /// Only used by the non-editable Invoice Details view.
  final double? netAmount;

  final Widget? leading;

  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  /// Whether the item can be edited.
  ///
  /// true  -> Create Invoice
  /// false -> Invoice Details
  final bool editable;

  int get remainingQuantity {
    final remaining = quantity - returnedQuantity;
    return remaining < 0 ? 0 : remaining;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: .08),
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: .75),
          width: 1.2,
        ),
      ),

      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
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
                    child: SizedBox(
                      height: 64,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                  ),
                ],
              ),

              const SizedBox(height: 20),

              //---------------------------------------------------------------
              // INFORMATION
              //---------------------------------------------------------------
              //---------------------------------------------------------------
              // INFORMATION
              //---------------------------------------------------------------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface.withValues(alpha: .55),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withValues(alpha: .35),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: editable
                    ? _buildEditableInformation(context)
                    : _buildReturnAwareInformation(context),
              ),

              const SizedBox(height: 22),

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
                        editable ? 'Total' : 'Net Amount',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          '₹${totalPrice.toStringAsFixed(2)}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (editable)
                    InkWell(
                      onTap: onDelete,
                      splashColor: colorScheme.primary.withValues(alpha: .08),
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: colorScheme.error.withValues(alpha: .30),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableInformation(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                'Quantity',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 10),

              _QuantityStepper(
                quantity: quantity,
                onDecrease: onDecrease,
                onIncrease: onIncrease,
              ),
            ],
          ),
        ),

        Container(width: 1, height: 34, color: colorScheme.outlineVariant),

        Expanded(
          child: _InfoTile(
            title: 'Unit Price',
            value: '₹${unitPrice.toStringAsFixed(2)}',
          ),
        ),
      ],
    );
  }

  Widget _buildReturnAwareInformation(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _InfoTile(title: 'Sold', value: '$quantity'),
            ),

            Container(width: 1, height: 34, color: colorScheme.outlineVariant),

            Expanded(
              child: _InfoTile(title: 'Returned', value: '$returnedQuantity'),
            ),

            Container(width: 1, height: 34, color: colorScheme.outlineVariant),

            Expanded(
              child: _InfoTile(title: 'Remaining', value: '$remainingQuantity'),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Divider(
          height: 1,
          color: colorScheme.outlineVariant.withValues(alpha: .5),
        ),

        const SizedBox(height: 14),

        _InfoRow(
          title: 'Unit Price',
          value: '₹${unitPrice.toStringAsFixed(2)}',
        ),

        if (originalPrice != null) ...[
          const SizedBox(height: 8),
          _InfoRow(
            title: 'Original Amount',
            value: '₹${originalPrice!.toStringAsFixed(2)}',
          ),
        ],

        if (returnedAmount != null && returnedAmount! > 0) ...[
          const SizedBox(height: 8),
          _InfoRow(
            title: 'Returned Amount',
            value: '₹${returnedAmount!.toStringAsFixed(2)}',
          ),
        ],

        if (netAmount != null) ...[
          const SizedBox(height: 8),
          _InfoRow(
            title: 'Net Amount',
            value: '₹${netAmount!.toStringAsFixed(2)}',
            emphasize: true,
          ),
        ],
      ],
    );
  }

  Widget _buildLeading(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: .08)),
      ),
      alignment: Alignment.center,
      child:
          leading ??
          Icon(Icons.inventory_2_rounded, size: 32, color: colorScheme.primary),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: theme.textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          value,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.title,
    required this.value,
    this.emphasize = false,
  });

  final String title;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: emphasize ? FontWeight.w600 : FontWeight.w500,
          ),
        ),

        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: emphasize ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    this.onIncrease,
    this.onDecrease,
  });

  final int quantity;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: .5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            onTap: onDecrease,
            child: SizedBox(
              width: 34,
              height: 38,
              child: Icon(Icons.remove, size: 18, color: colorScheme.primary),
            ),
          ),

          Container(
            width: 1,
            height: 22,
            color: colorScheme.outlineVariant.withValues(alpha: .5),
          ),

          SizedBox(
            width: 34,
            child: Center(
              child: Text(
                '$quantity',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Container(
            width: 1,
            height: 22,
            color: colorScheme.outlineVariant.withValues(alpha: .5),
          ),

          InkWell(
            borderRadius: const BorderRadius.horizontal(
              right: Radius.circular(12),
            ),
            onTap: onIncrease,
            child: SizedBox(
              width: 34,
              height: 38,
              child: Icon(Icons.add, size: 18, color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
