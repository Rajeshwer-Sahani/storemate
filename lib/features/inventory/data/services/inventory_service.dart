import 'package:supabase_flutter/supabase_flutter.dart';

class InventoryService {
  InventoryService({SupabaseClient? supabaseClient})
    : _supabase = supabaseClient ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  // ---------------------------------------------------------------------------
  // Get the current logged-in user's store ID
  // ---------------------------------------------------------------------------

  Future<String> getCurrentStoreId() async {
    final currentUser = _supabase.auth.currentUser;

    if (currentUser == null) {
      throw const AuthException(
        'Your session has expired. Please log in again.',
      );
    }

    final storeData = await _supabase
        .from('stores')
        .select('id')
        .eq('owner_id', currentUser.id)
        .maybeSingle();

    if (storeData == null) {
      throw Exception(
        'No store was found for this account. Please complete the store setup.',
      );
    }

    return storeData['id'] as String;
  }

  // ---------------------------------------------------------------------------
  // Get all product categories for the current store
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getProductCategories() async {
    final storeId = await getCurrentStoreId();

    final response = await _supabase
        .from('product_categories')
        .select('id, name')
        .eq('store_id', storeId)
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  // ---------------------------------------------------------------------------
  // Get product categories with active product counts for the current store
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>>
  getProductCategoriesWithProductCount() async {
    final storeId = await getCurrentStoreId();

    final response = await _supabase
        .from('product_categories')
        .select('''
        id,
        name,
        created_at,
        products (
          id,
          is_active
        )
      ''')
        .eq('store_id', storeId)
        .order('name');

    final categories = List<Map<String, dynamic>>.from(response);

    return categories.map((category) {
      final products = List<Map<String, dynamic>>.from(
        category['products'] ?? [],
      );

      final activeProductCount = products.where((product) {
        return product['is_active'] == true;
      }).length;

      return <String, dynamic>{
        'id': category['id'],
        'name': category['name'],
        'created_at': category['created_at'],
        'product_count': activeProductCount,
      };
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // Create a new product category
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> createProductCategory({
    required String name,
  }) async {
    final storeId = await getCurrentStoreId();
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }

    final response = await _supabase
        .from('product_categories')
        .insert({'store_id': storeId, 'name': trimmedName})
        .select('id, name')
        .single();

    return response;
  }

  // ---------------------------------------------------------------------------
  // Rename a product category belonging to the current store
  // ---------------------------------------------------------------------------

  Future<void> renameProductCategory({
    required String categoryId,
    required String name,
  }) async {
    final storeId = await getCurrentStoreId();
    final trimmedName = name.trim();

    if (categoryId.trim().isEmpty) {
      throw ArgumentError('A valid category ID is required.');
    }

    if (trimmedName.isEmpty) {
      throw ArgumentError('Category name cannot be empty.');
    }

    final existingCategory = await _supabase
        .from('product_categories')
        .select('id')
        .eq('id', categoryId)
        .eq('store_id', storeId)
        .maybeSingle();

    if (existingCategory == null) {
      throw Exception(
        'This category was not found or does not belong to your store.',
      );
    }

    await _supabase
        .from('product_categories')
        .update({'name': trimmedName})
        .eq('id', categoryId)
        .eq('store_id', storeId);
  }

  // ---------------------------------------------------------------------------
  // Safely delete an unused product category from the current store
  // ---------------------------------------------------------------------------

  Future<void> deleteProductCategory({required String categoryId}) async {
    final storeId = await getCurrentStoreId();

    if (categoryId.trim().isEmpty) {
      throw ArgumentError('A valid category ID is required.');
    }

    final existingCategory = await _supabase
        .from('product_categories')
        .select('id, name')
        .eq('id', categoryId)
        .eq('store_id', storeId)
        .maybeSingle();

    if (existingCategory == null) {
      throw Exception(
        'This category was not found or does not belong to your store.',
      );
    }

    final linkedProduct = await _supabase
        .from('products')
        .select('id')
        .eq('store_id', storeId)
        .eq('category_id', categoryId)
        .limit(1)
        .maybeSingle();

    if (linkedProduct != null) {
      throw Exception(
        'This category cannot be deleted because products are assigned to it.',
      );
    }

    await _supabase
        .from('product_categories')
        .delete()
        .eq('id', categoryId)
        .eq('store_id', storeId);
  }

  // ---------------------------------------------------------------------------
  // Add a new product
  // ---------------------------------------------------------------------------

  Future<void> addProduct({
    required String name,
    String? categoryId,
    String? brand,
    String? sku,
    String? barcode,
    required double purchasePrice,
    required double sellingPrice,
    required int stockQuantity,
    required int lowStockThreshold,
    String? description,
  }) async {
    final storeId = await getCurrentStoreId();

    await _supabase.from('products').insert({
      'store_id': storeId,
      'category_id': categoryId,
      'name': name.trim(),
      'brand': _emptyStringToNull(brand),
      'sku': _emptyStringToNull(sku),
      'barcode': _emptyStringToNull(barcode),
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'low_stock_threshold': lowStockThreshold,
      'description': _emptyStringToNull(description),
      'is_active': true,
    });
  }

  Future<void> addProducts(List<Map<String, dynamic>> products) async {
    if (products.isEmpty) {
      throw ArgumentError('At least one product is required.');
    }

    final storeId = await getCurrentStoreId();

    await _supabase
        .from('products')
        .insert(
          products.map((product) {
            return {
              'store_id': storeId,
              'category_id': product['category_id'],
              'name': (product['name'] as String).trim(),
              'brand': _emptyStringToNull(product['brand'] as String?),
              'sku': _emptyStringToNull(product['sku'] as String?),
              'barcode': _emptyStringToNull(product['barcode'] as String?),
              'purchase_price': product['purchase_price'],
              'selling_price': product['selling_price'],
              'stock_quantity': product['stock_quantity'],
              'low_stock_threshold': product['low_stock_threshold'],
              'description': _emptyStringToNull(
                product['description'] as String?,
              ),
              'is_active': true,
            };
          }).toList(),
        );
  }

  // ---------------------------------------------------------------------------
  // Update an existing product belonging to the current store
  // ---------------------------------------------------------------------------

  Future<void> updateProduct({
    required String productId,
    required String name,
    String? categoryId,
    String? brand,
    String? sku,
    String? barcode,
    required double purchasePrice,
    required double sellingPrice,
    required int stockQuantity,
    required int lowStockThreshold,
    String? description,
  }) async {
    final storeId = await getCurrentStoreId();

    final trimmedName = name.trim();

    if (productId.trim().isEmpty) {
      throw ArgumentError('A valid product ID is required.');
    }

    if (trimmedName.isEmpty) {
      throw ArgumentError('Product name cannot be empty.');
    }

    if (purchasePrice < 0) {
      throw ArgumentError('Purchase price cannot be negative.');
    }

    if (sellingPrice < 0) {
      throw ArgumentError('Selling price cannot be negative.');
    }

    if (stockQuantity < 0) {
      throw ArgumentError('Stock quantity cannot be negative.');
    }

    if (lowStockThreshold < 0) {
      throw ArgumentError('Low-stock threshold cannot be negative.');
    }

    await _supabase
        .from('products')
        .update({
          'category_id': categoryId,
          'name': trimmedName,
          'brand': _emptyStringToNull(brand),
          'sku': _emptyStringToNull(sku),
          'barcode': _emptyStringToNull(barcode),
          'purchase_price': purchasePrice,
          'selling_price': sellingPrice,
          'stock_quantity': stockQuantity,
          'low_stock_threshold': lowStockThreshold,
          'description': _emptyStringToNull(description),
        })
        .eq('id', productId)
        .eq('store_id', storeId)
        .eq('is_active', true);
  }

  // ---------------------------------------------------------------------------
  // Enable device tracking for a product
  // ---------------------------------------------------------------------------

  Future<void> enableDeviceTracking({required String productId}) async {
    final storeId = await getCurrentStoreId();

    final trimmedProductId = productId.trim();

    if (trimmedProductId.isEmpty) {
      throw ArgumentError('A valid product ID is required.');
    }

    // Verify that the product belongs to the current store and is active.
    final product = await _supabase
        .from('products')
        .select('id, tracking_mode')
        .eq('id', trimmedProductId)
        .eq('store_id', storeId)
        .eq('is_active', true)
        .maybeSingle();

    if (product == null) {
      throw Exception(
        'This product was not found or does not belong to your store.',
      );
    }

    final currentTrackingMode =
        product['tracking_mode']?.toString() ?? 'quantity';

    // Device tracking is already enabled.
    if (currentTrackingMode == 'device') {
      return;
    }

    // Only allow the safe transition for now.
    if (currentTrackingMode != 'quantity') {
      throw Exception('This product has an unsupported tracking mode.');
    }

    await _supabase
        .from('products')
        .update({'tracking_mode': 'device'})
        .eq('id', trimmedProductId)
        .eq('store_id', storeId)
        .eq('is_active', true);
  }

  // ---------------------------------------------------------------------------
  // Archive a product belonging to the logged-in owner's store
  // ---------------------------------------------------------------------------

  Future<void> archiveProduct({required String productId}) async {
    final storeId = await getCurrentStoreId();

    final trimmedProductId = productId.trim();

    if (trimmedProductId.isEmpty) {
      throw ArgumentError('Product ID cannot be empty.');
    }

    await _supabase
        .from('products')
        .update({'is_active': false})
        .eq('id', trimmedProductId)
        .eq('store_id', storeId)
        .eq('is_active', true);
  }

  // ---------------------------------------------------------------------------
  // Fetch archived products belonging to the logged-in owner's store
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getArchivedProducts() async {
    final storeId = await getCurrentStoreId();

    final response = await _supabase
        .from('products')
        .select('''
        id,
        store_id,
        category_id,
        name,
        brand,
        sku,
        barcode,
        tracking_mode,
        purchase_price,
        selling_price,
        stock_quantity,
        low_stock_threshold,
        description,
        is_active,
        created_at,
        updated_at,
        product_categories (
          id,
          name
        )
      ''')
        .eq('store_id', storeId)
        .eq('is_active', false)
        .order('updated_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ---------------------------------------------------------------------------
  // Restore an archived product belonging to the logged-in owner's store
  // ---------------------------------------------------------------------------

  Future<void> restoreProduct({required String productId}) async {
    final storeId = await getCurrentStoreId();

    if (productId.trim().isEmpty) {
      throw ArgumentError('Product ID cannot be empty.');
    }

    await _supabase
        .from('products')
        .update({
          'is_active': true,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', productId)
        .eq('store_id', storeId)
        .eq('is_active', false);
  }

  // ---------------------------------------------------------------------------
  // Securely adjust product stock using the database RPC
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>> adjustProductStock({
    required String productId,
    required String adjustmentType,
    required int quantity,
    String? note,
  }) async {
    final response = await _supabase.rpc(
      'adjust_product_stock',
      params: {
        'p_product_id': productId,
        'p_adjustment_type': adjustmentType,
        'p_quantity': quantity,
        'p_note': note?.trim().isEmpty ?? true ? null : note!.trim(),
      },
    );

    return Map<String, dynamic>.from(response as Map);
  }

  // ---------------------------------------------------------------------------
  // Fetch stock adjustment history for a product
  // ---------------------------------------------------------------------------

  // ---------------------------------------------------------------------------
  // Fetch stock adjustment history for a product
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getStockAdjustmentHistory({
    required String productId,
  }) async {
    if (productId.trim().isEmpty) {
      throw ArgumentError('Product ID cannot be empty.');
    }

    final storeId = await getCurrentStoreId();

    final response = await _supabase
        .from('stock_adjustments')
        .select('''
        id,
        product_id,
        adjustment_type,
        quantity_change,
        previous_stock,
        updated_stock,
        note,
        created_at
      ''')
        .eq('store_id', storeId)
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // ---------------------------------------------------------------------------
  // Convert empty optional text into null before saving it to Supabase
  // ---------------------------------------------------------------------------

  String? _emptyStringToNull(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return null;
    }

    return trimmedValue;
  }

  // ---------------------------------------------------------------------------
  // Fetch all products belonging to the logged-in owner's store
  // ---------------------------------------------------------------------------

  Future<List<Map<String, dynamic>>> getProducts() async {
    final storeId = await getCurrentStoreId();

    final response = await _supabase
        .from('products')
        .select('''
        id,
        store_id,
        category_id,
        name,
        brand,
        sku,
        barcode,
        tracking_mode,
        purchase_price,
        selling_price,
        stock_quantity,
        low_stock_threshold,
        description,
        is_active,
        created_at,
        product_categories (
          id,
          name
        )
        ''')
        .eq('store_id', storeId)
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
