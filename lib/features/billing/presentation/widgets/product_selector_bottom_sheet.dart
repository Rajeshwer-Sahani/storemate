import 'package:flutter/material.dart';

import '../../../inventory/data/models/product_model.dart';

class ProductSelectorBottomSheet extends StatefulWidget {
  const ProductSelectorBottomSheet({
    super.key,
    required this.products,
    this.selectedProductIds = const [],
  });

  final List<ProductModel> products;

  /// Already added products
  final List<String> selectedProductIds;

  static Future<ProductModel?> show(
    BuildContext context, {
    required List<ProductModel> products,
    List<String> selectedProductIds = const [],
  }) {
    return showModalBottomSheet<ProductModel>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) {
        return ProductSelectorBottomSheet(
          products: products,
          selectedProductIds: selectedProductIds,
        );
      },
    );
  }

  @override
  State<ProductSelectorBottomSheet> createState() =>
      _ProductSelectorBottomSheetState();
}

class _ProductSelectorBottomSheetState
    extends State<ProductSelectorBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  late List<ProductModel> _filteredProducts;

  @override
  void initState() {
    super.initState();

    _filteredProducts = List.from(widget.products);

    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);

    _searchController.dispose();

    super.dispose();
  }

  void _filterProducts() {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredProducts = List.from(widget.products);
      });
      return;
    }

    setState(() {
      _filteredProducts = widget.products.where((product) {
        return product.name.toLowerCase().contains(query) ||
            (product.brand ?? '').toLowerCase().contains(query) ||
            (product.sku ?? '').toLowerCase().contains(query) ||
            (product.categoryName ?? '').toLowerCase().contains(query);
      }).toList();
    });
  }

  Widget _buildStatusPill({
    required IconData icon,
    required String label,
    required Color color,
    Color? backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor ?? color.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductAvatar(ThemeData theme) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        color: theme.colorScheme.onPrimaryContainer,
        size: 24,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .80,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Product',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Choose products from your inventory.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onPrimaryContainer,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.10,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.inventory_2_rounded,
                            size: 22,
                            color: theme.colorScheme.primary,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Text(
                          '${_filteredProducts.length} Products Available',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  TextField(
                    controller: _searchController,

                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search product, SKU, brand...',
                      prefixIcon: const Icon(Icons.search_rounded),

                      filled: true,

                      fillColor: theme.colorScheme.surface,

                      contentPadding: const EdgeInsets.symmetric(vertical: 18),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outlineVariant,
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: _filteredProducts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.search_off_rounded,
                                size: 30,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Text(
                              'No Products Found',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Try searching using another keyword.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      itemCount: _filteredProducts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = _filteredProducts[index];

                        final alreadyAdded = widget.selectedProductIds.contains(
                          product.id,
                        );

                        final outOfStock = product.stockQuantity <= 0;

                        final lowStock =
                            !outOfStock &&
                            product.stockQuantity <= product.lowStockThreshold;

                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 180 + (index * 35)),
                          curve: Curves.easeOutCubic,
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 16 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: Card(
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                              side: BorderSide(
                                color: theme.colorScheme.outlineVariant,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              splashFactory: InkSparkle.splashFactory,
                              highlightColor: Colors.transparent,
                              overlayColor: WidgetStateProperty.resolveWith((
                                states,
                              ) {
                                if (states.contains(WidgetState.pressed)) {
                                  return theme.colorScheme.primary.withValues(
                                    alpha: .08,
                                  );
                                }
                                return null;
                              }),
                              onTap: outOfStock || alreadyAdded
                                  ? null
                                  : () => Navigator.pop(context, product),
                              child: Opacity(
                                opacity: outOfStock ? .55 : 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildProductAvatar(theme),

                                      const SizedBox(width: 16),

                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    product.name,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: theme
                                                        .textTheme
                                                        .titleMedium
                                                        ?.copyWith(
                                                          fontWeight:
                                                              FontWeight.w700,
                                                        ),
                                                  ),
                                                ),

                                                const SizedBox(width: 10),
                                                AnimatedContainer(
                                                  duration: const Duration(
                                                    milliseconds: 220,
                                                  ),
                                                  curve: Curves.easeOut,

                                                  width: 40,
                                                  height: 40,

                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,

                                                    color: alreadyAdded
                                                        ? Colors.green
                                                        : outOfStock
                                                        ? theme
                                                              .colorScheme
                                                              .surfaceContainerHighest
                                                        : theme
                                                              .colorScheme
                                                              .primary,
                                                  ),

                                                  child: Icon(
                                                    alreadyAdded
                                                        ? Icons.check_rounded
                                                        : outOfStock
                                                        ? Icons.block_rounded
                                                        : Icons.add_rounded,

                                                    color:
                                                        alreadyAdded ||
                                                            !outOfStock
                                                        ? Colors.white
                                                        : theme
                                                              .colorScheme
                                                              .outline,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            const SizedBox(height: 6),

                                            Text(
                                              [
                                                if ((product.brand ?? '')
                                                    .isNotEmpty)
                                                  product.brand!,
                                                if ((product.categoryName ?? '')
                                                    .isNotEmpty)
                                                  product.categoryName!,
                                              ].join(' • '),
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(
                                                    color: theme
                                                        .colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                            ),

                                            const SizedBox(height: 16),

                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                _buildStatusPill(
                                                  icon: Icons.currency_rupee,
                                                  label:
                                                      '₹${product.sellingPrice.toStringAsFixed(0)}',
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),

                                                if (outOfStock)
                                                  _buildStatusPill(
                                                    icon: Icons.block,
                                                    label: 'Out of Stock',
                                                    color: Colors.red,
                                                  )
                                                else if (lowStock)
                                                  _buildStatusPill(
                                                    icon: Icons
                                                        .warning_amber_rounded,
                                                    label:
                                                        '${product.stockQuantity} Left',
                                                    color: Colors.orange,
                                                  )
                                                else
                                                  _buildStatusPill(
                                                    icon: Icons
                                                        .inventory_2_rounded,
                                                    label:
                                                        '${product.stockQuantity} In Stock',
                                                    color: Colors.green,
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
