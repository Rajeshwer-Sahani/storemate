import 'create_invoice_item_request.dart';

class CreateInvoiceRequest {
  const CreateInvoiceRequest({
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    required this.items,
    required this.discount,
    required this.tax,
    required this.paidAmount,
    required this.paymentMethod,
    this.notes,
  });

  final String customerId;
  final String customerName;
  final String? customerPhone;

  final List<CreateInvoiceItemRequest> items;

  final double discount;
  final double tax;
  final double paidAmount;

  final String paymentMethod;
  final String? notes;
}