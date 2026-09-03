import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/product_icon.dart';
import 'package:storemate/features/inventory/data/models/product_model.dart';
import 'package:storemate/features/inventory/presentation/screens/manage_categories_screen.dart';
import 'package:storemate/features/inventory/data/services/inventory_service.dart';
import 'package:storemate/features/inventory/presentation/screens/add_product_screen.dart';
import 'package:storemate/features/inventory/presentation/screens/archived_products_screen.dart';
import 'package:storemate/features/inventory/presentation/screens/product_details_screen.dart';

// =============================================================================
// Inventory Filter and Sort Options
// =============================================================================

enum ProductStockFilter { all, inStock, lowStock, outOfStock }

enum ProductSortOption {
  newestFirst,
  nameAscending,
  nameDescending,
  priceLowToHigh,
  priceHighToLow,
  stockLowToHigh,
  stockHighToLow,
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() {
    return _InventoryScreenState();
  }
}

class _InventoryScreenState extends State<InventoryScreen> {
  final InventoryService _inventoryService = InventoryService();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, dynamic>> _products = [];

  bool _isLoading = true;

  String? _errorMessage;

  String _searchQuery = '';

  ProductStockFilter _selectedStockFilter = ProductStockFilter.all;

  ProductSortOption _selectedSortOption = ProductSortOption.newestFirst;

  // ---------------------------------------------------------------------------
  // Screen lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Load products from Supabase
  // ---------------------------------------------------------------------------

  Future<void> _loadProducts({bool showLoadingIndicator = true}) async {
    if (showLoadingIndicator && mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final products = await _inventoryService.getProducts();

      if (!mounted) {
        return;
      }

      setState(() {
        _products = products;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load inventory. Please try again.';
      });
    }
  }

  // ---------------------------------------------------------------------------
  // Open Add Product screen
  // ---------------------------------------------------------------------------

