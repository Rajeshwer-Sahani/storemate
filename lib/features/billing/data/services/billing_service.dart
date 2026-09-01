import 'package:flutter/material.dart';
import 'package:storemate/features/billing/data/models/create_invoice_request.dart';
import 'package:storemate/features/billing/data/models/invoice_timeline_model.dart';
import 'package:storemate/features/billing/data/models/payment_history_model.dart';
import 'package:storemate/features/billing/data/models/receive_payment_request.dart';
import 'package:storemate/features/billing/data/models/update_invoice_request.dart';
import 'package:storemate/features/store/data/module/store_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../customers/data/models/customer_model.dart';
import '../../../inventory/data/models/product_model.dart';

import '../models/invoice_item_model.dart';
import '../models/invoice_model.dart';

class BillingService {
  BillingService({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  static const _storesTable = 'stores';
  static const _customersTable = 'customers';
  static const _productsTable = 'products';

  static const _invoiceTable = 'invoices';
  static const _invoiceItemsTable = 'invoice_items';
  static const _invoiceSequencesTable = 'invoice_sequences';

  static const _stockAdjustmentsTable = 'stock_adjustments';

  //--------------------------
  // Invoice Number
  //--------------------------

  Future<String> getNextInvoiceNumber() async {
    try {
      final storeId = await _getCurrentStoreId();

      final sequence = await _supabase
          .from(_invoiceSequencesTable)
          .select('id, last_invoice_number')
          .eq('store_id', storeId)
          .single();

      final sequenceId = sequence['id'] as String;
      final currentNumber = sequence['last_invoice_number'] as int;

      final nextNumber = currentNumber + 1;

      await _supabase
          .from(_invoiceSequencesTable)
          .update({'last_invoice_number': nextNumber})
          .eq('id', sequenceId);

      return _formatInvoiceNumber(nextNumber);
    } on PostgrestException catch (e) {
      throw BillingException(e.message);
    } catch (e) {
      throw BillingException('Failed to generate invoice number: $e');
    }
  }

  //--------------------------
  // Customers
  //--------------------------

  Future<List<CustomerModel>> getCustomers() async {
    try {
      final storeId = await _getCurrentStoreId();

      final response = await _supabase
          .from(_customersTable)
          .select()
          .eq('store_id', storeId)
          .eq('is_archived', false)
          .order('full_name');

      return response
          .map<CustomerModel>((json) => CustomerModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw BillingException(e.message);
    } catch (e) {
      throw BillingException('Failed to load customers: $e');
    }
  }

  //--------------------------
  // Products
  //--------------------------

  Future<List<ProductModel>> getProducts() async {
    try {
      final storeId = await _getCurrentStoreId();

      final response = await _supabase
          .from(_productsTable)
          .select()
          .eq('store_id', storeId)
          .eq('is_active', true)
          .order('name');

      return response
          .map<ProductModel>((json) => ProductModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw BillingException(e.message);
    } catch (e) {
      throw BillingException('Failed to load products: $e');
    }
  }

  //--------------------------
  // Create Invoice
  //--------------------------
  Future<InvoiceModel> createInvoice(CreateInvoiceRequest request) async {
    try {
      final storeId = await _getCurrentStoreId();

      print('==============================');
      print('STORE ID: $storeId');

      final invoiceId = await _supabase.rpc(
        'create_complete_invoice',
        params: {
          'p_store_id': storeId,
          'p_customer_id': request.customerId,
          'p_customer_name': request.customerName,
          'p_customer_phone': request.customerPhone,
          'p_items': request.items.map((e) => e.toJson()).toList(),
          'p_discount': request.discount,
          'p_tax': request.tax,
          'p_paid_amount': request.paidAmount,
          'p_payment_method': request.paymentMethod,
          'p_notes': request.notes,
        },
      );

      print('RPC returned: $invoiceId');

      print('Invoice ID: $invoiceId');

      final response = await _supabase
          .from(_invoiceTable)
          .select('''
      *,
      invoice_items (
        quantity,
        invoice_return_items (
          quantity
        )
      ),
      emi_plans (
        id
      )
    ''')
          .eq('id', invoiceId)
          .single();

      final invoiceJson = Map<String, dynamic>.from(response);

      final emiPlans = (response['emi_plans'] as List?) ?? const [];

      invoiceJson['emi_plan_id'] = emiPlans.isNotEmpty
          ? emiPlans.first['id'] as String?
          : null;

      int totalItemQuantity = 0;
      int returnedItemQuantity = 0;

      final invoiceItems = (response['invoice_items'] as List?) ?? const [];

      for (final item in invoiceItems) {
        final itemJson = Map<String, dynamic>.from(item);

        totalItemQuantity += (itemJson['quantity'] as num?)?.toInt() ?? 0;

        final returnItems =
            (itemJson['invoice_return_items'] as List?) ?? const [];

        for (final returnItem in returnItems) {
          final returnItemJson = Map<String, dynamic>.from(returnItem);

          returnedItemQuantity +=
              (returnItemJson['quantity'] as num?)?.toInt() ?? 0;
        }
      }

      invoiceJson['total_item_quantity'] = totalItemQuantity;
      invoiceJson['returned_item_quantity'] = returnedItemQuantity;

      print('================ INVOICE JSON ================');

      invoiceJson.forEach((key, value) {
        print('$key : $value (${value.runtimeType})');
      });

      print('==============================================');

      return InvoiceModel.fromJson(invoiceJson);
    } on PostgrestException catch (e, stack) {
      print('========== POSTGREST ==========');
      print('message: ${e.message}');
      print('code: ${e.code}');
      print('details: ${e.details}');
      print('hint: ${e.hint}');
      print(stack);
      rethrow;
    }
  }

  //--------------------------
  // Invoices
  //--------------------------

  Future<List<InvoiceModel>> getInvoices() async {
    try {
      final storeId = await _getCurrentStoreId();

      final response = await _supabase
          .from(_invoiceTable)
          .select('''
      *,
      invoice_items (
        quantity,
        invoice_return_items (
          quantity
        )
      ),
      emi_plans (
        id
      )
    ''')
          .eq('store_id', storeId)
          .order('invoice_date', ascending: false);

      return (response as List).map<InvoiceModel>((json) {
        try {
          final invoiceJson = Map<String, dynamic>.from(json);

          final emiPlans = (json['emi_plans'] as List?) ?? const [];

          invoiceJson['emi_plan_id'] = emiPlans.isNotEmpty
              ? emiPlans.first['id'] as String?
              : null;

          int totalItemQuantity = 0;
          int returnedItemQuantity = 0;

          final invoiceItems = (json['invoice_items'] as List?) ?? const [];

          for (final item in invoiceItems) {
            final itemJson = Map<String, dynamic>.from(item);

            totalItemQuantity += (itemJson['quantity'] as num?)?.toInt() ?? 0;

            final returnItems =
                (itemJson['invoice_return_items'] as List?) ?? const [];

            for (final returnItem in returnItems) {
              final returnItemJson = Map<String, dynamic>.from(returnItem);

              returnedItemQuantity +=
                  (returnItemJson['quantity'] as num?)?.toInt() ?? 0;
            }
          }

          invoiceJson['total_item_quantity'] = totalItemQuantity;
          invoiceJson['returned_item_quantity'] = returnedItemQuantity;

          return InvoiceModel.fromJson(invoiceJson);
        } catch (e) {
          debugPrint('==============================');
          debugPrint('Failed invoice JSON:');
          debugPrint(json.toString());
          debugPrint('Error: $e');
          debugPrint('==============================');
          rethrow;
        }
      }).toList();
    } on PostgrestException catch (e) {
      throw BillingException(e.message);
    } catch (e) {
      throw BillingException('Failed to load invoices: $e');
    }
  }

  Future<InvoiceModel> getInvoiceById(String invoiceId) async {
    try {
      final response = await _supabase
          .from(_invoiceTable)
          .select('''
      *,
      invoice_items (
        quantity,
        invoice_return_items (
          quantity
        )
      ),
      emi_plans (
        id
      )
    ''')
          .eq('id', invoiceId)
          .single();

      final invoiceJson = Map<String, dynamic>.from(response);

      final emiPlans = (response['emi_plans'] as List?) ?? const [];

      invoiceJson['emi_plan_id'] = emiPlans.isNotEmpty
          ? emiPlans.first['id'] as String?
          : null;

      int totalItemQuantity = 0;
      int returnedItemQuantity = 0;

      final invoiceItems = (response['invoice_items'] as List?) ?? const [];

      for (final item in invoiceItems) {
        final itemJson = Map<String, dynamic>.from(item);

        totalItemQuantity += (itemJson['quantity'] as num?)?.toInt() ?? 0;

        final returnItems =
            (itemJson['invoice_return_items'] as List?) ?? const [];

        for (final returnItem in returnItems) {
          final returnItemJson = Map<String, dynamic>.from(returnItem);

          returnedItemQuantity +=
              (returnItemJson['quantity'] as num?)?.toInt() ?? 0;
        }
      }

      invoiceJson['total_item_quantity'] = totalItemQuantity;
      invoiceJson['returned_item_quantity'] = returnedItemQuantity;

      return InvoiceModel.fromJson(invoiceJson);
    } on PostgrestException catch (e) {
      throw BillingException(e.message);
    } catch (e) {
      throw BillingException('Failed to load invoice: $e');
    }
  }

  Future<List<InvoiceItemModel>> getInvoiceItems(String invoiceId) async {
    try {
      final response = await _supabase
          .from(_invoiceItemsTable)
          .select('''
          *,
          invoice_return_items (
            quantity
          )
        ''')
          .eq('invoice_id', invoiceId)
          .order('created_at');

      return (response as List).map<InvoiceItemModel>((json) {
        final itemJson = Map<String, dynamic>.from(json);

        // -----------------------------------------------------------------------
        // Calculate total returned quantity for this invoice item.
        // -----------------------------------------------------------------------

        int returnedQuantity = 0;

        final returnItems =
            (itemJson['invoice_return_items'] as List?) ?? const [];

        for (final returnItem in returnItems) {
          final returnItemJson = Map<String, dynamic>.from(returnItem);

          returnedQuantity +=
              (returnItemJson['quantity'] as num?)?.toInt() ?? 0;
        }

        // The nested relation is only needed to calculate returnedQuantity.
        // We don't need to keep it inside InvoiceItemModel.
        itemJson.remove('invoice_return_items');

        itemJson['returned_quantity'] = returnedQuantity;

        return InvoiceItemModel.fromJson(itemJson);
      }).toList();
    } on PostgrestException catch (e) {
      throw BillingException(e.message);
    } catch (e) {
      throw BillingException('Failed to load invoice items: $e');
    }
  }

  // ============================================================================
  // Update Invoice
  // ============================================================================

  Future<String> updateInvoice(UpdateInvoiceRequest request) async {
    try {
      final response = await _supabase.rpc(
        'update_complete_invoice',
        params: request.toRpc(),
      );

      if (response == null) {
        throw const BillingException('Invoice update failed.');
      }

      if (response is! String) {
        throw const BillingException(
          'Unexpected response received while updating invoice.',
        );
      }

      return response;
    } on PostgrestException catch (e) {
      throw BillingException(e.message);
    } catch (e) {
      throw BillingException('Failed to update invoice: $e');
    }
  }

  // ============================================================================
  // Get Current Store
  // ============================================================================

  Future<StoreModel> getCurrentStore() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User not authenticated');
    }

    final response = await _supabase
        .from('stores')
        .select()
        .eq('owner_id', userId)
        .single();

    return StoreModel.fromJson(response);
  }

  // ============================================================================
  // Receive Payment
  // ============================================================================

  Future<String> receivePayment(ReceivePaymentRequest request) async {
    try {
      final response = await _supabase.rpc(
        'receive_invoice_payment',
        params: request.toRpc(),
      );

      if (response == null) {
        throw const BillingException('Payment could not be processed.');
      }

      if (response is! String) {
        throw const BillingException(
          'Unexpected response received while processing payment.',
        );
      }

      return response;
    } on PostgrestException catch (e) {
      throw BillingException(e.message);
    } catch (e) {
      throw BillingException('Failed to receive payment: $e');
    }
  }

  // ============================================================================
  // Get Invoice Payment History
  // ============================================================================

  Future<List<PaymentHistoryModel>> getInvoicePayments(String invoiceId) async {
    try {
      final response = await _supabase
          .from('invoice_payments')
          .select()
          .eq('invoice_id', invoiceId)
          .order('created_at', ascending: false);

      return (response as List)
          .map(
            (json) =>
                PaymentHistoryModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw BillingException(e.message);
    } catch (e) {
      throw BillingException('Failed to load payment history: $e');
    }
  }

  // ============================================================================
  // Get Invoice Timeline
  // ============================================================================

  Future<List<InvoiceTimelineModel>> getInvoiceTimeline(
    String invoiceId,
  ) async {
    try {
      final response = await _supabase
          .from('invoice_timeline')
          .select()
          .eq('invoice_id', invoiceId)
          .order('created_at', ascending: false);

      return (response as List)
          .map(
            (json) =>
                InvoiceTimelineModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } on PostgrestException catch (e) {
      throw BillingException(e.message);
    } catch (e) {
      throw BillingException('Failed to load invoice timeline.');
    }
  }

  // ============================================================================
  // Delete Invoice
  // ============================================================================

  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _supabase.rpc(
        'delete_invoice',
        params: {'p_invoice_id': invoiceId},
      );
    } on PostgrestException catch (e) {
      throw BillingException(e.message);
    } catch (e) {
      throw BillingException('Failed to delete invoice. Please try again.');
    }
  }

  //--------------------------
  // Search
  //--------------------------

  //--------------------------
  // Reports
  //--------------------------

  //--------------------------
  // Helper Methods
  //--------------------------

  Future<String> _getCurrentStoreId() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw const BillingException('User is not authenticated.');
    }

    final response = await _supabase
        .from(_storesTable)
        .select('id')
        .eq('owner_id', user.id)
        .single();

    return response['id'] as String;
  }
}

// Formats the invoice number with leading zeros and a prefix.
String _formatInvoiceNumber(int sequence) {
  return 'INV-${sequence.toString().padLeft(6, '0')}';
}

class BillingException implements Exception {
  const BillingException(this.message);

  final String message;

  @override
  String toString() => message;
}
