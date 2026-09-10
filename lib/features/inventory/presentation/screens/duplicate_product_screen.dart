import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/product_icon.dart';
import 'package:storemate/features/inventory/data/models/product_model.dart';

class DuplicateProductScreen extends StatefulWidget {
  const DuplicateProductScreen({super.key, required this.products});

  final List<ProductModel> products;

  @override
  State<DuplicateProductScreen> createState() => _DuplicateProductScreenState();
}

class _DuplicateProductScreenState extends State<DuplicateProductScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final products = widget.products.where((product) {
      final query = _query.toLowerCase();

      return product.name.toLowerCase().contains(query) ||
          (product.sku ?? '').toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Duplicate Product',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Choose a product to use as a starting point.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.45,
                letterSpacing: 0.05,
              ),
            ),

            const SizedBox(height: 18),

            // -----------------------------------------------------------------
            // Search
            // -----------------------------------------------------------------
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _query = value.trim();
                });
              },
              style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search products',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 27,
                ),
                filled: true,
                fillColor: isDark
                    ? colorScheme.surfaceContainerHighest
                    : colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 17,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: colorScheme.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // -----------------------------------------------------------------
            // Product list
            // -----------------------------------------------------------------
            if (products.isEmpty)
              _EmptyProductsState(query: _query)
            else
              ...products.map(
                (product) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _DuplicateProductTile(
                    product: product,
                    onTap: () {
                      Navigator.of(context).pop(product);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Duplicate Product Tile
// =============================================================================

class _DuplicateProductTile extends StatelessWidget {
  const _DuplicateProductTile({required this.product, required this.onTap});

  final ProductModel product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Row(
              children: [
                // -------------------------------------------------------------
                // Product icon
                // -------------------------------------------------------------
                ProductIcon(
                  product: {
                    ...product.toJson(),
                    'product_categories': {'name': product.categoryName},
                  },
                  size: 64,
                  iconSize: 30,
                  borderRadius: 18,
                ),

                const SizedBox(width: 16),

                // -------------------------------------------------------------
                // Product information
                // -------------------------------------------------------------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        'Selling price: ${product.sellingPrice.toStringAsFixed(2)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // -------------------------------------------------------------
                // Arrow
                // -------------------------------------------------------------
                Icon(
                  Icons.chevron_right_rounded,
                  color: colorScheme.onSurfaceVariant,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Empty State
// =============================================================================

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 46,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 14),
          Text(
            query.isEmpty
                ? 'No products available.'
                : 'No matching products found.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          if (query.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Try searching with a different name or SKU.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
