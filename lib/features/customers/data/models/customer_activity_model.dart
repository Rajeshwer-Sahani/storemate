enum CustomerActivityType {
  invoice,
  invoicePayment,
  emiPayment,
}

class CustomerActivityModel {
  const CustomerActivityModel({
    required this.type,
    required this.title,
    required this.description,
    required this.amount,
    required this.dateTime,
    this.paymentMethod,
    this.invoiceId,
    this.invoiceNumber,
  });

  final CustomerActivityType type;

  final String title;
  final String description;

  final double? amount;
  final DateTime dateTime;

  final String? paymentMethod;

  final String? invoiceId;
  final String? invoiceNumber;
}