class InvoiceModel {
  const InvoiceModel({
    required this.id,
    required this.storeId,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.subtotal,
    required this.discount,
    required this.tax,
    required this.grandTotal,
    required this.paidAmount,
    required this.dueAmount,
    required this.totalProfit,
    required this.paymentStatus,
    required this.invoiceStatus,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String storeId;
  final String customerId;
  final String customerName;
  final String? customerPhone;

  final String invoiceNumber;
  final DateTime invoiceDate;

  final double subtotal;
  final double discount;
  final double tax;
  final double grandTotal;

  final double paidAmount;
  final double dueAmount;
  final double totalProfit;

  final String paymentStatus;
  final String invoiceStatus;
  final String paymentMethod;

  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String?,
      invoiceNumber: json['invoice_number'] as String,
      invoiceDate: DateTime.parse(json['invoice_date'] as String),

      subtotal: (json['subtotal'] as num).toDouble(),
      discount: (json['discount'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      grandTotal: (json['grand_total'] as num).toDouble(),

      paidAmount: (json['paid_amount'] as num).toDouble(),
      dueAmount: (json['due_amount'] as num).toDouble(),
      totalProfit: (json['total_profit'] as num).toDouble(),

      paymentStatus: json['payment_status'] as String,
      invoiceStatus: json['invoice_status'] as String,
      paymentMethod: json['payment_method'] as String,

      notes: json['notes'] as String?,

      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'invoice_number': invoiceNumber,
      'invoice_date': invoiceDate.toIso8601String(),
      'subtotal': subtotal,
      'discount': discount,
      'tax': tax,
      'grand_total': grandTotal,
      'paid_amount': paidAmount,
      'due_amount': dueAmount,
      'total_profit': totalProfit,
      'payment_status': paymentStatus,
      'invoice_status': invoiceStatus,
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  InvoiceModel copyWith({
    String? id,
    String? storeId,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? invoiceNumber,
    DateTime? invoiceDate,
    double? subtotal,
    double? discount,
    double? tax,
    double? grandTotal,
    double? paidAmount,
    double? dueAmount,
    double? totalProfit,
    String? paymentStatus,
    String? invoiceStatus,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tax: tax ?? this.tax,
      grandTotal: grandTotal ?? this.grandTotal,
      paidAmount: paidAmount ?? this.paidAmount,
      dueAmount: dueAmount ?? this.dueAmount,
      totalProfit: totalProfit ?? this.totalProfit,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      invoiceStatus: invoiceStatus ?? this.invoiceStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}