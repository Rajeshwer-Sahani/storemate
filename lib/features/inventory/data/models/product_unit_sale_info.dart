class ProductUnitSaleInfo {
  const ProductUnitSaleInfo({
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.invoiceId,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.saleAmount,
    this.paymentStatus,
  });

  final String? customerId;
  final String customerName;
  final String? customerPhone;

  final String invoiceId;
  final String invoiceNumber;
  final DateTime invoiceDate;

  final double saleAmount;
  final String? paymentStatus;
}