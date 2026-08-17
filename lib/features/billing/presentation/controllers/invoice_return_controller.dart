import 'package:flutter/foundation.dart';
import 'package:storemate/features/billing/data/models/invoice_return_item_model.dart';

import '../../data/models/invoice_return_history_model.dart';
import '../../data/models/requests/process_invoice_return_request.dart';
import '../../data/models/requests/process_return_item_request.dart';
import '../../data/models/returnable_item_model.dart';
import '../../data/repositories/invoice_return_repository.dart';

class InvoiceReturnController extends ChangeNotifier {
  InvoiceReturnController({InvoiceReturnRepository? repository})
    : _repository = repository ?? InvoiceReturnRepository();

  final InvoiceReturnRepository _repository;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  String? _error;

  String? get error => _error;

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  List<ReturnableItemModel> _returnableItems = [];
  List<ReturnableItemModel> get returnableItems => _returnableItems;

  List<InvoiceReturnHistoryModel> _returnHistory = [];
  List<InvoiceReturnHistoryModel> get returnHistory => _returnHistory;

  /// Selected items keyed by invoice_item_id.
  final Map<String, ProcessReturnItemRequest> _selectedItems = {};

  Map<String, ProcessReturnItemRequest> get selectedItems =>
      Map.unmodifiable(_selectedItems);

ReturnReason? _returnReason;

ReturnReason? get returnReason => _returnReason;

  String _notes = '';

  String get notes => _notes;

  double _refundAmount = 0;

  double get refundAmount => _refundAmount;

  /// Fetches all items that are eligible for return.
  Future<void> fetchReturnableItems(String invoiceId) async {
    _setLoading(true);

    try {
      _returnableItems = await _repository.getReturnableItems(invoiceId);

      _setError(null);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Fetches the return history of an invoice.
  Future<void> fetchReturnHistory(String invoiceId) async {
    _setLoading(true);

    try {
      _returnHistory = await _repository.getReturnHistory(invoiceId);

      _setError(null);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Processes an invoice return.
  Future<String> processInvoiceReturn({
  required String invoiceId,
  required String storeId,
  required ReturnReason returnReason,
  String? notes,
  required List<ProcessReturnItemRequest> returnItems,
}) async {
  final request = ProcessInvoiceReturnRequest(
    invoiceId: invoiceId,
    storeId: storeId,
    returnReason: returnReason.dbValue,
    notes: notes,
    returnItems: returnItems,
  );

  _setLoading(true);

  try {
    final result = await _repository.processInvoiceReturn(request);

    _setError(null);

    return result;
  } catch (e) {
    _setError(e.toString());
    rethrow;
  } finally {
    _setLoading(false);
  }
}

  /// Validates whether the requested quantity can be returned.
  Future<bool> validateReturnQuantity({
    required String invoiceItemId,
    required int quantity,
  }) async {
    try {
      return await _repository.validateReturnQuantity(
        invoiceItemId: invoiceItemId,
        quantity: quantity,
      );
    } catch (e) {
      _setError(e.toString());
      rethrow;
    }
  }

  void selectItem(ReturnableItemModel item) {
    _selectedItems[item.invoiceItemId] = ProcessReturnItemRequest(
      invoiceItemId: item.invoiceItemId,
      quantity: 1,
    );

    _calculateRefundAmount();

    notifyListeners();
  }

  void removeSelectedItem(String invoiceItemId) {
    _selectedItems.remove(invoiceItemId);

    _calculateRefundAmount();

    notifyListeners();
  }

  void updateQuantity(String invoiceItemId, int quantity) {
    final item = _selectedItems[invoiceItemId];

    if (item == null) return;

    _selectedItems[invoiceItemId] = item.copyWith(quantity: quantity);

    _calculateRefundAmount();

    notifyListeners();
  }

  void updateReturnReason(ReturnReason? value) {
  _returnReason = value;

  notifyListeners();
}

  void updateNotes(String value) {
    _notes = value;

    notifyListeners();
  }

  void _calculateRefundAmount() {
    double total = 0;

    for (final selected in _selectedItems.values) {
      final product = _returnableItems.firstWhere(
        (item) => item.invoiceItemId == selected.invoiceItemId,
      );

      total += product.unitPrice * selected.quantity;
    }

    _refundAmount = total;
  }

  void clearSelection() {
    _selectedItems.clear();

    _returnReason = null;

    _notes = '';

    _refundAmount = 0;

    notifyListeners();
  }
}
