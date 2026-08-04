class PaymentHistoryModel {
  final String id;

  final String invoiceId;

  final String? customerId;

  final double amount;

  final String paymentMethod;

  final String? notes;

  final DateTime createdAt;

  const PaymentHistoryModel({
    required this.id,
    required this.invoiceId,
    this.customerId,
    required this.amount,
    required this.paymentMethod,
    this.notes,
    required this.createdAt,
  });

  factory PaymentHistoryModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PaymentHistoryModel(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      customerId: json['customer_id'] as String?,
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(
        json['created_at'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'customer_id': customerId,
      'amount': amount,
      'payment_method': paymentMethod,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  PaymentHistoryModel copyWith({
    String? id,
    String? invoiceId,
    String? customerId,
    double? amount,
    String? paymentMethod,
    String? notes,
    DateTime? createdAt,
  }) {
    return PaymentHistoryModel(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}