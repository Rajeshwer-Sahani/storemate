class EmiPaymentModel {
  const EmiPaymentModel({
    required this.id,
    required this.emiPlanId,
    required this.customerId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.reference,
    this.notes,
    required this.createdBy,
    required this.createdAt,
  });

  // ===========================================================================
  // Basic Information
  // ===========================================================================

  final String id;
  final String emiPlanId;
  final String customerId;

  // ===========================================================================
  // Payment Information
  // ===========================================================================

  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;

  // ===========================================================================
  // Additional Information
  // ===========================================================================

  final String? reference;
  final String? notes;

  // ===========================================================================
  // Audit Information
  // ===========================================================================

  final String createdBy;
  final DateTime createdAt;

  // ===========================================================================
  // Computed Helpers
  // ===========================================================================

  /// Whether this payment has a reference value.
  bool get hasReference =>
      reference != null && reference!.trim().isNotEmpty;

  /// Whether this payment contains notes.
  bool get hasNotes =>
      notes != null && notes!.trim().isNotEmpty;

  // ===========================================================================
  // From JSON
  // ===========================================================================

  factory EmiPaymentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EmiPaymentModel(
      id: json['id'] as String,

      emiPlanId: json['emi_plan_id'] as String,

      customerId: json['customer_id'] as String,

      // -----------------------------------------------------------------------
      // Payment Information
      // -----------------------------------------------------------------------

      amount: (json['amount'] as num).toDouble(),

      paymentMethod: json['payment_method'] as String,

      paymentDate: DateTime.parse(
        json['payment_date'] as String,
      ),

      // -----------------------------------------------------------------------
      // Additional Information
      // -----------------------------------------------------------------------

      reference: json['reference'] as String?,

      notes: json['notes'] as String?,

      // -----------------------------------------------------------------------
      // Audit Information
      // -----------------------------------------------------------------------

      createdBy: json['created_by'] as String,

      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
    );
  }

  // ===========================================================================
  // To JSON
  // ===========================================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'emi_plan_id': emiPlanId,
      'customer_id': customerId,

      'amount': amount,
      'payment_method': paymentMethod,
      'payment_date': paymentDate.toIso8601String(),

      'reference': reference,
      'notes': notes,

      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  // ===========================================================================
  // Copy With
  // ===========================================================================

  EmiPaymentModel copyWith({
    String? id,
    String? emiPlanId,
    String? customerId,
    double? amount,
    String? paymentMethod,
    DateTime? paymentDate,
    String? reference,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return EmiPaymentModel(
      id: id ?? this.id,

      emiPlanId: emiPlanId ?? this.emiPlanId,

      customerId: customerId ?? this.customerId,

      amount: amount ?? this.amount,

      paymentMethod: paymentMethod ?? this.paymentMethod,

      paymentDate: paymentDate ?? this.paymentDate,

      reference: reference ?? this.reference,

      notes: notes ?? this.notes,

      createdBy: createdBy ?? this.createdBy,

      createdAt: createdAt ?? this.createdAt,
    );
  }
}