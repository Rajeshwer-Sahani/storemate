import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/invoice_return_history_model.dart';
import '../models/requests/process_invoice_return_request.dart';
import '../models/returnable_item_model.dart';

class InvoiceReturnService {
  InvoiceReturnService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  static const _getReturnableItemsRpc = 'get_returnable_items';
  static const _getInvoiceReturnsRpc = 'get_invoice_returns';
  static const _processInvoiceReturnRpc = 'process_invoice_return';
  static const _validateReturnQuantityRpc = 'validate_return_quantity';

  /// Get all items that can still be returned.
  Future<List<ReturnableItemModel>> getReturnableItems(String invoiceId) async {
    try {
      final response = await _supabase.rpc(
        _getReturnableItemsRpc,
        params: {'p_invoice_id': invoiceId},
      );

      return (response as List)
          .map(
            (json) =>
                ReturnableItemModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw InvoiceReturnException(e.message);
    } catch (e) {
      throw InvoiceReturnException('Failed to load returnable items: $e');
    }
  }

  /// Get return history of an invoice.
  Future<List<InvoiceReturnHistoryModel>> getReturnHistory(
    String invoiceId,
  ) async {
    try {
      final response = await _supabase.rpc(
        _getInvoiceReturnsRpc,
        params: {'p_invoice_id': invoiceId},
      );

      return (response as List)
          .map(
            (json) => InvoiceReturnHistoryModel.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw InvoiceReturnException(e.message);
    } catch (e) {
      throw InvoiceReturnException('Failed to load return history: $e');
    }
  }

  /// Process an invoice return.
  Future<String> processInvoiceReturn(
    ProcessInvoiceReturnRequest request,
  ) async {
    return '';
  }

  /// Validate whether a quantity can be returned.
  Future<bool> validateReturnQuantity({
    required String invoiceItemId,
    required int quantity,
  }) async {
    try {
      final response = await _supabase.rpc(
        _validateReturnQuantityRpc,
        params: {'p_invoice_item_id': invoiceItemId, 'p_quantity': quantity},
      );

      return response as bool;
    } on PostgrestException catch (e) {
      throw InvoiceReturnException(e.message);
    } catch (e) {
      throw InvoiceReturnException('Failed to validate return quantity: $e');
    }
  }
}

class InvoiceReturnException implements Exception {
  const InvoiceReturnException(this.message);

  final String message;

  @override
  String toString() => message;
}
