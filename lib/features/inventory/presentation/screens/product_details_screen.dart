import 'package:flutter/material.dart';

import 'package:storemate/features/inventory/data/models/product_model.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({required this.product, super.key});

  final ProductModel product;

  bool get _isOutOfStock {
    return product.stockQuantity <= 0;
  }

  bool get _isLowStock {
    return product.stockQuantity > 0 &&
        product.stockQuantity <= product.lowStockThreshold;
  }

  String get _stockStatusText {
    if (_isOutOfStock) {
      return 'Out of stock';
    }

    if (_isLowStock) {
      return 'Low stock';
    }

    return 'In stock';
  }

  IconData get _stockStatusIcon {
    if (_isOutOfStock) {
      return Icons.remove_shopping_cart_outlined;
    }

    if (_isLowStock) {
      return Icons.warning_amber_rounded;
    }

    return Icons.check_circle_outline_rounded;
  }

  String _formatPrice(double price) {
    final hasDecimalValue = price % 1 != 0;

    return '₹${price.toStringAsFixed(hasDecimalValue ? 2 : 0)}';
  }

  String _displayValue(String? value, {String fallback = 'Not added'}) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return fallback;
    }

    return trimmedValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final stockStatusColor = _isOutOfStock || _isLowStock
        ? colorScheme.error
        : Colors.green.shade700;

    final stockStatusBackground = _isOutOfStock || _isLowStock
        ? colorScheme.error.withValues(alpha: 0.10)
        : Colors.green.withValues(alpha: 0.10);

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details'), centerTitle: false),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          children: [
            // Product header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                children: [
                  Container(
                    width: 82,
                    height: 82,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    product.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    [
                      if (product.brand != null &&
                          product.brand!.trim().isNotEmpty)
                        product.brand!.trim(),
                      if (product.categoryName != null) product.categoryName!,
                    ].join(' • '),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: stockStatusBackground,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _stockStatusIcon,
                          size: 18,
                          color: stockStatusColor,
                        ),

                        const SizedBox(width: 7),

                        Text(
                          _stockStatusText,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: stockStatusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Stock overview
            _SectionHeading(
              title: 'Stock Overview',
              subtitle: 'Current inventory information.',
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    icon: Icons.layers_outlined,
                    value: product.stockQuantity.toString(),
                    label: 'Stock Units',
                    iconColor: colorScheme.primary,
                    iconBackground: colorScheme.primary.withValues(alpha: 0.10),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _SummaryCard(
                    icon: Icons.warning_amber_rounded,
                    value: product.lowStockThreshold.toString(),
                    label: 'Low-stock Alert',
                    iconColor: colorScheme.error,
                    iconBackground: colorScheme.error.withValues(alpha: 0.10),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // Pricing
            _SectionHeading(
              title: 'Pricing',
              subtitle: 'Buying and selling prices.',
            ),

            const SizedBox(height: 14),

            _InformationCard(
              children: [
                _InformationRow(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Purchase price',
                  value: _formatPrice(product.purchasePrice),
                ),

                const _InformationDivider(),

                _InformationRow(
                  icon: Icons.sell_outlined,
                  label: 'Selling price',
                  value: _formatPrice(product.sellingPrice),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // Product information
            _SectionHeading(
              title: 'Product Information',
              subtitle: 'General product details.',
            ),

            const SizedBox(height: 14),

            _InformationCard(
              children: [
                _InformationRow(
                  icon: Icons.category_outlined,
                  label: 'Category',
                  value: _displayValue(product.categoryName),
                ),

                const _InformationDivider(),

                _InformationRow(
                  icon: Icons.sell_outlined,
                  label: 'Brand',
                  value: _displayValue(product.brand),
                ),

                const _InformationDivider(),

                _InformationRow(
                  icon: Icons.qr_code_rounded,
                  label: 'SKU / Product code',
                  value: _displayValue(product.sku),
                ),
              ],
            ),

            const SizedBox(height: 26),

            // Description
            _SectionHeading(
              title: 'Description',
              subtitle: 'Additional product information.',
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Text(
                _displayValue(
                  product.description,
                  fallback: 'No description has been added for this product.',
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color:
                      product.description == null ||
                          product.description!.trim().isEmpty
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Section heading
// -----------------------------------------------------------------------------

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Stock summary card
// -----------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
    required this.iconBackground,
  });

  final IconData icon;

  final String value;

  final String label;

  final Color iconColor;

  final Color iconBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: iconColor),
          ),

          const SizedBox(height: 16),

          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Information container
// -----------------------------------------------------------------------------

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}

// -----------------------------------------------------------------------------
// Information row
// -----------------------------------------------------------------------------

class _InformationRow extends StatelessWidget {
  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;

  final String label;

  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 17),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 21, color: colorScheme.primary),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Divider
// -----------------------------------------------------------------------------

class _InformationDivider extends StatelessWidget {
  const _InformationDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}
