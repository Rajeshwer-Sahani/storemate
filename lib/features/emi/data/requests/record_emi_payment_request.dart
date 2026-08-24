class RecordEmiPaymentRequest {
  final String emiPlanId;
  final double amount;
  final String paymentMethod;
  final DateTime paymentDate;
  final String? reference;
  final String? notes;

  const RecordEmiPaymentRequest({
    required this.emiPlanId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentDate,
    this.reference,
    this.notes,
  });

  Map<String, dynamic> toRpcParams() {
    return {
      'p_emi_plan_id': emiPlanId,
      'p_amount': amount,
      'p_payment_method': paymentMethod,
      'p_payment_date': paymentDate.toIso8601String().split('T').first,
      'p_reference': reference,
      'p_notes': notes,
    };
  }
}