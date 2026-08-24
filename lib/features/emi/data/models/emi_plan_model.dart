class EmiPlanModel {
  const EmiPlanModel({
    required this.id,
    required this.storeId,
    required this.customerId,
    required this.invoiceId,
    required this.financedAmount,
    required this.interestType,
    required this.interestRate,
    required this.interestAmount,
    required this.processingFee,
    required this.totalPayableAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.tenureMonths,
    required this.startDate,
    required this.firstDueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // ===========================================================================
  // Basic Information
  // ===========================================================================

  final String id;
  final String storeId;
  final String customerId;
  final String invoiceId;

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
  bool get isActive => status == 'active';

  /// Whether the EMI plan is completed.
  bool get isCompleted => status == 'completed';

  /// Whether the EMI plan is cancelled.
  bool get isCancelled => status == 'cancelled';

  // ===========================================================================
  // From JSON
  // ===========================================================================

  factory EmiPlanModel.fromJson(Map<String, dynamic> json) {
    return EmiPlanModel(
      id: json['id'] as String,

      storeId: json['store_id'] as String,

      customerId: json['customer_id'] as String,

      invoiceId: json['invoice_id'] as String,

      // -----------------------------------------------------------------------
      // Financial Information
      // -----------------------------------------------------------------------

      financedAmount: (json['financed_amount'] as num).toDouble(),

      interestType: json['interest_type'] as String,

      interestRate: (json['interest_rate'] as num).toDouble(),

      interestAmount: (json['interest_amount'] as num).toDouble(),

      processingFee: (json['processing_fee'] as num).toDouble(),

      totalPayableAmount:
          (json['total_payable_amount'] as num).toDouble(),

      paidAmount: (json['paid_amount'] as num).toDouble(),

      remainingAmount:
          (json['remaining_amount'] as num).toDouble(),

      // -----------------------------------------------------------------------
      // EMI Schedule
      // -----------------------------------------------------------------------

      tenureMonths: (json['tenure_months'] as num).toInt(),

      startDate: DateTime.parse(
        json['start_date'] as String,
      ),

      firstDueDate: DateTime.parse(
        json['first_due_date'] as String,
      ),

      // -----------------------------------------------------------------------
      // Status
      // -----------------------------------------------------------------------

      status: json['status'] as String,

      // -----------------------------------------------------------------------
      // Timestamps
      // -----------------------------------------------------------------------

      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),

      updatedAt: DateTime.parse(
        json['updated_at'] as String,
      ),
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
      'invoice_id': invoiceId,

      'financed_amount': financedAmount,

      'interest_type': interestType,
      'interest_rate': interestRate,
      'interest_amount': interestAmount,
      'processing_fee': processingFee,

      'total_payable_amount': totalPayableAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,

      'tenure_months': tenureMonths,

      'start_date': startDate.toIso8601String(),
      'first_due_date': firstDueDate.toIso8601String(),

      'status': status,

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
    String? invoiceId,
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
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      customerId: customerId ?? this.customerId,
      invoiceId: invoiceId ?? this.invoiceId,

      financedAmount: financedAmount ?? this.financedAmount,

      interestType: interestType ?? this.interestType,
      interestRate: interestRate ?? this.interestRate,
      interestAmount: interestAmount ?? this.interestAmount,
      processingFee: processingFee ?? this.processingFee,

      totalPayableAmount:
          totalPayableAmount ?? this.totalPayableAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingAmount:
          remainingAmount ?? this.remainingAmount,

      tenureMonths: tenureMonths ?? this.tenureMonths,

      startDate: startDate ?? this.startDate,
      firstDueDate: firstDueDate ?? this.firstDueDate,

      status: status ?? this.status,

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}