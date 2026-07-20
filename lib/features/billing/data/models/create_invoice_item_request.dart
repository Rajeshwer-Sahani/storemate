class CreateInvoiceItemRequest {
  const CreateInvoiceItemRequest({
    required this.productId,
    required this.quantity,
    required this.discount,
    required this.tax,
    this.serialNumber,
    this.imeiNumber,
  });

  final String productId;
  final int quantity;
  final double discount;
  final double tax;
  final String? serialNumber;
  final String? imeiNumber;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'discount': discount,
      'tax': tax,
      'serial_number': serialNumber,
      'imei_number': imeiNumber,
    };
  }
}