import 'package:storemate/features/billing/data/services/invoice_return_service.dart';
import 'package:storemate/features/inventory/data/models/product_unit_model.dart';

import '../models/invoice_return_history_model.dart';
import '../models/requests/process_invoice_return_request.dart';
import '../models/returnable_item_model.dart';

class InvoiceReturnRepository {
  InvoiceReturnRepository({
    InvoiceReturnService? service,
  }) : _service = service ?? InvoiceReturnService();

  final InvoiceReturnService _service;

  Future<List<ReturnableItemModel>> getReturnableItems(
    String invoiceId,
  ) {
    return _service.getReturnableItems(invoiceId);
  }

  Future<List<InvoiceReturnHistoryModel>> getReturnHistory(
    String invoiceId,
  ) {
    return _service.getReturnHistory(invoiceId);
  }

  Future<List<ProductUnitModel>> getReturnableProductUnits({
    required String invoiceItemId,
  }) {
    return _service.getReturnableProductUnits(
      invoiceItemId: invoiceItemId,
    );
  }

  Future<String> processInvoiceReturn(
    ProcessInvoiceReturnRequest request,
  ) {
    return _service.processInvoiceReturn(request);
  }

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