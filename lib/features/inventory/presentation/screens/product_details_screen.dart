import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/product_icon.dart';
import 'package:storemate/features/inventory/data/services/inventory_service.dart';
import 'package:storemate/features/inventory/data/models/product_model.dart';
import 'package:storemate/features/inventory/presentation/screens/edit_product_screen.dart';
import 'package:storemate/features/inventory/presentation/widgets/adjust_stock_bottom_sheet.dart';
import 'package:storemate/features/inventory/presentation/screens/stock_history_screen.dart';

class ProductDetailsScreen extends StatelessWidget {
  ProductDetailsScreen({required this.product, super.key});

  final ProductModel product;
  final InventoryService _inventoryService = InventoryService();

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

  Future<void> _showArchiveConfirmation(BuildContext context) async {
    final shouldArchive = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final theme = Theme.of(bottomSheetContext);

        final colorScheme = theme.colorScheme;

        return Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom-sheet handle
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 28),

              // Archive icon
              // Archive icon
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  color: colorScheme.error,
                  size: 34,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Archive Product?',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                'Are you sure you want to archive '
                '${product.name}? It will be removed '
                'from your active inventory.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 28),

              Row(
                children: [
                  // Cancel button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(bottomSheetContext).pop(false);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(
                            color: colorScheme.primary,
                            width: 1.5,
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Archive button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(bottomSheetContext).pop(true);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.archive_outlined, size: 19),
                        label: const Text(
                          'Archive',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (shouldArchive != true || !context.mounted) {
      return;
    }

    await _archiveProduct(context);
  }

  Future<void> _archiveProduct(BuildContext context) async {
    try {
      await _inventoryService.archiveProduct(productId: product.id);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.white,
                  size: 21,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Unable to archive the product. '
                    'Please try again.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        );
    }
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
      appBar: AppBar(
        title: const Text('Product Details'),
        centerTitle: false,
        actions: [
          // Edit Product
          IconButton(
            tooltip: 'Edit product',
            onPressed: () async {
              final wasUpdated = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                  builder: (_) {
                    return EditProductScreen(product: product);
                  },
                ),
              );

              if (wasUpdated == true && context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
            icon: const Icon(Icons.edit_outlined),
          ),

          // Product options
          PopupMenuButton<String>(
            tooltip: 'Product options',
            icon: const Icon(Icons.more_vert_rounded),
            position: PopupMenuPosition.under,
            onSelected: (action) async {
              if (action == 'archive') {
                await _showArchiveConfirmation(context);
              }
            },
            itemBuilder: (context) {
              final colorScheme = Theme.of(context).colorScheme;

              return [
                PopupMenuItem<String>(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(
                        Icons.archive_outlined,
                        size: 21,
                        color: colorScheme.error,
                      ),

                      const SizedBox(width: 12),

                      Text(
                        'Archive Product',
                        style: TextStyle(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
          ),

          const SizedBox(width: 8),
        ],
      ),
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
                  ProductIcon(
                    product: {
                      'name': product.name,
                      'brand': product.brand,
                      'product_categories': {'name': product.categoryName},
                    },
                    size: 82,
                    iconSize: 40,
                    borderRadius: 24,
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

            const SizedBox(height: 16),

            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StockHistoryScreen(
                      productId: product.id,
                      productName: product.name,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.history_rounded,
                        color: Colors.indigo.shade600,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stock History',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'View every stock adjustment',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
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
                  iconColor: Colors.green.shade600,
                  iconBackground: Colors.green.withValues(alpha: 0.10),
                ),

                const _InformationDivider(),

                _InformationRow(
                  icon: Icons.sell_outlined,
                  label: 'Selling price',
                  value: _formatPrice(product.sellingPrice),
                  iconColor: Colors.orange.shade700,
                  iconBackground: Colors.orange.withValues(alpha: 0.10),
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
                  iconColor: Colors.purple.shade600,
                  iconBackground: Colors.purple.withValues(alpha: 0.10),
                ),

                const _InformationDivider(),

                _InformationRow(
                  icon: Icons.sell_outlined,
                  label: 'Brand',
                  value: _displayValue(product.brand),
                  iconColor: Colors.blue.shade600,
                  iconBackground: Colors.blue.withValues(alpha: 0.10),
                ),

                const _InformationDivider(),

                _InformationRow(
                  icon: Icons.qr_code_rounded,
                  label: 'SKU / Product code',
                  value: _displayValue(product.sku),
                  iconColor: Colors.teal.shade600,
                  iconBackground: Colors.teal.withValues(alpha: 0.10),
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

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                icon: const Icon(Icons.swap_horiz_rounded),
                label: const Text('Adjust Stock'),
                onPressed: () async {
                  final result =
                      await showModalBottomSheet<Map<String, dynamic>>(
                        context: context,
                        isScrollControlled: true,
                        useSafeArea: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) {
                          return AdjustStockBottomSheet(
                            product: {
                              'id': product.id,
                              'name': product.name,
                              'stock_quantity': product.stockQuantity,
                              'brand': product.brand,
                              'product_categories': {
                                'name': product.categoryName,
                              },
                            },
                          );
                        },
                      );

                  if (!context.mounted || result == null) {
                    return;
                  }

                  // Return only a success flag to InventoryScreen.
                  // The InventoryScreen only needs to know that something changed.
                  Navigator.of(context).pop(true);
                },
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
    this.iconColor,
    this.iconBackground,
  });

  final IconData icon;

  final String label;

  final String value;

  final Color? iconColor;

  final Color? iconBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final resolvedIconColor = iconColor ?? colorScheme.primary;

    final resolvedIconBackground =
        iconBackground ?? colorScheme.primary.withValues(alpha: 0.09);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 17),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: resolvedIconBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 21, color: resolvedIconColor),
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
