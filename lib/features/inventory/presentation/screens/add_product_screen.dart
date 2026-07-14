import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:storemate/features/inventory/data/services/inventory_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() {
    return _AddProductScreenState();
  }
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final InventoryService _inventoryService = InventoryService();

  final TextEditingController _productNameController = TextEditingController();

  final TextEditingController _brandController = TextEditingController();

  final TextEditingController _skuController = TextEditingController();

  final TextEditingController _purchasePriceController =
      TextEditingController();

  final TextEditingController _sellingPriceController = TextEditingController();

  final TextEditingController _stockQuantityController = TextEditingController(
    text: '0',
  );

  final TextEditingController _lowStockThresholdController =
      TextEditingController(text: '5');

  final TextEditingController _descriptionController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];

  String? _selectedCategoryId;

  String? get _selectedCategoryName {
    if (_selectedCategoryId == null) {
      return null;
    }

    for (final category in _categories) {
      if (category['id'] == _selectedCategoryId) {
        return category['name']?.toString();
      }
    }

    return null;
  }

  bool _isLoadingCategories = true;

  bool _isSavingProduct = false;

  // ---------------------------------------------------------------------------
  // Screen lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _loadCategories();
  }

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
  // Load categories from Supabase
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

      _showMessage(
        'Unable to load product categories. Please try again.',
        isError: true,
      );
    }
  }

  Future<void> _showCategorySelector() async {
    if (_isLoadingCategories || _isSavingProduct) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    final selectedCategoryId = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return _CategorySelectorSheet(
          categories: _categories,
          selectedCategoryId: _selectedCategoryId,
          onAddCategory: () async {
            Navigator.of(bottomSheetContext).pop();

            await Future<void>.delayed(const Duration(milliseconds: 200));

            if (!mounted) {
              return;
            }

            await _showAddCategoryDialog();
          },
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
  // Open dialog to create a category
  // ---------------------------------------------------------------------------

  Future<void> _showAddCategoryDialog() async {
    final categoryName = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return const _AddCategoryDialog();
      },
    );

    if (!mounted || categoryName == null || categoryName.trim().isEmpty) {
      return;
    }

    try {
      final newCategory = await _inventoryService.createProductCategory(
        name: categoryName.trim(),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _categories = [..._categories, newCategory]
          ..sort((firstCategory, secondCategory) {
            final firstName = firstCategory['name'] as String;

            final secondName = secondCategory['name'] as String;

            return firstName.toLowerCase().compareTo(secondName.toLowerCase());
          });

        _selectedCategoryId = newCategory['id'] as String;
      });

      _showMessage('${categoryName.trim()} category created successfully.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to create the category. Please try again.',
        isError: true,
      );
    }
  }
  // ---------------------------------------------------------------------------
  // Validate and save product
  // ---------------------------------------------------------------------------

  Future<void> _saveProduct() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      return;
    }

    setState(() {
      _isSavingProduct = true;
    });

    try {
      await _inventoryService.addProduct(
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

      _showMessage('Product added successfully.');

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Unable to add the product. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingProduct = false;
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
  // Validators
  // ---------------------------------------------------------------------------

  String? _validateRequiredText(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the $fieldName.';
    }

    return null;
  }

  String? _validatePrice(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the $fieldName.';
    }

    final price = double.tryParse(value.trim());

    if (price == null) {
      return 'Enter a valid amount.';
    }

    if (price < 0) {
      return '$fieldName cannot be negative.';
    }

    return null;
  }

  String? _validateQuantity(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter the $fieldName.';
    }

    final quantity = int.tryParse(value.trim());

    if (quantity == null) {
      return 'Enter a valid whole number.';
    }

    if (quantity < 0) {
      return '$fieldName cannot be negative.';
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Product'), centerTitle: false),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Form(
            key: _formKey,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              children: [
                Text(
                  'Product Information',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Add the basic information and stock details for this product.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 28),

                // Product name
                TextFormField(
                  controller: _productNameController,
                  enabled: !_isSavingProduct,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Product name',
                    hintText: 'Example: Samsung Galaxy S25',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                  ),
                  validator: (value) {
                    return _validateRequiredText(value, 'product name');
                  },
                ),

                const SizedBox(height: 18),

                // Category
                // Premium category selector
                _CategorySelectorField(
                  selectedCategoryName: _selectedCategoryName,
                  isLoading: _isLoadingCategories,
                  isEnabled: !_isSavingProduct,
                  onTap: _showCategorySelector,
                ),

                const SizedBox(height: 12),

                // Brand
                TextFormField(
                  controller: _brandController,
                  enabled: !_isSavingProduct,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Brand (optional)',
                    hintText: 'Example: Samsung',
                    prefixIcon: Icon(Icons.sell_outlined),
                  ),
                ),

                const SizedBox(height: 18),

                // SKU
                TextFormField(
                  controller: _skuController,
                  enabled: !_isSavingProduct,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'SKU / Product code (optional)',
                    hintText: 'Example: SAM-S25-128',
                    prefixIcon: Icon(Icons.qr_code_rounded),
                  ),
                ),

                const SizedBox(height: 28),

                _SectionTitle(
                  title: 'Pricing',
                  subtitle: 'Enter the buying and selling prices.',
                ),

                const SizedBox(height: 18),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _purchasePriceController,
                        enabled: !_isSavingProduct,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Purchase price',
                          prefixText: '₹ ',
                        ),
                        validator: (value) {
                          return _validatePrice(value, 'purchase price');
                        },
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: TextFormField(
                        controller: _sellingPriceController,
                        enabled: !_isSavingProduct,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d{0,2}'),
                          ),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Selling price',
                          prefixText: '₹ ',
                        ),
                        validator: (value) {
                          return _validatePrice(value, 'selling price');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _SectionTitle(
                  title: 'Stock Details',
                  subtitle: 'Set the opening quantity and low-stock alert.',
                ),

                const SizedBox(height: 18),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockQuantityController,
                        enabled: !_isSavingProduct,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Opening stock',
                          prefixIcon: Icon(Icons.inventory_outlined),
                        ),
                        validator: (value) {
                          return _validateQuantity(value, 'opening stock');
                        },
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: TextFormField(
                        controller: _lowStockThresholdController,
                        enabled: !_isSavingProduct,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Low-stock alert',
                          prefixIcon: Icon(Icons.warning_amber_rounded),
                        ),
                        validator: (value) {
                          return _validateQuantity(value, 'low-stock alert');
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                _SectionTitle(
                  title: 'Additional Details',
                  subtitle: 'Add optional information about the product.',
                ),

                const SizedBox(height: 18),

                TextFormField(
                  controller: _descriptionController,
                  enabled: !_isSavingProduct,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.multiline,
                  minLines: 4,
                  maxLines: 6,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    hintText:
                        'Add product specifications, colour, storage, or other notes.',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Save button
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: Border(
              top: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
          ),
          child: SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: _isSavingProduct ? null : _saveProduct,
              icon: _isSavingProduct
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_business_rounded),
              label: Text(
                _isSavingProduct ? 'Saving Product...' : 'Save Product',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Reusable section heading
// -----------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

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
            fontWeight: FontWeight.w700,
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
// Category selector field
// -----------------------------------------------------------------------------

class _CategorySelectorField extends StatelessWidget {
  const _CategorySelectorField({
    required this.selectedCategoryName,
    required this.isLoading,
    required this.isEnabled,
    required this.onTap,
  });

  final String? selectedCategoryName;

  final bool isLoading;

  final bool isEnabled;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    final hasSelectedCategory = selectedCategoryName != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled && !isLoading ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                Icons.category_outlined,
                color: colorScheme.onSurfaceVariant,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      isLoading
                          ? 'Loading categories...'
                          : selectedCategoryName ?? 'Select a category',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: hasSelectedCategory
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                        fontWeight: hasSelectedCategory
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}


// -----------------------------------------------------------------------------
// Bottom sheet to select a category
// -----------------------------------------------------------------------------
class _CategorySelectorSheet extends StatelessWidget {
  const _CategorySelectorSheet({
    required this.categories,
    required this.selectedCategoryId,
    required this.onAddCategory,
  });

  final List<Map<String, dynamic>> categories;

  final String? selectedCategoryId;

  final VoidCallback onAddCategory;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.72,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),

          // Drag indicator
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(100),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 12, 14),
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

                      const SizedBox(height: 4),

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
                  tooltip: 'Close',
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: colorScheme.outlineVariant),

          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 36, 24, 28),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      Icons.category_outlined,
                      size: 34,
                      color: colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    'No categories yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    'Create your first category to organize products.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                shrinkWrap: true,
                itemCount: categories.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 8);
                },
                itemBuilder: (context, index) {
                  final category = categories[index];

                  final categoryId = category['id'] as String;

                  final categoryName = category['name'] as String;

                  final isSelected = categoryId == selectedCategoryId;

                  return Material(
                    color: isSelected
                        ? colorScheme.primary.withValues(alpha: 0.09)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop(categoryId);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(13),
                              ),
                              child: Icon(
                                Icons.category_outlined,
                                color: colorScheme.primary,
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Text(
                                categoryName,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: colorScheme.primary,
                              )
                            else
                              Icon(
                                Icons.chevron_right_rounded,
                                color: colorScheme.onSurfaceVariant,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: onAddCategory,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add New Category'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Dialog to add a new category
// -----------------------------------------------------------------------------

class _AddCategoryDialog extends StatefulWidget {
  const _AddCategoryDialog();

  @override
  State<_AddCategoryDialog> createState() {
    return _AddCategoryDialogState();
  }
}

class _AddCategoryDialogState extends State<_AddCategoryDialog> {
  final TextEditingController _categoryNameController = TextEditingController();

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  void _submitCategory() {
    final categoryName = _categoryNameController.text.trim();

    if (categoryName.isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.of(context).pop(categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Category'),
      content: TextField(
        controller: _categoryNameController,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(
          labelText: 'Category name',
          hintText: 'Example: Mobile Phones',
          prefixIcon: Icon(Icons.category_outlined),
        ),
        onSubmitted: (_) {
          _submitCategory();
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitCategory,
          child: const Text('Add Category'),
        ),
      ],
    );
  }
}
