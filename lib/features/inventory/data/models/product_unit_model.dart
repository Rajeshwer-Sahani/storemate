class ProductUnitModel {
  const ProductUnitModel({
    required this.id,
    required this.storeId,
    required this.productId,
    this.imei1,
    this.imei2,
    this.serialNumber,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String storeId;
  final String productId;

  final String? imei1;
  final String? imei2;
  final String? serialNumber;

  final String status;

  final DateTime createdAt;
  final DateTime updatedAt;

  // ---------------------------------------------------------------------------
  // Status helpers
  // ---------------------------------------------------------------------------

  bool get isInStock => status == ProductUnitStatus.inStock;

  bool get isReserved => status == ProductUnitStatus.reserved;

  bool get isSold => status == ProductUnitStatus.sold;

  bool get isReturned => status == ProductUnitStatus.returned;

  bool get isDamaged => status == ProductUnitStatus.damaged;

  bool get isInRepair => status == ProductUnitStatus.repair;

  // ---------------------------------------------------------------------------
  // Display helpers
  // ---------------------------------------------------------------------------

  String get statusLabel {
    switch (status) {
      case ProductUnitStatus.inStock:
        return 'In stock';

      case ProductUnitStatus.reserved:
        return 'Reserved';

      case ProductUnitStatus.sold:
        return 'Sold';

      case ProductUnitStatus.returned:
        return 'Returned';

      case ProductUnitStatus.damaged:
        return 'Damaged';

      case ProductUnitStatus.repair:
        return 'In repair';

      default:
        return 'Unknown';
    }
  }

  factory ProductUnitModel.fromJson(Map<String, dynamic> json) {
    return ProductUnitModel(
      id: json['id']?.toString() ?? '',
      storeId: json['store_id']?.toString() ?? '',
      productId: json['product_id']?.toString() ?? '',
      imei1: json['imei_1']?.toString(),
      imei2: json['imei_2']?.toString(),
      serialNumber: json['serial_number']?.toString(),
      status: json['status']?.toString() ?? ProductUnitStatus.inStock,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'product_id': productId,
      'imei_1': imei1,
      'imei_2': imei2,
      'serial_number': serialNumber,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

// -----------------------------------------------------------------------------
// Product unit status constants
// -----------------------------------------------------------------------------

abstract final class ProductUnitStatus {
  static const String inStock = 'in_stock';
  static const String reserved = 'reserved';
  static const String sold = 'sold';
  static const String returned = 'returned';
  static const String damaged = 'damaged';
  static const String repair = 'repair';

  static const List<String> values = [
    inStock,
    reserved,
    sold,
    returned,
    damaged,
    repair,
  ];
}