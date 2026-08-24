class EmiInstallmentModel {
  const EmiInstallmentModel({
    required this.id,
    required this.emiPlanId,
    required this.installmentNumber,
    required this.dueDate,
    required this.scheduledAmount,
    required this.paidAmount,
    required this.remainingAmount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  // ===========================================================================
  // Basic Information
  // ===========================================================================

  final String id;
  final String emiPlanId;

  // ===========================================================================
  // Installment Information
  // ===========================================================================

  final int installmentNumber;
  final DateTime dueDate;

  final double scheduledAmount;
  final double paidAmount;
  final double remainingAmount;

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

  /// Whether this installment has been completely paid.
  bool get isPaid => remainingAmount <= 0;

  /// Whether this installment still has an outstanding amount.
  bool get hasRemainingAmount => remainingAmount > 0;

  /// Whether the installment is partially paid.
  bool get isPartiallyPaid =>
      paidAmount > 0 && remainingAmount > 0;

  /// Percentage of this installment that has been paid.
  double get paidPercentage {
    if (scheduledAmount <= 0) {
      return 0;
    }

    final percentage = paidAmount / scheduledAmount;

    if (percentage < 0) {
      return 0;
    }

    if (percentage > 1) {
      return 1;
    }

    return percentage;
  }

  /// Whether this installment is currently pending.
  bool get isPending => status == 'pending';

  /// Whether this installment is overdue.
  bool get isOverdue => status == 'overdue';

  /// Whether this installment is completed.
  bool get isCompleted => status == 'paid';

  // ===========================================================================
  // From JSON
  // ===========================================================================

  factory EmiInstallmentModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EmiInstallmentModel(
      id: json['id'] as String,

      emiPlanId: json['emi_plan_id'] as String,

      // -----------------------------------------------------------------------
      // Installment Information
      // -----------------------------------------------------------------------

      installmentNumber:
          (json['installment_number'] as num).toInt(),

      dueDate: DateTime.parse(
        json['due_date'] as String,
      ),

      scheduledAmount:
          (json['scheduled_amount'] as num).toDouble(),

      paidAmount:
          (json['paid_amount'] as num).toDouble(),

      remainingAmount:
          (json['remaining_amount'] as num).toDouble(),

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
      'emi_plan_id': emiPlanId,

      'installment_number': installmentNumber,
      'due_date': dueDate.toIso8601String(),

      'scheduled_amount': scheduledAmount,
      'paid_amount': paidAmount,
      'remaining_amount': remainingAmount,

      'status': status,

      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ===========================================================================
  // Copy With
  // ===========================================================================

  EmiInstallmentModel copyWith({
    String? id,
    String? emiPlanId,
    int? installmentNumber,
    DateTime? dueDate,
    double? scheduledAmount,
    double? paidAmount,
    double? remainingAmount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmiInstallmentModel(
      id: id ?? this.id,

      emiPlanId: emiPlanId ?? this.emiPlanId,

      installmentNumber:
          installmentNumber ?? this.installmentNumber,

      dueDate: dueDate ?? this.dueDate,

      scheduledAmount:
          scheduledAmount ?? this.scheduledAmount,

      paidAmount: paidAmount ?? this.paidAmount,

      remainingAmount:
          remainingAmount ?? this.remainingAmount,

      status: status ?? this.status,

      createdAt: createdAt ?? this.createdAt,

      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}