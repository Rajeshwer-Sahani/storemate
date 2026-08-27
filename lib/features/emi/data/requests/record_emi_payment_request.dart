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

  String _toDatabasePaymentMethod(String value) {
    switch (value.trim().toLowerCase()) {
      case 'cash':
        return 'cash';

      case 'upi':
        return 'upi';

      case 'card':
        return 'card';

      case 'bank transfer':
      case 'bank_transfer':
        return 'bank_transfer';

      case 'other':
        return 'other';

      default:
        throw ArgumentError('Unsupported EMI payment method: $value');
    }
  }

  Map<String, dynamic> toRpcParams() {
    return {
      'p_emi_plan_id': emiPlanId,
      'p_amount': amount,
      'p_payment_method': _toDatabasePaymentMethod(paymentMethod),
      'p_payment_date': paymentDate.toIso8601String().split('T').first,
      'p_reference': reference,
      'p_notes': notes,
    };
  }
}
