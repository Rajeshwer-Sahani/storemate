import 'package:flutter/foundation.dart';
import 'package:storemate/features/billing/data/models/invoice_return_item_model.dart';
import 'package:storemate/features/inventory/data/models/product_unit_model.dart';

import '../../data/models/invoice_return_history_model.dart';
import '../../data/models/requests/process_invoice_return_request.dart';
import '../../data/models/requests/process_return_item_request.dart';
import '../../data/models/returnable_item_model.dart';
import '../../data/repositories/invoice_return_repository.dart';

class InvoiceReturnController extends ChangeNotifier {
  InvoiceReturnController({
    InvoiceReturnRepository? repository,
  }) : _repository = repository ?? InvoiceReturnRepository();

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

  /// Selected return items keyed by invoice_item_id.
  final Map<String, ProcessReturnItemRequest> _selectedItems = {};

  Map<String, ProcessReturnItemRequest> get selectedItems =>
      Map.unmodifiable(_selectedItems);

  /// Exact devices available for return, keyed by invoice_item_id.
  final Map<String, List<ProductUnitModel>> _returnableProductUnits = {};

  List<ProductUnitModel> getReturnableProductUnits(
    String invoiceItemId,
  ) {
    return List.unmodifiable(
      _returnableProductUnits[invoiceItemId] ?? const [],
    );
  }

  ReturnReason? _returnReason;

  ReturnReason? get returnReason => _returnReason;

  String _notes = '';

  String get notes => _notes;

  double _refundAmount = 0;

  double get refundAmount => _refundAmount;

  // ---------------------------------------------------------------------------
  // FETCH
  // ---------------------------------------------------------------------------

  Future<void> fetchReturnableItems(String invoiceId) async {
    _setLoading(true);

    try {
      _returnableItems = await _repository.getReturnableItems(invoiceId);

      _returnableProductUnits.clear();

      final deviceItems = _returnableItems
          .where((item) => item.isDeviceTracked)
          .toList();

      if (deviceItems.isNotEmpty) {
        final results = await Future.wait(
          deviceItems.map(
            (item) async {
              final units =
                  await _repository.getReturnableProductUnits(
                invoiceItemId: item.invoiceItemId,
              );

              return MapEntry(item.invoiceItemId, units);
            },
          ),
        );

        for (final result in results) {
          _returnableProductUnits[result.key] = result.value;
        }
      }

      _setError(null);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

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

  // ---------------------------------------------------------------------------
  // PROCESS RETURN
  // ---------------------------------------------------------------------------

  Future<String> processInvoiceReturn({
    required String invoiceId,
    required String storeId,
    required ReturnReason returnReason,
    String? notes,
    required List<ProcessReturnItemRequest> returnItems,
  }) async {
    final validationError = validateSelectedItems();

    if (validationError != null) {
      throw StateError(validationError);
    }

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

  // ---------------------------------------------------------------------------
  // VALIDATION
  // ---------------------------------------------------------------------------

  String? validateSelectedItems() {
    if (_selectedItems.isEmpty) {
      return 'Please select at least one item to return.';
    }

    for (final selected in _selectedItems.values) {
      final item = _returnableItems.firstWhere(
        (item) => item.invoiceItemId == selected.invoiceItemId,
      );

      if (selected.quantity <= 0) {
        return 'Return quantity must be greater than zero.';
      }

      if (selected.quantity > item.remainingQuantity) {
        return 'Return quantity for ${item.productName} cannot exceed '
            '${item.remainingQuantity}.';
      }

      if (item.isDeviceTracked) {
        if (selected.productUnitIds.length != selected.quantity) {
          return 'Please select exactly ${selected.quantity} device(s) '
              'for ${item.productName}.';
        }

        final availableUnitIds = _returnableProductUnits[
              item.invoiceItemId
            ]?.map((unit) => unit.id).toSet() ??
            <String>{};

        for (final unitId in selected.productUnitIds) {
          if (!availableUnitIds.contains(unitId)) {
            return 'One or more selected devices are no longer available '
                'for return.';
          }
        }
      } else if (selected.productUnitIds.isNotEmpty) {
        return 'Device selections are not allowed for ${item.productName}.';
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // ITEM SELECTION
  // ---------------------------------------------------------------------------

  void selectItem(ReturnableItemModel item) {
    _selectedItems[item.invoiceItemId] = ProcessReturnItemRequest(
      invoiceItemId: item.invoiceItemId,
      quantity: 1,
      productUnitIds: const [],
    );

    _calculateRefundAmount();

    notifyListeners();
  }

  void removeSelectedItem(String invoiceItemId) {
    _selectedItems.remove(invoiceItemId);

    _calculateRefundAmount();

    notifyListeners();
  }

  void updateQuantity(
    String invoiceItemId,
    int quantity,
  ) {
    final item = _selectedItems[invoiceItemId];

    if (item == null) return;

    final returnableItem = _returnableItems.firstWhere(
      (item) => item.invoiceItemId == invoiceItemId,
    );

    _selectedItems[invoiceItemId] = item.copyWith(
      quantity: quantity,
      // Changing quantity invalidates the previous exact-device selection.
      productUnitIds: returnableItem.isDeviceTracked
          ? const []
          : item.productUnitIds,
    );

    _calculateRefundAmount();

    notifyListeners();
  }

  void updateSelectedDevices({
    required String invoiceItemId,
    required List<String> productUnitIds,
  }) {
    final item = _selectedItems[invoiceItemId];

    if (item == null) return;

    if (productUnitIds.length != item.quantity) {
      throw StateError(
        'Please select exactly ${item.quantity} device(s).',
      );
    }

    _selectedItems[invoiceItemId] = item.copyWith(
      productUnitIds: List.unmodifiable(productUnitIds),
    );

    notifyListeners();
  }

  List<String> getSelectedDeviceIds(String invoiceItemId) {
    return List.unmodifiable(
      _selectedItems[invoiceItemId]?.productUnitIds ?? const [],
    );
  }

  // ---------------------------------------------------------------------------
  // RETURN DETAILS
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // VALIDATE QUANTITY
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // CLEAR
  // ---------------------------------------------------------------------------

  void clearSelection() {
    _selectedItems.clear();

    _returnReason = null;

    _notes = '';

    _refundAmount = 0;

    notifyListeners();
  }
}