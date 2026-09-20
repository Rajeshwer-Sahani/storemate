import 'package:flutter/material.dart';
import 'package:storemate/core/widgets/product_icon.dart';
import 'package:storemate/features/inventory/data/services/inventory_service.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final InventoryService _inventoryService = InventoryService();

  List<Map<String, dynamic>> _categories = [];

  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  // ---------------------------------------------------------------------------
  // Load categories
  // ---------------------------------------------------------------------------

  Future<void> _loadCategories({bool showLoader = true}) async {
    if (showLoader && mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final categories = await _inventoryService
          .getProductCategoriesWithProductCount();

      if (!mounted) {
        return;
      }

      setState(() {
        _categories = categories;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _readErrorMessage(
          error,
          fallbackMessage:
              'Unable to load product categories. Please try again.',
        ),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Refresh categories
  // ---------------------------------------------------------------------------

  Future<void> _refreshCategories() async {
    if (_isRefreshing) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    await _loadCategories(showLoader: false);
  }

  // ---------------------------------------------------------------------------
  // Open add-category bottom sheet
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Open add-category bottom sheet
  // ---------------------------------------------------------------------------

  Future<void> _showAddCategorySheet() async {
    final result = await _showAddCategoryFormSheet();

    if (result == null || !mounted) {
      return;
    }

    final categoryName = result['name']?.toString() ?? '';
    final requiresDeviceTracking = result['requiresDeviceTracking'] == true;

    try {
      await _inventoryService.createProductCategory(
        name: categoryName,
        requiresDeviceTracking: requiresDeviceTracking,
      );

      if (!mounted) {
        return;
      }

      await _loadCategories(showLoader: false);

      if (!mounted) {
        return;
      }

      _showMessage('Category added successfully.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _readErrorMessage(
          error,
          fallbackMessage: 'Unable to add the category. Please try again.',
        ),
        isError: true,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Add-category form with product tracking selection
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?> _showAddCategoryFormSheet() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final theme = Theme.of(bottomSheetContext);
        final colorScheme = theme.colorScheme;

        bool isSaving = false;
        bool requiresDeviceTracking = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.88,
                ),
                padding: EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Align(
                          child: Container(
                            width: 44,
                            height: 5,
                            decoration: BoxDecoration(
                              color: colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(100),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Header
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(
                                  alpha: 0.10,
                                ),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(
                                Icons.category_outlined,
                                color: colorScheme.primary,
                                size: 27,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Add Category',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Create a category and define how its '
                                    'products are tracked.',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Category name
                        TextFormField(
                          controller: controller,
                          autofocus: true,
                          textCapitalization: TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          maxLength: 50,
                          decoration: const InputDecoration(
                            labelText: 'Category name',
                            hintText: 'For example, Mobile Phones',
                            prefixIcon: Icon(Icons.category_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a category name.';
                            }

                            if (value.trim().length < 2) {
                              return 'Category name must contain at least 2 characters.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 8),

                        // Tracking section title
                        Text(
                          'How should products in this category be tracked?',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'This determines whether products use normal '
                          'quantity stock or individual device identifiers.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Quantity option
                        _buildTrackingOptionCard(
                          context: context,
                          title: 'Quantity',
                          description:
                              'Track stock by quantity.\n\n'
                              'Chargers, speakers, accessories, etc.',
                          icon: Icons.inventory_2_outlined,
                          selected: !requiresDeviceTracking,
                          onTap: () {
                            setModalState(() {
                              requiresDeviceTracking = false;
                            });
                          },
                        ),

                        const SizedBox(height: 12),

                        // Individual device option
                        _buildTrackingOptionCard(
                          context: context,
                          title: 'Individual Devices',
                          description:
                              'Every physical item has an IMEI or serial number.\n\n'
                              'Phones, laptops, tablets, etc.',
                          icon: Icons.smartphone_outlined,
                          selected: requiresDeviceTracking,
                          onTap: () {
                            setModalState(() {
                              requiresDeviceTracking = true;
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        // Add button
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: FilledButton.icon(
                            onPressed: isSaving
                                ? null
                                : () {
                                    if (formKey.currentState?.validate() !=
                                        true) {
                                      return;
                                    }

                                    setModalState(() {
                                      isSaving = true;
                                    });

                                    Navigator.of(context).pop({
                                      'name': controller.text.trim(),
                                      'requiresDeviceTracking':
                                          requiresDeviceTracking,
                                    });
                                  },
                            icon: isSaving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : const Icon(Icons.add_rounded, size: 21),
                            label: Text(
                              isSaving ? 'Adding...' : 'Add Category',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    controller.dispose();

    return result;
  }

  // ---------------------------------------------------------------------------
  // Tracking option card
  // ---------------------------------------------------------------------------

  Widget _buildTrackingOptionCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final borderColor = selected
        ? colorScheme.primary
        : colorScheme.outlineVariant;

    final backgroundColor = selected
        ? colorScheme.primary.withValues(alpha: 0.07)
        : colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary.withValues(alpha: 0.12)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selected
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                              width: 2,
                            ),
                          ),
                          child: selected
                              ? Center(
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
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

  // ---------------------------------------------------------------------------
  // Open rename-category bottom sheet
  // ---------------------------------------------------------------------------

  Future<void> _showRenameCategorySheet(Map<String, dynamic> category) async {
    final categoryId = category['id']?.toString() ?? '';
    final currentName = category['name']?.toString() ?? '';

    final updatedName = await _showCategoryFormSheet(
      title: 'Rename Category',
      subtitle: 'Update the name used to organize your products.',
      fieldLabel: 'Category name',
      fieldHint: 'Enter category name',
      buttonLabel: 'Save Changes',
      buttonIcon: Icons.check_rounded,
      initialValue: currentName,
    );

    if (updatedName == null || !mounted) {
      return;
    }

    if (updatedName.trim().toLowerCase() == currentName.trim().toLowerCase()) {
      return;
    }

    try {
      await _inventoryService.renameProductCategory(
        categoryId: categoryId,
        name: updatedName,
      );

      if (!mounted) {
        return;
      }

      await _loadCategories(showLoader: false);

      if (!mounted) {
        return;
      }

      _showMessage('Category renamed successfully.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _readErrorMessage(
          error,
          fallbackMessage: 'Unable to rename the category. Please try again.',
        ),
        isError: true,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Show delete confirmation
  // ---------------------------------------------------------------------------

  Future<void> _showDeleteConfirmation(Map<String, dynamic> category) async {
    final categoryId = category['id']?.toString() ?? '';
    final categoryName = category['name']?.toString() ?? '';
    final productCount = _readInteger(category['product_count']);

    if (productCount > 0) {
      _showMessage(
        'This category cannot be deleted because products are assigned to it.',
        isError: true,
      );
      return;
    }

    final shouldDelete = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final theme = Theme.of(bottomSheetContext);
        final colorScheme = theme.colorScheme;

        return Container(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            24 + MediaQuery.paddingOf(bottomSheetContext).bottom,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 28),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: colorScheme.error.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: colorScheme.error,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Delete Category?',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to permanently delete '
                '$categoryName? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(bottomSheetContext).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(bottomSheetContext).pop(true);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 20,
                        ),
                        label: const Text('Delete'),
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

    if (shouldDelete != true || !mounted) {
      return;
    }

    await _deleteCategory(categoryId: categoryId);
  }

  // ---------------------------------------------------------------------------
  // Delete category
  // ---------------------------------------------------------------------------

  Future<void> _deleteCategory({required String categoryId}) async {
    try {
      await _inventoryService.deleteProductCategory(categoryId: categoryId);

      if (!mounted) {
        return;
      }

      await _loadCategories(showLoader: false);

      if (!mounted) {
        return;
      }

      _showMessage('Category deleted successfully.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        _readErrorMessage(
          error,
          fallbackMessage: 'Unable to delete the category. Please try again.',
        ),
        isError: true,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Reusable add/rename category form
  // ---------------------------------------------------------------------------

  Future<String?> _showCategoryFormSheet({
    required String title,
    required String subtitle,
    required String fieldLabel,
    required String fieldHint,
    required String buttonLabel,
    required IconData buttonIcon,
    String initialValue = '',
  }) async {
    final controller = TextEditingController(text: initialValue);

    final formKey = GlobalKey<FormState>();

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final theme = Theme.of(bottomSheetContext);
        final colorScheme = theme.colorScheme;

        bool isSaving = false;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Container(
                padding: EdgeInsets.fromLTRB(
                  24,
                  12,
                  24,
                  24 + MediaQuery.paddingOf(context).bottom,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(32),
                  ),
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.10,
                              ),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              Icons.category_outlined,
                              color: colorScheme.primary,
                              size: 27,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  subtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      TextFormField(
                        controller: controller,
                        autofocus: true,
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        maxLength: 50,
                        decoration: InputDecoration(
                          labelText: fieldLabel,
                          hintText: fieldHint,
                          prefixIcon: const Icon(Icons.category_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a category name.';
                          }

                          if (value.trim().length < 2) {
                            return 'Category name must contain at least 2 characters.';
                          }

                          return null;
                        },
                        onFieldSubmitted: (_) {
                          if (isSaving) {
                            return;
                          }

                          if (formKey.currentState?.validate() != true) {
                            return;
                          }

                          setModalState(() {
                            isSaving = true;
                          });

                          Navigator.of(context).pop(controller.text.trim());
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: FilledButton.icon(
                          onPressed: isSaving
                              ? null
                              : () {
                                  if (formKey.currentState?.validate() !=
                                      true) {
                                    return;
                                  }

                                  setModalState(() {
                                    isSaving = true;
                                  });

                                  Navigator.of(
                                    context,
                                  ).pop(controller.text.trim());
                                },
                          icon: Icon(buttonIcon, size: 21),
                          label: Text(buttonLabel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    return result;
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
          margin: const EdgeInsets.all(16),
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
  // Helpers
  // ---------------------------------------------------------------------------

  int _readInteger(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _readErrorMessage(Object error, {required String fallbackMessage}) {
    final errorMessage = error.toString();

    if (errorMessage.startsWith('Exception: ')) {
      return errorMessage.replaceFirst('Exception: ', '');
    }

    if (errorMessage.startsWith('Invalid argument(s): ')) {
      return errorMessage.replaceFirst('Invalid argument(s): ', '');
    }

    return fallbackMessage;
  }

  // ---------------------------------------------------------------------------
  // UI
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        centerTitle: false,
      ),
      floatingActionButton: _categories.isEmpty || _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddCategorySheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Category'),
            ),
      body: SafeArea(top: false, child: _buildBody(colorScheme)),
    );
  }

  Widget _buildBody(ColorScheme colorScheme) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categories.isEmpty) {
      return _buildEmptyState(colorScheme);
    }

    return RefreshIndicator(
      onRefresh: _refreshCategories,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
        children: [
          Text(
            'Product Categories',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '${_categories.length} '
            '${_categories.length == 1 ? 'category' : 'categories'}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ..._categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildCategoryCard(category, colorScheme),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Category card
  // ---------------------------------------------------------------------------

  Widget _buildCategoryCard(
    Map<String, dynamic> category,
    ColorScheme colorScheme,
  ) {
    final categoryName = category['name']?.toString() ?? 'Unnamed Category';

    final productCount = _readInteger(category['product_count']);

    final requiresDeviceTracking = category['requires_device_tracking'] == true;

    final iconData = ProductIconResolver.resolveFromText(
      category: categoryName,
    );

    final theme = Theme.of(context);

    final iconBackgroundColor = theme.brightness == Brightness.light
        ? iconData.backgroundColor
        : Color.alphaBlend(
            iconData.color.withValues(alpha: 0.14),
            colorScheme.surfaceContainerHighest,
          );

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CategoryIcon(
            categoryName: categoryName,
            size: 58,
            iconSize: 28,
            borderRadius: 18,
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '$productCount '
                  '${productCount == 1 ? 'product' : 'products'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 9),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: requiresDeviceTracking
                        ? colorScheme.primary.withValues(alpha: 0.09)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        requiresDeviceTracking
                            ? Icons.smartphone_outlined
                            : Icons.inventory_2_outlined,
                        size: 15,
                        color: requiresDeviceTracking
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        requiresDeviceTracking
                            ? 'Individual Devices'
                            : 'Quantity',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: requiresDeviceTracking
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            tooltip: 'Category options',
            onSelected: (value) {
              if (value == 'rename') {
                _showRenameCategorySheet(category);
              }

              if (value == 'delete') {
                _showDeleteConfirmation(category);
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<String>(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 12),
                      Text('Rename Category'),
                    ],
                  ),
                ),

                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: colorScheme.error,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Delete Category',
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ];
            },
            icon: Icon(
              Icons.more_vert_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  
  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 116,
              height: 116,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(34),
              ),
              child: Icon(
                Icons.category_outlined,
                color: colorScheme.primary,
                size: 52,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No product categories',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              'Create categories to keep your products '
              'organized and easier to manage.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: _showAddCategorySheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add First Category'),
            ),
          ],
        ),
      ),
    );
  }
}