  Future<void> _openAddProductScreen() async {
    final wasProductAdded = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) {
          return const AddProductScreen();
        },
      ),
    );

    if (wasProductAdded == true) {
      await _loadProducts(showLoadingIndicator: false);

      if (!mounted) {
        return;
      }

      _showMessage('Inventory updated successfully.');
    }
  }

  // ---------------------------------------------------------------------------
  // Open Archived Products screen
  // ---------------------------------------------------------------------------

  Future<void> _openArchivedProductsScreen() async {
    final wasProductRestored = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) {
          return const ArchivedProductsScreen();
        },
      ),
    );

    if (wasProductRestored != true || !mounted) {
      return;
    }

    await _loadProducts(showLoadingIndicator: false);

    if (!mounted) {
      return;
    }

    _showMessage('Product restored successfully.');
  }

  // ---------------------------------------------------------------------------
  // Open Manage Categories screen
  // ---------------------------------------------------------------------------

  Future<void> _openManageCategoriesScreen() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) {
          return const ManageCategoriesScreen();
        },
      ),
    );

    if (!mounted) {
      return;
    }

    // Refresh Inventory because category names may have been renamed
    // while the owner was managing categories.
    await _loadProducts(showLoadingIndicator: false);
  }

  // ---------------------------------------------------------------------------
  // Open Product Details screen
  // ---------------------------------------------------------------------------

  Future<void> _openProductDetails(Map<String, dynamic> product) async {
    final productModel = ProductModel.fromJson(product);

    final wasUpdated = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) {
          return ProductDetailsScreen(product: productModel);
        },
      ),
    );

    if (!mounted || wasUpdated != true) {
      return;
    }

    await _loadProducts();

    if (!mounted) {
      return;
    }

    _showMessage('Product updated successfully.');
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isError
              ? colorScheme.error
              : const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          elevation: 6,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Product helpers
  // ---------------------------------------------------------------------------

  List<Map<String, dynamic>> get _filteredProducts {
    final normalizedQuery = _searchQuery.trim().toLowerCase();

    // Create a new list so filtering and sorting never modify _products.
    var visibleProducts = List<Map<String, dynamic>>.from(_products);

    // ---------------------------------------------------------------------------
    // Apply stock filter
    // ---------------------------------------------------------------------------

    visibleProducts = visibleProducts.where((product) {
      final stockQuantity = _readInteger(product['stock_quantity']);

      final lowStockThreshold = _readInteger(product['low_stock_threshold']);

      switch (_selectedStockFilter) {
        case ProductStockFilter.all:
          return true;

        case ProductStockFilter.inStock:
          return stockQuantity > lowStockThreshold;

        case ProductStockFilter.lowStock:
          return stockQuantity > 0 && stockQuantity <= lowStockThreshold;

        case ProductStockFilter.outOfStock:
          return stockQuantity == 0;
      }
    }).toList();

    // ---------------------------------------------------------------------------
    // Apply product search
    // ---------------------------------------------------------------------------

    if (normalizedQuery.isNotEmpty) {
      visibleProducts = visibleProducts.where((product) {
        final productName = (product['name'] ?? '')
            .toString()
            .trim()
            .toLowerCase();

        final brand = (product['brand'] ?? '').toString().trim().toLowerCase();

        final sku = (product['sku'] ?? '').toString().trim().toLowerCase();

        final categoryData = product['product_categories'];

        final categoryName = categoryData is Map
            ? (categoryData['name'] ?? '').toString().trim().toLowerCase()
            : '';

        return productName.contains(normalizedQuery) ||
            brand.contains(normalizedQuery) ||
            categoryName.contains(normalizedQuery) ||
            sku.contains(normalizedQuery);
      }).toList();
    }

    // ---------------------------------------------------------------------------
    // Apply product sorting
    // ---------------------------------------------------------------------------

    visibleProducts.sort((firstProduct, secondProduct) {
      switch (_selectedSortOption) {
        case ProductSortOption.newestFirst:
          final firstCreatedAt = _readDateTime(firstProduct['created_at']);

          final secondCreatedAt = _readDateTime(secondProduct['created_at']);

          return secondCreatedAt.compareTo(firstCreatedAt);

        case ProductSortOption.nameAscending:
          return _readProductName(
            firstProduct,
          ).compareTo(_readProductName(secondProduct));

        case ProductSortOption.nameDescending:
          return _readProductName(
            secondProduct,
          ).compareTo(_readProductName(firstProduct));

        case ProductSortOption.priceLowToHigh:
          final firstPrice = _readDouble(firstProduct['selling_price']);

          final secondPrice = _readDouble(secondProduct['selling_price']);

          return firstPrice.compareTo(secondPrice);

        case ProductSortOption.priceHighToLow:
          final firstPrice = _readDouble(firstProduct['selling_price']);

          final secondPrice = _readDouble(secondProduct['selling_price']);

          return secondPrice.compareTo(firstPrice);

        case ProductSortOption.stockLowToHigh:
          final firstStock = _readInteger(firstProduct['stock_quantity']);

          final secondStock = _readInteger(secondProduct['stock_quantity']);

          return firstStock.compareTo(secondStock);

        case ProductSortOption.stockHighToLow:
          final firstStock = _readInteger(firstProduct['stock_quantity']);

          final secondStock = _readInteger(secondProduct['stock_quantity']);

          return secondStock.compareTo(firstStock);
      }
    });

    return visibleProducts;
  }

  // ---------------------------------------------------------------------------
  // Inventory summary values
  // ---------------------------------------------------------------------------

  int get _totalProducts {
    return _products.length;
  }

  int get _totalStockUnits {
    return _products.fold<int>(0, (total, product) {
      return total + _readInteger(product['stock_quantity']);
    });
  }

  int get _lowStockProducts {
    return _products.where((product) {
      final stockQuantity = _readInteger(product['stock_quantity']);

      final lowStockThreshold = _readInteger(product['low_stock_threshold']);

      return stockQuantity <= lowStockThreshold;
    }).length;
  }

  // ---------------------------------------------------------------------------
  // Product value helpers
  // ---------------------------------------------------------------------------

  String _readProductName(Map<String, dynamic> product) {
    return (product['name'] ?? '').toString().trim().toLowerCase();
  }

  DateTime _readDateTime(dynamic value) {
    return DateTime.tryParse(value?.toString() ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
  }

  int _readInteger(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _readDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _InventoryHeader(
                onAddProduct: _openAddProductScreen,
                onOpenArchivedProducts: _openArchivedProductsScreen,
                onOpenManageCategories: _openManageCategoriesScreen,
              ),

              Expanded(child: _buildContent(theme)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return _InventoryErrorState(
        message: _errorMessage!,
        onRetry: _loadProducts,
      );
    }

    if (_products.isEmpty) {
      return _EmptyInventoryState(
        onAddProduct: _openAddProductScreen,
        onRefresh: () {
          return _loadProducts(showLoadingIndicator: false);
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () {
        return _loadProducts(showLoadingIndicator: false);
      },
      child: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  _InventorySummary(
                    totalProducts: _totalProducts,
                    totalStockUnits: _totalStockUnits,
                    lowStockProducts: _lowStockProducts,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          textInputAction: TextInputAction.search,
                          autocorrect: false,
                          enableSuggestions: false,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Search products, brands or SKU',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _searchQuery.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    onPressed: () {
                                      _searchController.clear();
                                      _searchFocusNode.unfocus();

                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          SizedBox(
                            width: 56,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: _showFilterAndSortSheet,
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                side: BorderSide(
                                  color: _hasActiveFilterOrSort
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                ),
                                backgroundColor: _hasActiveFilterOrSort
                                    ? Theme.of(context).colorScheme.primary
                                          .withValues(alpha: 0.10)
                                    : Theme.of(context).colorScheme.surface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                color: _hasActiveFilterOrSort
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),

                          if (_hasActiveFilterOrSort)
                            Positioned(
                              top: -3,
                              right: -3,
                              child: Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _searchQuery.trim().isEmpty
                              ? 'All Products'
                              : 'Search Results',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      Text(
                        '${_filteredProducts.length} '
                        '${_filteredProducts.length == 1 ? 'product' : 'products'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),

          if (_filteredProducts.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _NoSearchResultsState(searchQuery: _searchQuery.trim()),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 140),
              sliver: SliverList.separated(
                itemCount: _filteredProducts.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 12);
                },
                itemBuilder: (context, index) {
                  final product = _filteredProducts[index];

                  return _ProductCard(
                    product: product,
                    onTap: () {
                      _openProductDetails(product);
                    },
                    readInteger: _readInteger,
                    readDouble: _readDouble,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  bool get _hasActiveFilterOrSort {
    return _selectedStockFilter != ProductStockFilter.all ||
        _selectedSortOption != ProductSortOption.newestFirst;
  }

  Future<void> _showFilterAndSortSheet() async {
    ProductStockFilter temporaryStockFilter = _selectedStockFilter;
    ProductSortOption temporarySortOption = _selectedSortOption;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final colorScheme = Theme.of(context).colorScheme;
            final textTheme = Theme.of(context).textTheme;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.88,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(32),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),

                  // Bottom-sheet drag handle
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.tune_rounded,
                            size: 24,
                            color: colorScheme.primary,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Filter & Sort',
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Refine how your products are displayed.',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          tooltip: 'Close',
                          onPressed: () {
                            Navigator.of(bottomSheetContext).pop();
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  Divider(height: 1, color: colorScheme.outlineVariant),

                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // -----------------------------------------------------
                          // Stock filter
                          // -----------------------------------------------------
                          Text(
                            'Stock Status',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Show products based on their stock availability.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: ProductStockFilter.values.map((filter) {
                              final isSelected = temporaryStockFilter == filter;

                              return ChoiceChip(
                                selected: isSelected,
                                showCheckmark: false,
                                label: Text(_stockFilterLabel(filter)),
                                avatar: Icon(
                                  _stockFilterIcon(filter),
                                  size: 18,
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurfaceVariant,
                                ),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? colorScheme.onPrimary
                                      : colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                                selectedColor: colorScheme.primary,
                                backgroundColor:
                                    colorScheme.surfaceContainerLowest,
                                side: BorderSide(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.outlineVariant,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 10,
                                ),
                                onSelected: (_) {
                                  setModalState(() {
                                    temporaryStockFilter = filter;
                                  });
                                },
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 30),

                          // -----------------------------------------------------
                          // Sort options
                          // -----------------------------------------------------
                          Text(
                            'Sort Products',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            'Choose the order in which products appear.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: colorScheme.outlineVariant,
                              ),
                            ),
                            child: Column(
                              children: ProductSortOption.values.map((
                                sortOption,
                              ) {
                                final isSelected =
                                    temporarySortOption == sortOption;

                                final isLast =
                                    sortOption == ProductSortOption.values.last;

                                return Column(
                                  children: [
                                    InkWell(
                                      borderRadius: BorderRadius.circular(18),
                                      onTap: () {
                                        setModalState(() {
                                          temporarySortOption = sortOption;
                                        });
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 15,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 42,
                                              height: 42,
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? colorScheme.primary
                                                          .withValues(
                                                            alpha: 0.10,
                                                          )
                                                    : colorScheme
                                                          .surfaceContainer,
                                                borderRadius:
                                                    BorderRadius.circular(13),
                                              ),
                                              child: Icon(
                                                _sortOptionIcon(sortOption),
                                                size: 21,
                                                color: isSelected
                                                    ? colorScheme.primary
                                                    : colorScheme
                                                          .onSurfaceVariant,
                                              ),
                                            ),

                                            const SizedBox(width: 14),

                                            Expanded(
                                              child: Text(
                                                _sortOptionLabel(sortOption),
                                                style: textTheme.bodyLarge
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ),

                                            Radio<ProductSortOption>(
                                              value: sortOption,
                                              groupValue: temporarySortOption,
                                              onChanged: (value) {
                                                if (value == null) {
                                                  return;
                                                }

                                                setModalState(() {
                                                  temporarySortOption = value;
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                    if (!isLast)
                                      Divider(
                                        height: 1,
                                        indent: 72,
                                        color: colorScheme.outlineVariant,
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // -------------------------------------------------------------
                  // Bottom actions
                  // -------------------------------------------------------------
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      24,
                      16,
                      24,
                      16 + MediaQuery.paddingOf(context).bottom,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      border: Border(
                        top: BorderSide(color: colorScheme.outlineVariant),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 52,
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedStockFilter = ProductStockFilter.all;
                                  _selectedSortOption =
                                      ProductSortOption.newestFirst;
                                });

                                Navigator.of(bottomSheetContext).pop();
                              },
                              child: const Text('Reset'),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 52,
                            child: FilledButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedStockFilter = temporaryStockFilter;

                                  _selectedSortOption = temporarySortOption;
                                });

                                Navigator.of(bottomSheetContext).pop();
                              },
                              icon: const Icon(Icons.check_rounded, size: 20),
                              label: const Text('Apply Filters'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _stockFilterLabel(ProductStockFilter filter) {
    switch (filter) {
      case ProductStockFilter.all:
        return 'All Products';

      case ProductStockFilter.inStock:
        return 'In Stock';

      case ProductStockFilter.lowStock:
        return 'Low Stock';

      case ProductStockFilter.outOfStock:
        return 'Out of Stock';
    }
  }

  IconData _stockFilterIcon(ProductStockFilter filter) {
    switch (filter) {
      case ProductStockFilter.all:
        return Icons.inventory_2_outlined;

      case ProductStockFilter.inStock:
        return Icons.check_circle_outline_rounded;

      case ProductStockFilter.lowStock:
        return Icons.warning_amber_rounded;

      case ProductStockFilter.outOfStock:
        return Icons.remove_shopping_cart_outlined;
    }
  }

  String _sortOptionLabel(ProductSortOption option) {
    switch (option) {
      case ProductSortOption.newestFirst:
        return 'Newest First';

      case ProductSortOption.nameAscending:
        return 'Name: A–Z';

      case ProductSortOption.nameDescending:
        return 'Name: Z–A';

      case ProductSortOption.priceLowToHigh:
        return 'Price: Low to High';

      case ProductSortOption.priceHighToLow:
        return 'Price: High to Low';

      case ProductSortOption.stockLowToHigh:
        return 'Stock: Low to High';

      case ProductSortOption.stockHighToLow:
        return 'Stock: High to Low';
    }
  }

  IconData _sortOptionIcon(ProductSortOption option) {
    switch (option) {
      case ProductSortOption.newestFirst:
        return Icons.schedule_rounded;

      case ProductSortOption.nameAscending:
        return Icons.sort_by_alpha_rounded;

      case ProductSortOption.nameDescending:
        return Icons.sort_by_alpha_rounded;

      case ProductSortOption.priceLowToHigh:
        return Icons.trending_up_rounded;

      case ProductSortOption.priceHighToLow:
        return Icons.trending_down_rounded;

      case ProductSortOption.stockLowToHigh:
        return Icons.south_rounded;

      case ProductSortOption.stockHighToLow:
        return Icons.north_rounded;
    }
  }
}

// =============================================================================
// Inventory Header
// =============================================================================

class _InventoryHeader extends StatelessWidget {
  const _InventoryHeader({
    required this.onAddProduct,
    required this.onOpenArchivedProducts,
    required this.onOpenManageCategories,
  });

  final VoidCallback onAddProduct;
  final VoidCallback onOpenArchivedProducts;
  final VoidCallback onOpenManageCategories;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Inventory',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Manage your products and stock',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.icon(
                onPressed: onAddProduct,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add'),
              ),

              const SizedBox(width: 4),

              PopupMenuButton<String>(
                tooltip: 'More options',
                onSelected: (value) {
                  if (value == 'manage_categories') {
                    onOpenManageCategories();
                    return;
                  }

                  if (value == 'archived_products') {
                    onOpenArchivedProducts();
                  }
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem<String>(
                      value: 'manage_categories',
                      child: Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            color: theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 12),
                          const Text('Manage Categories'),
                        ],
                      ),
                    ),

                    PopupMenuItem<String>(
                      value: 'archived_products',
                      child: Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: theme.colorScheme.onSurface,
                          ),
                          const SizedBox(width: 12),
                          const Text('Archived Products'),
                        ],
                      ),
                    ),
                  ];
                },
                icon: const Icon(Icons.more_vert_rounded, size: 28),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InventorySummary extends StatelessWidget {
  const _InventorySummary({
    required this.totalProducts,
    required this.totalStockUnits,
    required this.lowStockProducts,
  });

  final int totalProducts;
  final int totalStockUnits;
  final int lowStockProducts;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InventorySummaryCard(
            icon: Icons.inventory_2_outlined,
            value: totalProducts.toString(),
            label: 'Products',
            iconColor: const Color(0xFF2563EB),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _InventorySummaryCard(
            icon: Icons.layers_outlined,
            value: totalStockUnits.toString(),
            label: 'Stock Units',
            iconColor: const Color(0xFF7C3AED),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _InventorySummaryCard(
            icon: Icons.warning_amber_rounded,
            value: lowStockProducts.toString(),
            label: 'Low Stock',
            iconColor: const Color(0xFFDC2626),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Inventory Summary Card
// =============================================================================

class _InventorySummaryCard extends StatelessWidget {
  const _InventorySummaryCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 23, color: iconColor),
          ),

          const SizedBox(height: 14),

          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Product Card
// =============================================================================

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onTap,
    required this.readInteger,
    required this.readDouble,
  });

  final Map<String, dynamic> product;

  final VoidCallback onTap;

  final int Function(dynamic value) readInteger;

  final double Function(dynamic value) readDouble;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final productName = (product['name'] ?? '').toString();

    final brand = (product['brand'] ?? '').toString().trim();

    final sku = (product['sku'] ?? '').toString().trim();

    final sellingPrice = readDouble(product['selling_price']);

    final stockQuantity = readInteger(product['stock_quantity']);

    final lowStockThreshold = readInteger(product['low_stock_threshold']);

    final categoryData = product['product_categories'];

    final categoryName = categoryData is Map
        ? (categoryData['name'] ?? 'Uncategorized').toString()
        : 'Uncategorized';

    final isOutOfStock = stockQuantity == 0;

    final isLowStock = stockQuantity > 0 && stockQuantity <= lowStockThreshold;

    final String stockStatus;

    final IconData stockIcon;

    final Color stockColor;

    if (isOutOfStock) {
      stockStatus = 'Out of stock';
      stockIcon = Icons.remove_shopping_cart_outlined;
      stockColor = colorScheme.error;
    } else if (isLowStock) {
      stockStatus = 'Low stock: $stockQuantity';
      stockIcon = Icons.warning_amber_rounded;
      stockColor = colorScheme.error;
    } else {
      stockStatus = '$stockQuantity in stock';
      stockIcon = Icons.check_circle_outline_rounded;
      stockColor = const Color(0xFF16A34A);
    }

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              // Product icon
              // Product icon
              ProductIcon(product: product),

              const SizedBox(width: 14),

              // Product information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),

                        Icon(
                          Icons.chevron_right_rounded,
                          size: 23,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      [if (brand.isNotEmpty) brand, categoryName].join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),

                    if (sku.isNotEmpty) ...[
                      const SizedBox(height: 3),

                      Text(
                        'SKU: $sku',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatPrice(sellingPrice),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: stockColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(stockIcon, size: 14, color: stockColor),

                              const SizedBox(width: 5),

                              Text(
                                stockStatus,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: stockColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
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
    );
  }

  String _formatPrice(double price) {
    final wholePrice = price.round();

    final priceText = wholePrice.toString();

    final formattedPrice = priceText.replaceAllMapped(
      RegExp(r'(\d)(?=(\d\d)+\d$)'),
      (match) {
        return '${match[1]},';
      },
    );

    return '₹$formattedPrice';
  }
}

// =============================================================================
// Empty Inventory State
// =============================================================================

class _EmptyInventoryState extends StatelessWidget {
  const _EmptyInventoryState({
    required this.onAddProduct,
    required this.onRefresh,
  });

  final VoidCallback onAddProduct;

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(28, 80, 28, 140),
        children: [
          Center(
            child: Container(
              width: 96,
              height: 96,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.inventory_2_outlined,
                size: 46,
                color: colorScheme.primary,
              ),
            ),
          ),

          const SizedBox(height: 26),

          Text(
            'Your inventory is empty',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'Add your first product to start managing stock, pricing, billing, and low-stock alerts.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          FilledButton.icon(
            onPressed: onAddProduct,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add First Product'),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// No Search Results
// =============================================================================

class _NoSearchResultsState extends StatelessWidget {
  const _NoSearchResultsState({required this.searchQuery});

  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 40, 30, 140),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 58,
            color: theme.colorScheme.onSurfaceVariant,
          ),

          const SizedBox(height: 18),

          Text(
            'No products found',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'No products match “$searchQuery”. Try another product name, brand, category, or SKU.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Error State
// =============================================================================

class _InventoryErrorState extends StatelessWidget {
  const _InventoryErrorState({required this.message, required this.onRetry});

  final String message;

  final Future<void> Function({bool showLoadingIndicator}) onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: theme.colorScheme.error,
            ),

            const SizedBox(height: 18),

            Text(
              'Unable to load inventory',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () {
                onRetry();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
