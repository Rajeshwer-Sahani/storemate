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

  final FocusNode _searchFocusNode = FocusNode();

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
    _searchFocusNode.dispose();

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .85,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Product',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Choose a product to add to the invoice.',
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Search product, SKU, brand...',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),

                  const SizedBox(height: 16),
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
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: theme.colorScheme.outline,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Products Found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try searching by product name, SKU, brand or category.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
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

                        return Card(
                          elevation: 0,
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: outOfStock
                                ? null
                                : () {
                                    Navigator.pop(context, product);
                                  },
                            child: Opacity(
                              opacity: outOfStock ? 0.55 : 1,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      child: Icon(
                                        Icons.inventory_2_rounded,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.name,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                          ),

                                          if ((product.brand ?? '')
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              product.brand!,
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],

                                          if ((product.categoryName ?? '')
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              product.categoryName!,
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],

                                          if ((product.sku ?? '')
                                              .isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              'SKU : ${product.sku}',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                          ],

                                          const SizedBox(height: 12),

                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: [
                                              Chip(
                                                avatar: const Icon(
                                                  Icons.currency_rupee,
                                                  size: 16,
                                                ),
                                                label: Text(
                                                  product.sellingPrice
                                                      .toStringAsFixed(2),
                                                ),
                                              ),

                                              Chip(
                                                avatar: const Icon(
                                                  Icons.inventory,
                                                  size: 16,
                                                ),
                                                label: Text(
                                                  '${product.stockQuantity} in stock',
                                                ),
                                              ),

                                              if (lowStock)
                                                Chip(
                                                  avatar: const Icon(
                                                    Icons.warning_amber,
                                                    size: 16,
                                                  ),
                                                  label: const Text(
                                                    'Low Stock',
                                                  ),
                                                ),

                                              if (outOfStock)
                                                Chip(
                                                  avatar: const Icon(
                                                    Icons.block,
                                                    size: 16,
                                                  ),
                                                  label: const Text(
                                                    'Out of Stock',
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(width: 12),

                                    if (alreadyAdded)
                                      Icon(
                                        Icons.check_circle,
                                        color: theme.colorScheme.primary,
                                      )
                                    else if (!outOfStock)
                                      Icon(
                                        Icons.add_circle_outline,
                                        color: theme.colorScheme.primary,
                                      ),
                                  ],
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
