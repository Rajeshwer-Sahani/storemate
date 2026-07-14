class ProductModel {
  const ProductModel({
    required this.id,
    required this.storeId,
    this.categoryId,
    this.categoryName,
    required this.name,
    this.brand,
    this.sku,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.stockQuantity,
    required this.lowStockThreshold,
    this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String storeId;

  final String? categoryId;
  final String? categoryName;

  final String name;
  final String? brand;
  final String? sku;

  final double purchasePrice;
  final double sellingPrice;

  final int stockQuantity;
  final int lowStockThreshold;

  final String? description;

  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;

  // ---------------------------------------------------------------------------
  // Convert Supabase JSON data into ProductModel
  // ---------------------------------------------------------------------------

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final categoryData = json['product_categories'];

    String? categoryName;

    if (categoryData is Map) {
      categoryName = categoryData['name']?.toString();
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',

      storeId: json['store_id']?.toString() ?? '',

      categoryId: json['category_id']?.toString(),

      categoryName: categoryName ?? json['category_name']?.toString(),

      name: json['name']?.toString() ?? 'Unnamed Product',

      brand: json['brand']?.toString(),

      sku: json['sku']?.toString(),

      purchasePrice: (json['purchase_price'] as num?)?.toDouble() ?? 0.0,

      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,

      stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,

      lowStockThreshold: (json['low_stock_threshold'] as num?)?.toInt() ?? 0,

      description: json['description']?.toString(),

      isActive: json['is_active'] as bool? ?? true,

      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),

      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // Convert ProductModel into JSON
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'category_id': categoryId,
      'name': name,
      'brand': brand,
      'sku': sku,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'stock_quantity': stockQuantity,
      'low_stock_threshold': lowStockThreshold,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
