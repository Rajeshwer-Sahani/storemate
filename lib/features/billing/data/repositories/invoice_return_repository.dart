import '../models/invoice_return_history_model.dart';
import '../models/requests/process_invoice_return_request.dart';
import '../models/returnable_item_model.dart';
import '../services/invoice_return_service.dart';

class InvoiceReturnRepository {
  InvoiceReturnRepository({
    InvoiceReturnService? service,
  }) : _service = service ?? InvoiceReturnService();

  final InvoiceReturnService _service;

  /// Returns all items that are eligible for return.
  Future<List<ReturnableItemModel>> getReturnableItems(
    String invoiceId,
  ) {
    return _service.getReturnableItems(invoiceId);
  }

  /// Returns the return history of an invoice.
  Future<List<InvoiceReturnHistoryModel>> getReturnHistory(
    String invoiceId,
  ) {
    return _service.getReturnHistory(invoiceId);
  }

  /// Processes an invoice return.
  Future<String> processInvoiceReturn(
    ProcessInvoiceReturnRequest request,
  ) {
    return _service.processInvoiceReturn(request);
  }

  /// Validates whether the requested quantity can be returned.
  Future<bool> validateReturnQuantity({
    required String invoiceItemId,
    required int quantity,
  }) {
    return _service.validateReturnQuantity(
      invoiceItemId: invoiceItemId,
      quantity: quantity,
    );
  }
}