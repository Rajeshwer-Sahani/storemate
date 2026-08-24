class RecordEmiPaymentResponse {
  final String paymentId;
  final String emiPlanId;
  final String customerId;
  final double paymentAmount;
  final double totalPaid;
  final double remainingAmount;
  final String planStatus;
  final double allocatedAmount;
  final int allocationsCount;

  const RecordEmiPaymentResponse({
    required this.paymentId,
    required this.emiPlanId,
    required this.customerId,
    required this.paymentAmount,
    required this.totalPaid,
    required this.remainingAmount,
    required this.planStatus,
    required this.allocatedAmount,
    required this.allocationsCount,
  });

  factory RecordEmiPaymentResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return RecordEmiPaymentResponse(
      paymentId: json['payment_id'] as String,
      emiPlanId: json['emi_plan_id'] as String,
      customerId: json['customer_id'] as String,
      paymentAmount: _toDouble(json['payment_amount']),
      totalPaid: _toDouble(json['total_paid']),
      remainingAmount: _toDouble(json['remaining_amount']),
      planStatus: json['plan_status'] as String,
      allocatedAmount: _toDouble(json['allocated_amount']),
      allocationsCount: (json['allocations_count'] as num).toInt(),
    );
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;

    if (value is num) {
      return value.toDouble();
    }

    return double.parse(value.toString());
  }
}