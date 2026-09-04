import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/product_icon.dart';

import 'package:storemate/features/inventory/data/models/product_model.dart';
import 'package:storemate/features/inventory/data/services/inventory_service.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({required this.product, super.key});

  final ProductModel product;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final InventoryService _inventoryService = InventoryService();

  late final TextEditingController _productNameController;

  late final TextEditingController _brandController;

  late final TextEditingController _skuController;

  late final TextEditingController _purchasePriceController;

  late final TextEditingController _sellingPriceController;

  late final TextEditingController _stockQuantityController;

  late final TextEditingController _lowStockThresholdController;

  late final TextEditingController _descriptionController;

  List<Map<String, dynamic>> _categories = [];

  String? _selectedCategoryId;

  bool _isLoadingCategories = true;

  bool _isSaving = false;

  // ---------------------------------------------------------------------------
  // Initial setup
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _productNameController = TextEditingController(text: widget.product.name);

    _brandController = TextEditingController(text: widget.product.brand ?? '');

    _skuController = TextEditingController(text: widget.product.sku ?? '');

    _purchasePriceController = TextEditingController(
      text: _numberText(widget.product.purchasePrice),
    );

    _sellingPriceController = TextEditingController(
      text: _numberText(widget.product.sellingPrice),
    );

    _stockQuantityController = TextEditingController(
      text: widget.product.stockQuantity.toString(),
    );

    _lowStockThresholdController = TextEditingController(
      text: widget.product.lowStockThreshold.toString(),
    );

    _descriptionController = TextEditingController(
      text: widget.product.description ?? '',
    );

    _selectedCategoryId = widget.product.categoryId;

    _loadCategories();
  }

  // ---------------------------------------------------------------------------
  // Remove unnecessary .0 from prices
  // ---------------------------------------------------------------------------

  String _numberText(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  // ---------------------------------------------------------------------------
  // Dispose controllers
  // ---------------------------------------------------------------------------

  @override
  void dispose() {
    _productNameController.dispose();

    _brandController.dispose();

    _skuController.dispose();

    _purchasePriceController.dispose();

    _sellingPriceController.dispose();

    _stockQuantityController.dispose();

    _lowStockThresholdController.dispose();

    _descriptionController.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Load product categories
  // ---------------------------------------------------------------------------

  Future<void> _loadCategories() async {
    try {
      final categories = await _inventoryService.getProductCategories();

      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;

        _isLoadingCategories = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingCategories = false;
      });

      _showMessage('Unable to load product categories.', isError: true);
    }
  }

  // ---------------------------------------------------------------------------
  // Open premium category selector
  // ---------------------------------------------------------------------------

  Future<void> _showCategorySelector() async {
    FocusScope.of(context).unfocus();

    final selectedCategoryId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return _CategorySelectionSheet(
          categories: _categories,
          selectedCategoryId: _selectedCategoryId,
        );
      },
    );

    if (!mounted || selectedCategoryId == null) {
      return;
    }

    setState(() {
      _selectedCategoryId = selectedCategoryId;
    });
  }

  // ---------------------------------------------------------------------------
  // Selected category name
  // ---------------------------------------------------------------------------

  String? get _selectedCategoryName {
    if (_selectedCategoryId == null) {
      return null;
    }

    for (final category in _categories) {
      if (category['id'] == _selectedCategoryId) {
        return category['name']?.toString();
      }
    }

    return widget.product.categoryName;
  }

  // ---------------------------------------------------------------------------
  // Save updated product
  // ---------------------------------------------------------------------------

  Future<void> _updateProduct() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategoryId == null) {
      _showMessage('Please select a product category.', isError: true);

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _inventoryService.updateProduct(
        productId: widget.product.id,
        name: _productNameController.text,
        categoryId: _selectedCategoryId,
        brand: _brandController.text,
        sku: _skuController.text,
        purchasePrice: double.parse(_purchasePriceController.text.trim()),
        sellingPrice: double.parse(_sellingPriceController.text.trim()),
        stockQuantity: int.parse(_stockQuantityController.text.trim()),
        lowStockThreshold: int.parse(_lowStockThresholdController.text.trim()),
        description: _descriptionController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to update the product. '
        'Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
          content: Text(message),
          backgroundColor: isError ? colorScheme.error : null,
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),

      body: SafeArea(
        top: false,
        child: Form(
          key: _formKey,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 130),
            children: [
              _SectionHeading(
                title: 'Product Information',
                subtitle: 'Update the product information and stock details.',
              ),

              const SizedBox(height: 22),

              TextFormField(
                controller: _productNameController,
                enabled: !_isSaving,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Product name',
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter the product name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 18),

              // Premium category selector
              InkWell(
                onTap: _isLoadingCategories || _isSaving
                    ? null
                    : _showCategorySelector,
                borderRadius: BorderRadius.circular(18),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                    suffixIcon: Icon(Icons.keyboard_arrow_down_rounded),
                  ),
                  child: _isLoadingCategories
                      ? const Text('Loading categories...')
                      : Text(
                          _selectedCategoryName ?? 'Select a category',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _selectedCategoryName == null
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurface,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _brandController,
                enabled: !_isSaving,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Brand (optional)',
                  prefixIcon: Icon(Icons.sell_outlined),
                ),
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _skuController,
                enabled: !_isSaving,
                textCapitalization: TextCapitalization.characters,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'SKU / Product code (optional)',
                  prefixIcon: Icon(Icons.qr_code_rounded),
                ),
              ),

              const SizedBox(height: 30),

              _SectionHeading(
                title: 'Pricing',
                subtitle: 'Update the buying and selling prices.',
              ),

              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _purchasePriceController,
                      enabled: !_isSaving,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Purchase price',
                        prefixText: '₹ ',
                      ),
                      validator: _validatePrice,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: TextFormField(
                      controller: _sellingPriceController,
                      enabled: !_isSaving,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Selling price',
                        prefixText: '₹ ',
                      ),
                      validator: _validatePrice,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              _SectionHeading(
                title: 'Stock Details',
                subtitle: 'Update the available quantity and low-stock alert.',
              ),

              const SizedBox(height: 18),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockQuantityController,
                      enabled: !_isSaving,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Stock quantity',
                        prefixIcon: Icon(Icons.inventory_outlined),
                      ),
                      validator: _validateWholeNumber,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: TextFormField(
                      controller: _lowStockThresholdController,
                      enabled: !_isSaving,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Low-stock alert',
                        prefixIcon: Icon(Icons.warning_amber_rounded),
                      ),
                      validator: _validateWholeNumber,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              _SectionHeading(
                title: 'Additional Details',
                subtitle: 'Update optional information about the product.',
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _descriptionController,
                enabled: !_isSaving,
                minLines: 4,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),

      // Fixed update button
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          ),
          child: FilledButton.icon(
            onPressed: _isSaving ? null : _updateProduct,
            icon: _isSaving
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_isSaving ? 'Updating Product...' : 'Update Product'),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  String? _validatePrice(String? value) {
    final price = double.tryParse(value?.trim() ?? '');

    if (price == null) {
      return 'Enter a valid price';
    }

    if (price < 0) {
      return 'Cannot be negative';
    }

    return null;
  }

  String? _validateWholeNumber(String? value) {
    final number = int.tryParse(value?.trim() ?? '');

    if (number == null) {
      return 'Enter a valid number';
    }

    if (number < 0) {
      return 'Cannot be negative';
    }

    return null;
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
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Premium category bottom sheet
// -----------------------------------------------------------------------------

class _CategorySelectionSheet extends StatelessWidget {
  const _CategorySelectionSheet({
    required this.categories,
    required this.selectedCategoryId,
  });

  final List<Map<String, dynamic>> categories;

  final String? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.72,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),

            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(100),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 14, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Category',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Text(
                          'Choose a category for this product.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: colorScheme.outlineVariant),

            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: categories.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 12);
                },
                itemBuilder: (context, index) {
                  final category = categories[index];

                  final id = category['id'].toString();

                  final name =
                      category['name']?.toString() ?? 'Unnamed Category';

                  final isSelected = id == selectedCategoryId;

                  return InkWell(
                    onTap: () {
                      Navigator.of(context).pop(id);
                    },
                    borderRadius: BorderRadius.circular(18),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.12)
                            : colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CategoryIcon(
                            categoryName: name,
                            size: 48,
                            iconSize: 24,
                            borderRadius: 14,
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Text(
                              name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          Icon(
                            isSelected
                                ? Icons.check_circle_rounded
                                : Icons.chevron_right_rounded,
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ],
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
