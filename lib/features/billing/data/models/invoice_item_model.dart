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

  final int quantity;

  final double discount;
  final double tax;

  final double lineSubtotal;
  final double lineTotal;
  final double lineProfit;

  final String? serialNumber;
  final String? imeiNumber;

  final DateTime createdAt;

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

      quantity: json['quantity'] as int,

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