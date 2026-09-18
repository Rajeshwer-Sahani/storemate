class CreateInvoiceItemRequest {
  const CreateInvoiceItemRequest({
    required this.productId,
    required this.quantity,
    required this.discount,
    required this.tax,
    this.serialNumber,
    this.imeiNumber,
    this.productUnitIds = const [],
  });

  final String productId;

  final int quantity;

  final double discount;

  final double tax;

  /// Legacy invoice-level serial number field.
  ///
  /// Kept for backward compatibility with the existing billing flow.
  final String? serialNumber;

  /// Legacy invoice-level IMEI field.
  ///
  /// Kept for backward compatibility with the existing billing flow.
  final String? imeiNumber;

  /// Exact physical product units selected for this invoice item.
  ///
  /// Quantity-based products should keep this empty.
  /// Device-tracked products should contain exactly one unit ID
  /// for every unit being sold.
  final List<String> productUnitIds;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'discount': discount,
      'tax': tax,
      'serial_number': serialNumber,
      'imei_number': imeiNumber,
      'product_unit_ids': productUnitIds,
    };
  }
}