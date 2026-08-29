class EmiPaymentAllocationModel {
  const EmiPaymentAllocationModel({
    required this.id,
    required this.paymentId,
    required this.installmentId,
    required this.allocatedAmount,
    required this.createdAt,
  });

  final String id;
  final String paymentId;
  final String installmentId;
  final double allocatedAmount;
  final DateTime createdAt;

  factory EmiPaymentAllocationModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return EmiPaymentAllocationModel(
      id: json['id'] as String,
      paymentId: json['payment_id'] as String,
      installmentId: json['installment_id'] as String,
      allocatedAmount:
          (json['allocated_amount'] as num).toDouble(),
      createdAt:
          DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_id': paymentId,
      'installment_id': installmentId,
      'allocated_amount': allocatedAmount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}