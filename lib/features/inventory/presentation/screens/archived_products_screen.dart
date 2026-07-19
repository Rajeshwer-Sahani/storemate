import 'package:flutter/material.dart';

import '../../data/services/inventory_service.dart';

class ArchivedProductsScreen extends StatefulWidget {
  const ArchivedProductsScreen({super.key});

  @override
  State<ArchivedProductsScreen> createState() => _ArchivedProductsScreenState();
}

class _ArchivedProductsScreenState extends State<ArchivedProductsScreen> {
  final InventoryService _inventoryService = InventoryService();

  List<Map<String, dynamic>> _archivedProducts = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _loadArchivedProducts();
  }

  // ---------------------------------------------------------------------------
  // Load archived products
  // ---------------------------------------------------------------------------

  Future<void> _loadArchivedProducts() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final products = await _inventoryService.getArchivedProducts();

      if (!mounted) {
        return;
      }

      setState(() {
        _archivedProducts = products;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load archived products. Please try again.';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Show restore confirmation
  // ---------------------------------------------------------------------------

  Future<void> _showRestoreConfirmation(Map<String, dynamic> product) async {
    final productName = product['name']?.toString() ?? 'this product';

    final shouldRestore = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final colorScheme = Theme.of(bottomSheetContext).colorScheme;

        return Container(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            MediaQuery.paddingOf(bottomSheetContext).bottom + 20,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bottom-sheet handle
              Container(
                width: 64,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),

              const SizedBox(height: 28),

              // Restore icon
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Icon(
                  Icons.restore_rounded,
                  color: colorScheme.primary,
                  size: 34,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Restore Product?',
                textAlign: TextAlign.center,
                style: Theme.of(bottomSheetContext).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 12),

              Text(
                'Are you sure you want to restore '
                '$productName? It will appear in your '
                'active inventory again.',
                textAlign: TextAlign.center,
                style: Theme.of(bottomSheetContext).textTheme.bodyLarge
                    ?.copyWith(
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

                  // Restore button
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(bottomSheetContext).pop(true);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        icon: const Icon(Icons.restore_rounded, size: 19),
                        label: const Text(
                          'Restore',
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

    if (shouldRestore != true || !mounted) {
      return;
    }

    await _restoreProduct(product);
  }

  // ---------------------------------------------------------------------------
  // Restore product
  // ---------------------------------------------------------------------------

  Future<void> _restoreProduct(Map<String, dynamic> product) async {
    final productId = product['id']?.toString();

    if (productId == null || productId.isEmpty) {
      _showMessage('Unable to restore this product.', isError: true);

      return;
    }

    try {
      await _inventoryService.restoreProduct(productId: productId);

      if (!mounted) {
        return;
      }

      await _loadArchivedProducts();

      if (!mounted) return;

      _showMessage('Product restored successfully.');

      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to restore the product. Please try again.',
        isError: true,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Snackbar
  // ---------------------------------------------------------------------------

  void _showMessage(String message, {bool isError = false}) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? colorScheme.error
              : const Color(0xFF16A34A),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 21,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Products'),
        centerTitle: false,
      ),
      body: RefreshIndicator(
        onRefresh: _loadArchivedProducts,
        child: _buildContent(colorScheme),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Screen content
  // ---------------------------------------------------------------------------

  Widget _buildContent(ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 140),

          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 52),

          const SizedBox(height: 20),

          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),

          const SizedBox(height: 20),

          Center(
            child: FilledButton(
              onPressed: _loadArchivedProducts,
              child: const Text('Try Again'),
            ),
          ),
        ],
      );
    }

    if (_archivedProducts.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 28),
        children: [
          const SizedBox(height: 150),

          Center(
            child: Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                color: colorScheme.primary,
                size: 42,
              ),
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'No archived products',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 12),

          Text(
            'Products you archive will appear here '
            'and can be restored at any time.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        Text(
          'Archived Inventory',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),

        const SizedBox(height: 6),

        Text(
          '${_archivedProducts.length} '
          '${_archivedProducts.length == 1 ? 'product' : 'products'}',
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant),
        ),

        const SizedBox(height: 20),

        ..._archivedProducts.map(
          (product) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ArchivedProductCard(
              product: product,
              onRestore: () {
                _showRestoreConfirmation(product);
              },
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Archived product card
// =============================================================================

class _ArchivedProductCard extends StatelessWidget {
  const _ArchivedProductCard({required this.product, required this.onRestore});

  final Map<String, dynamic> product;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final productName = product['name']?.toString() ?? 'Unnamed product';

    final brand = product['brand']?.toString();

    final categoryData = product['product_categories'];

    final categoryName = categoryData is Map<String, dynamic>
        ? categoryData['name']?.toString()
        : null;

    final sellingPrice = (product['selling_price'] as num?)?.toDouble() ?? 0;

    final details = [
      if (brand != null && brand.trim().isNotEmpty) brand.trim(),

      if (categoryName != null && categoryName.trim().isNotEmpty)
        categoryName.trim(),
    ].join(' • ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: colorScheme.primary,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (details.isNotEmpty) ...[
                  const SizedBox(height: 5),

                  Text(
                    details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                Text(
                  '₹${sellingPrice.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          IconButton(
            tooltip: 'Restore product',
            onPressed: onRestore,
            style: IconButton.styleFrom(
              foregroundColor: colorScheme.primary,
              backgroundColor: colorScheme.primary.withValues(alpha: 0.10),
            ),
            icon: const Icon(Icons.restore_rounded),
          ),
        ],
      ),
    );
  }
}
