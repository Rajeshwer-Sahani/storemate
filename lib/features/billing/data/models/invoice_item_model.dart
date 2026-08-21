class InvoiceItemModel {
  const InvoiceItemModel({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.productName,
    this.productSku,
    this.productCategory,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.quantity,
    required this.returnedQuantity,
    required this.discount,
    required this.tax,
    required this.lineSubtotal,
    required this.lineTotal,
    required this.lineProfit,
    this.serialNumber,
    this.imeiNumber,
    required this.createdAt,
  });

  final String id;
  final String invoiceId;
  final String productId;

  final String productName;
  final String? productSku;
  final String? productCategory;

  final double purchasePrice;
  final double sellingPrice;

  /// Original quantity sold on the invoice.
  final int quantity;

  /// Total quantity returned for this invoice item.
  final int returnedQuantity;

  final double discount;
  final double tax;

  final double lineSubtotal;
  final double lineTotal;
  final double lineProfit;

  final String? serialNumber;
  final String? imeiNumber;

  final DateTime createdAt;

  // ===========================================================================
  // Return Calculations
  // ===========================================================================

  /// Quantity that is still with the customer.
  int get remainingQuantity => quantity - returnedQuantity;

  /// Original value of all units sold.
  double get originalAmount => quantity * sellingPrice;

  /// Value of the units that have been returned.
  double get returnedAmount => returnedQuantity * sellingPrice;

  /// Value of the units that remain after the return.
  double get netAmount => remainingQuantity * sellingPrice;

  /// Whether this item has any return.
  bool get hasReturn => returnedQuantity > 0;

  /// Whether the complete quantity of this item has been returned.
  bool get isFullyReturned =>
      quantity > 0 && returnedQuantity >= quantity;

  /// Whether only part of this item's quantity has been returned.
  bool get isPartiallyReturned =>
      returnedQuantity > 0 && returnedQuantity < quantity;

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      productId: json['product_id'] as String,

      productName: json['product_name'] as String,
      productSku: json['product_sku'] as String?,
      productCategory: json['product_category'] as String?,

      purchasePrice: (json['purchase_price'] as num).toDouble(),
      sellingPrice: (json['selling_price'] as num).toDouble(),

      quantity: (json['quantity'] as num).toInt(),

      returnedQuantity:
          (json['returned_quantity'] as num?)?.toInt() ?? 0,

      discount: (json['discount'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),

      lineSubtotal: (json['line_subtotal'] as num).toDouble(),
      lineTotal: (json['line_total'] as num).toDouble(),
      lineProfit: (json['line_profit'] as num).toDouble(),

      serialNumber: json['serial_number'] as String?,
      imeiNumber: json['imei_number'] as String?,

      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'product_id': productId,
      'product_name': productName,
      'product_sku': productSku,
      'product_category': productCategory,
      'purchase_price': purchasePrice,
      'selling_price': sellingPrice,
      'quantity': quantity,
      'returned_quantity': returnedQuantity,
      'discount': discount,
      'tax': tax,
      'line_subtotal': lineSubtotal,
      'line_total': lineTotal,
      'line_profit': lineProfit,
      'serial_number': serialNumber,
      'imei_number': imeiNumber,
      'created_at': createdAt.toIso8601String(),
    };
  }

  InvoiceItemModel copyWith({
    String? id,
    String? invoiceId,
    String? productId,
    String? productName,
    String? productSku,
    String? productCategory,
    double? purchasePrice,
    double? sellingPrice,
    int? quantity,
    int? returnedQuantity,
    double? discount,
    double? tax,
    double? lineSubtotal,
    double? lineTotal,
    double? lineProfit,
    String? serialNumber,
    String? imeiNumber,
    DateTime? createdAt,
  }) {
    return InvoiceItemModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      productCategory: productCategory ?? this.productCategory,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      quantity: quantity ?? this.quantity,
      returnedQuantity: returnedQuantity ?? this.returnedQuantity,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      lineSubtotal: lineSubtotal ?? this.lineSubtotal,
      lineTotal: lineTotal ?? this.lineTotal,
      lineProfit: lineProfit ?? this.lineProfit,
      serialNumber: serialNumber ?? this.serialNumber,
      imeiNumber: imeiNumber ?? this.imeiNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}