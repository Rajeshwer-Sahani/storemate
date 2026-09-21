class ProductUnitSaleInfo {
  const ProductUnitSaleInfo({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.invoiceDate,
    this.customerName,
    this.customerPhone,
    this.paymentStatus,
    this.invoiceStatus,
  });

  final String invoiceId;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String? customerName;
  final String? customerPhone;
  final String? paymentStatus;
  final String? invoiceStatus;
}