class ProductModel {
  const ProductModel({
    required this.id,
    required this.storeId,
    this.categoryId,
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
  // Convert Supabase JSON data into a ProductModel object
  // ---------------------------------------------------------------------------

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      categoryId: json['category_id'] as String?,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      sku: json['sku'] as String?,
      purchasePrice: (json['purchase_price'] as num).toDouble(),
      sellingPrice: (json['selling_price'] as num).toDouble(),
      stockQuantity: json['stock_quantity'] as int,
      lowStockThreshold: json['low_stock_threshold'] as int,
      description: json['description'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // ---------------------------------------------------------------------------
  // Convert ProductModel into JSON for Supabase
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