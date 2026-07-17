class StockAdjustmentModel {
  const StockAdjustmentModel({
    required this.id,
    required this.productId,
    required this.adjustmentType,
    required this.quantityChange,
    required this.previousStock,
    required this.updatedStock,
    required this.createdAt,
    this.note,
  });

  final String id;
  final String productId;

  final String adjustmentType;

  final int quantityChange;
  final int previousStock;
  final int updatedStock;

  final String? note;

  final DateTime createdAt;

  factory StockAdjustmentModel.fromJson(Map<String, dynamic> json) {
    return StockAdjustmentModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      adjustmentType: json['adjustment_type'] as String,
      quantityChange: (json['quantity_change'] as num).toInt(),
      previousStock: (json['previous_stock'] as num).toInt(),
      updatedStock: (json['updated_stock'] as num).toInt(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'adjustment_type': adjustmentType,
      'quantity_change': quantityChange,
      'previous_stock': previousStock,
      'updated_stock': updatedStock,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}