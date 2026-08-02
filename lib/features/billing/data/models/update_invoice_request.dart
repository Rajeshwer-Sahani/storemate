import 'package:storemate/features/billing/data/models/create_invoice_item_request.dart';

/// ============================================================================
/// Update Invoice Request
/// ============================================================================
///
/// Mirrors the PostgreSQL RPC:
/// update_complete_invoice()
///
/// This model contains everything required to update an existing invoice.
/// ============================================================================
class UpdateInvoiceRequest {
  const UpdateInvoiceRequest({
    required this.invoiceId,
    required this.customerId,
    required this.customerName,
    required this.customerPhone,
    required this.paymentMethod,
    required this.paidAmount,
    required this.discountType,
    required this.discountValue,
    required this.taxPercentage,
    required this.notes,
    required this.items,
  });

  /// Invoice
  final String invoiceId;

  /// Customer
  final String? customerId;
  final String customerName;
  final String? customerPhone;

  /// Payment
  final String paymentMethod;
  final double paidAmount;

  /// Discount
  final String discountType;
  final double discountValue;

  /// Tax
  final double taxPercentage;

  /// Notes
  final String? notes;

  /// Products
  final List<CreateInvoiceItemRequest> items;

  /// ==========================================================================
  /// RPC Parameters
  /// ==========================================================================
  Map<String, dynamic> toRpc() {
    return {
      'p_invoice_id': invoiceId,

      'p_customer_id': customerId,
      'p_customer_name': customerName,
      'p_customer_phone': customerPhone,

      'p_payment_method': paymentMethod,
      'p_paid_amount': paidAmount,

      'p_discount_type': discountType,
      'p_discount_value': discountValue,

      'p_tax_percentage': taxPercentage,

      'p_notes': notes,

      'p_items': items.map((e) => e.toJson()).toList(),
    };
  }
}