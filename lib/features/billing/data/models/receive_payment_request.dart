class ReceivePaymentRequest {
  const ReceivePaymentRequest({
    required this.invoiceId,
    required this.receiveAmount,
    required this.paymentMethod,
    this.notes,
  });

  final String invoiceId;

  final double receiveAmount;

  final String paymentMethod;

  final String? notes;

  Map<String, dynamic> toRpc() {
    return {
      'p_invoice_id': invoiceId,
      'p_receive_amount': receiveAmount,
      'p_payment_method': paymentMethod,
      'p_notes': notes,
    };
  }

  ReceivePaymentRequest copyWith({
    String? invoiceId,
    double? receiveAmount,
    String? paymentMethod,
    String? notes,
  }) {
    return ReceivePaymentRequest(
      invoiceId: invoiceId ?? this.invoiceId,
      receiveAmount: receiveAmount ?? this.receiveAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
    );
  }
}