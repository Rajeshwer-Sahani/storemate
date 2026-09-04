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

  Future<void> _showAddCategorySheet() async {
    final categoryName = await _showCategoryFormSheet(
      title: 'Add Category',
      subtitle: 'Create a new category to organize your products.',
      fieldLabel: 'Category name',
      fieldHint: 'For example, Mobile',
      buttonLabel: 'Add Category',
      buttonIcon: Icons.add_rounded,
    );

    if (categoryName == null || !mounted) {
      return;
    }

    try {
      await _inventoryService.createProductCategory(name: categoryName);

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

                const SizedBox(height: 6),

                Text(
                  '$productCount '
                  '${productCount == 1 ? 'product' : 'products'}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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
