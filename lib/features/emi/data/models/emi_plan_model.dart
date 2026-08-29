class EmiPlanModel {
  const EmiPlanModel({
    required this.id,
    required this.storeId,

    // Identity
    required this.customerId,
    this.customerName,
    this.customerPhone,
    required this.invoiceId,
    this.invoiceNumber,

    // Financial
    required this.financedAmount,
    required this.interestType,
    required this.interestRate,
    required this.interestAmount,
    required this.processingFee,
    required this.totalPayableAmount,
    required this.paidAmount,
    required this.remainingAmount,

    // EMI Schedule
    required this.tenureMonths,
    required this.startDate,
    required this.firstDueDate,

    // Status
    required this.status,

    // Timestamps
    required this.createdAt,
    required this.updatedAt,
  });

  // ===========================================================================
  // Basic Information
  // ===========================================================================

  final String id;
  final String storeId;

  // ===========================================================================
  // Identity
  // ===========================================================================
  //
  // IDs are used for database relationships.
  //
  // Human-readable fields are used by the UI so the user can immediately
  // identify whose EMI plan this is and which invoice it belongs to.
  //

  /// Customer primary key.
  final String customerId;

  /// Customer's display name.
  ///
  /// Nullable because the base `emi_plans` query may not include
  /// customer information.
  final String? customerName;

  /// Customer's phone number.
  ///
  /// Nullable because the base `emi_plans` query may not include
  /// customer information.
  final String? customerPhone;

  /// Invoice primary key.
  final String invoiceId;

  /// Human-readable invoice number.
  ///
  /// Nullable because the base `emi_plans` query may not include
  /// invoice information.
  final String? invoiceNumber;

  // ===========================================================================
  // Financial Information
  // ===========================================================================

  final double financedAmount;

  final String interestType;
  final double interestRate;
  final double interestAmount;
  final double processingFee;

  final double totalPayableAmount;
  final double paidAmount;
  final double remainingAmount;

  // ===========================================================================
  // EMI Schedule
  // ===========================================================================

  final int tenureMonths;
  final DateTime startDate;
  final DateTime firstDueDate;

  // ===========================================================================
  // Status
  // ===========================================================================

  final String status;

  // ===========================================================================
  // Timestamps
  // ===========================================================================

  final DateTime createdAt;
  final DateTime updatedAt;

  // ===========================================================================
  // Computed Helpers
  // ===========================================================================

  /// Whether the EMI plan has been completely paid.
  bool get isPaid => remainingAmount <= 0;

  /// Whether the EMI plan still has an outstanding amount.
  bool get hasRemainingAmount => remainingAmount > 0;

  /// Percentage of the total payable amount that has been paid.
  double get paidPercentage {
    if (totalPayableAmount <= 0) {
      return 0;
    }

    final percentage = paidAmount / totalPayableAmount;

    if (percentage < 0) {
      return 0;
    }

    if (percentage > 1) {
      return 1;
    }

    return percentage;
  }

  /// Whether the EMI plan is currently active.
  bool get isActive => status.toLowerCase() == 'active';

  /// Whether the EMI plan is completed.
  bool get isCompleted => status.toLowerCase() == 'completed';

  /// Whether the EMI plan is cancelled.
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  // ===========================================================================
  // Identity Helpers
  // ===========================================================================

  /// Whether customer information is available for display.
  bool get hasCustomerIdentity =>
      customerName != null && customerName!.trim().isNotEmpty;

  /// Whether invoice information is available for display.
  bool get hasInvoiceIdentity =>
      invoiceNumber != null && invoiceNumber!.trim().isNotEmpty;

  /// Display-safe customer name.
  String get displayCustomerName {
    if (customerName != null && customerName!.trim().isNotEmpty) {
      return customerName!.trim();
    }

    return 'Unknown Customer';
  }

  /// Display-safe customer phone number.
  String? get displayCustomerPhone {
    if (customerPhone == null || customerPhone!.trim().isEmpty) {
      return null;
    }

    return customerPhone!.trim();
  }

  /// Display-safe invoice number.
  String get displayInvoiceNumber {
    if (invoiceNumber != null && invoiceNumber!.trim().isNotEmpty) {
      return invoiceNumber!.trim();
    }

    return 'Invoice unavailable';
  }

  // ===========================================================================
  // From JSON
  // ===========================================================================

  factory EmiPlanModel.fromJson(Map<String, dynamic> json) {
    // -------------------------------------------------------------------------
    // Optional joined customer data
    // -------------------------------------------------------------------------
    //
    // This supports Supabase responses such as:
    //
    // {
    //   ...emi_plan_fields,
    //   "customers": {
    //      "full_name": "...",
    //      "phone_number": "..."
    //   }
    // }
    //

    final customerJson = json['customers'] is Map
        ? Map<String, dynamic>.from(json['customers'] as Map)
        : null;

    // -------------------------------------------------------------------------
    // Optional joined invoice data
    // -------------------------------------------------------------------------

    final invoiceJson = json['invoices'] is Map
        ? Map<String, dynamic>.from(json['invoices'] as Map)
        : null;

    return EmiPlanModel(
      // -----------------------------------------------------------------------
      // Basic Information
      // -----------------------------------------------------------------------
      id: json['id'] as String,

      storeId: json['store_id'] as String,

      // -----------------------------------------------------------------------
      // Identity
      // -----------------------------------------------------------------------
      customerId: json['customer_id'] as String,

      customerName:
          json['customer_name'] as String? ??
          customerJson?['full_name'] as String?,

      customerPhone:
          json['customer_phone'] as String? ??
          customerJson?['phone_number'] as String?,

      invoiceId: json['invoice_id'] as String,

      invoiceNumber:
          json['invoice_number'] as String? ??
          invoiceJson?['invoice_number'] as String?,

      // -----------------------------------------------------------------------
      // Financial Information
      // -----------------------------------------------------------------------
      financedAmount: (json['financed_amount'] as num).toDouble(),

      interestType: json['interest_type'] as String,

      interestRate: (json['interest_rate'] as num).toDouble(),

      interestAmount: (json['interest_amount'] as num).toDouble(),

      processingFee: (json['processing_fee'] as num).toDouble(),

      totalPayableAmount: (json['total_payable_amount'] as num).toDouble(),

      paidAmount: (json['paid_amount'] as num).toDouble(),

      remainingAmount: (json['remaining_amount'] as num).toDouble(),

      // -----------------------------------------------------------------------
      // EMI Schedule
      // -----------------------------------------------------------------------
      tenureMonths: (json['tenure_months'] as num).toInt(),

      startDate: DateTime.parse(json['start_date'] as String),

      firstDueDate: DateTime.parse(json['first_due_date'] as String),

      // -----------------------------------------------------------------------
      // Status
      // -----------------------------------------------------------------------
      status: json['status'] as String,

      // -----------------------------------------------------------------------
      // Timestamps
      // -----------------------------------------------------------------------
      createdAt: DateTime.parse(json['created_at'] as String),

      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  // ===========================================================================
  // To JSON
  // ===========================================================================

  Map<String, dynamic> toJson() {
    return {
      // -----------------------------------------------------------------------
      // Basic Information
      // -----------------------------------------------------------------------
      'id': id,
      'store_id': storeId,

      // -----------------------------------------------------------------------
      // Identity
      // -----------------------------------------------------------------------
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_phone': customerPhone,

      'invoice_id': invoiceId,
      'invoice_number': invoiceNumber,

      // -----------------------------------------------------------------------
      // Financial Information
      // -----------------------------------------------------------------------
      'financed_amount': financedAmount,

      'interest_type': interestType,
      'interest_rate': interestRate,
      'interest_amount': interestAmount,
      'processing_fee': processingFee,

      'total_payable_amount': totalPayableAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,

      // -----------------------------------------------------------------------
      // EMI Schedule
      // -----------------------------------------------------------------------
      'tenure_months': tenureMonths,

      'start_date': startDate.toIso8601String(),
      'first_due_date': firstDueDate.toIso8601String(),

      // -----------------------------------------------------------------------
      // Status
      // -----------------------------------------------------------------------
      'status': status,

      // -----------------------------------------------------------------------
      // Timestamps
      // -----------------------------------------------------------------------
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ===========================================================================
  // Copy With
  // ===========================================================================

  EmiPlanModel copyWith({
    String? id,
    String? storeId,

    String? customerId,
    String? customerName,
    String? customerPhone,

    String? invoiceId,
    String? invoiceNumber,

    double? financedAmount,
    String? interestType,
    double? interestRate,
    double? interestAmount,
    double? processingFee,
    double? totalPayableAmount,
    double? paidAmount,
    double? remainingAmount,

    int? tenureMonths,
    DateTime? startDate,
    DateTime? firstDueDate,

    String? status,

    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmiPlanModel(
      // -----------------------------------------------------------------------
      // Basic Information
      // -----------------------------------------------------------------------
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,

      // -----------------------------------------------------------------------
      // Identity
      // -----------------------------------------------------------------------
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,

      invoiceId: invoiceId ?? this.invoiceId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,

      // -----------------------------------------------------------------------
      // Financial Information
      // -----------------------------------------------------------------------
      financedAmount: financedAmount ?? this.financedAmount,

      interestType: interestType ?? this.interestType,

      interestRate: interestRate ?? this.interestRate,

      interestAmount: interestAmount ?? this.interestAmount,

      processingFee: processingFee ?? this.processingFee,

      totalPayableAmount: totalPayableAmount ?? this.totalPayableAmount,

      paidAmount: paidAmount ?? this.paidAmount,

      remainingAmount: remainingAmount ?? this.remainingAmount,

      // -----------------------------------------------------------------------
      // EMI Schedule
      // -----------------------------------------------------------------------
      tenureMonths: tenureMonths ?? this.tenureMonths,

      startDate: startDate ?? this.startDate,

      firstDueDate: firstDueDate ?? this.firstDueDate,

      // -----------------------------------------------------------------------
      // Status
      // -----------------------------------------------------------------------
      status: status ?? this.status,

      // -----------------------------------------------------------------------
      // Timestamps
      // -----------------------------------------------------------------------
      createdAt: createdAt ?? this.createdAt,

      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
