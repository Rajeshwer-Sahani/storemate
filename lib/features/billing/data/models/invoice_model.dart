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
    required this.totalItemQuantity,
    required this.returnedItemQuantity,
    required this.returnedAmount,
    required this.totalProfit,
    required this.paymentStatus,
    required this.invoiceStatus,
    required this.paymentMethod,
    this.emiPlanId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  // ===========================================================================
  // Basic Information
  // ===========================================================================

  final String id;
  final String storeId;

  final String customerId;
  final String customerName;
  final String? customerPhone;

  final String invoiceNumber;
  final DateTime invoiceDate;

  // ===========================================================================
  // Invoice Amounts
  // ===========================================================================

  final double subtotal;
  final double discount;
  final double tax;
  final double grandTotal;

  // ===========================================================================
  // Payment
  // ===========================================================================

  final double paidAmount;
  final double dueAmount;

  // ===========================================================================
  // Items & Returns
  // ===========================================================================

  /// Total quantity of items originally sold in this invoice.
  final int totalItemQuantity;

  /// Total quantity returned across all return transactions.
  final int returnedItemQuantity;

  /// Cumulative monetary value of all returned items.
  final double returnedAmount;

  // ===========================================================================
  // Profit
  // ===========================================================================

  final double totalProfit;

  // ===========================================================================
  // Status
  // ===========================================================================

  final String paymentStatus;
  final String invoiceStatus;
  final String paymentMethod;

  // ===========================================================================
  // EMI
  // ===========================================================================

  /// ID of the EMI plan associated with this invoice.
  ///
  /// Null when the invoice does not have an EMI plan.
  final String? emiPlanId;

  /// Whether this invoice has an associated EMI plan.
  bool get hasEmiPlan => emiPlanId != null && emiPlanId!.isNotEmpty;

  // ===========================================================================
  // Additional Information
  // ===========================================================================

  final String? notes;

  final DateTime createdAt;
  final DateTime updatedAt;

  // ===========================================================================
  // Return Helpers
  // ===========================================================================

  /// Whether this invoice has at least one returned item.
  bool get hasReturn => returnedItemQuantity > 0;

  /// Whether the complete invoice quantity has been returned.
  bool get isFullyReturned =>
      totalItemQuantity > 0 && returnedItemQuantity >= totalItemQuantity;

  /// Whether only part of the invoice quantity has been returned.
  bool get isPartiallyReturned =>
      returnedItemQuantity > 0 && returnedItemQuantity < totalItemQuantity;

  // ===========================================================================
  // Display Status
  // ===========================================================================

  String get displayStatus {
    if (isFullyReturned) {
      return 'returned';
    }

    if (isPartiallyReturned) {
      return 'partially_returned';
    }

    return paymentStatus;
  }

  // ===========================================================================
  // From JSON
  // ===========================================================================

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] as String,

      storeId: json['store_id'] as String,

      customerId: json['customer_id'] as String,

      customerName: json['customer_name'] as String,

      customerPhone: json['customer_phone'] as String?,

      invoiceNumber: json['invoice_number'] as String,

      invoiceDate: DateTime.parse(json['invoice_date'] as String),

      // -----------------------------------------------------------------------
      // Amounts
      // -----------------------------------------------------------------------
      subtotal: (json['subtotal'] as num).toDouble(),

      discount: (json['discount'] as num).toDouble(),

      tax: (json['tax'] as num).toDouble(),

      grandTotal: (json['grand_total'] as num).toDouble(),

      // -----------------------------------------------------------------------
      // Payment
      // -----------------------------------------------------------------------
      paidAmount: (json['paid_amount'] as num).toDouble(),

      dueAmount: (json['due_amount'] as num).toDouble(),

      // -----------------------------------------------------------------------
      // Items & Returns
      // -----------------------------------------------------------------------
      totalItemQuantity: (json['total_item_quantity'] as num?)?.toInt() ?? 0,

      returnedItemQuantity:
          (json['returned_item_quantity'] as num?)?.toInt() ?? 0,

      returnedAmount: (json['returned_amount'] as num?)?.toDouble() ?? 0.0,

      // -----------------------------------------------------------------------
      // Profit
      // -----------------------------------------------------------------------
      totalProfit: (json['total_profit'] as num).toDouble(),

      // -----------------------------------------------------------------------
      // Status
      // -----------------------------------------------------------------------
      paymentStatus: json['payment_status'] as String,

      invoiceStatus: json['invoice_status'] as String,

      paymentMethod: json['payment_method'] as String,

      // -----------------------------------------------------------------------
      // EMI
      // -----------------------------------------------------------------------
      emiPlanId: json['emi_plan_id'] as String?,

      // -----------------------------------------------------------------------
      // Additional Information
      // -----------------------------------------------------------------------
      notes: json['notes'] as String?,

      createdAt: DateTime.parse(json['created_at'] as String),

      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // ===========================================================================
  // To JSON
  // ===========================================================================

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

      'total_item_quantity': totalItemQuantity,
      'returned_item_quantity': returnedItemQuantity,
      'returned_amount': returnedAmount,

      'total_profit': totalProfit,

      'payment_status': paymentStatus,
      'invoice_status': invoiceStatus,
      'payment_method': paymentMethod,

      'emi_plan_id': emiPlanId,

      'notes': notes,

      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ===========================================================================
  // Copy With
  // ===========================================================================

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
    int? totalItemQuantity,
    int? returnedItemQuantity,
    double? returnedAmount,
    double? totalProfit,
    String? paymentStatus,
    String? invoiceStatus,
    String? paymentMethod,
    String? emiPlanId,
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

      totalItemQuantity: totalItemQuantity ?? this.totalItemQuantity,

      returnedItemQuantity: returnedItemQuantity ?? this.returnedItemQuantity,

      returnedAmount: returnedAmount ?? this.returnedAmount,

      totalProfit: totalProfit ?? this.totalProfit,

      paymentStatus: paymentStatus ?? this.paymentStatus,

      invoiceStatus: invoiceStatus ?? this.invoiceStatus,

      paymentMethod: paymentMethod ?? this.paymentMethod,

      emiPlanId: emiPlanId ?? this.emiPlanId,

      notes: notes ?? this.notes,

      createdAt: createdAt ?? this.createdAt,

      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
