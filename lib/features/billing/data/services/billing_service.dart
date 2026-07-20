import 'package:storemate/features/billing/data/models/create_invoice_request.dart';
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
          .eq('is_archived', false)
          .order('product_name');

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
  // Invoice
  //--------------------------

  Future<InvoiceModel> _insertInvoice({required InvoiceModel invoice}) async {
    try {
      final response = await _supabase
          .from(_invoiceTable)
          .insert(invoice.toJson())
          .select()
          .single();

      return InvoiceModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw BillingException(e.message);
    } catch (e) {
      throw BillingException('Failed to create invoice: $e');
    }
  }

  //--------------------------
  // Create Invoice
  //--------------------------
  Future<InvoiceModel> createInvoice(CreateInvoiceRequest request) async {
    try {
      final storeId = await _getCurrentStoreId();

      final invoiceId = await _supabase.rpc(
        'create_complete_invoice',
        params: {
          'p_store_id': storeId,
          'p_customer_id': request.customerId,
          'p_customer_name': request.customerName,
          'p_customer_phone': request.customerPhone,
          'p_items': request.items.map((item) => item.toJson()).toList(),
          'p_discount': request.discount,
          'p_tax': request.tax,
          'p_paid_amount': request.paidAmount,
          'p_payment_method': request.paymentMethod,
          'p_notes': request.notes,
        },
      );

      final response = await _supabase
          .from(_invoiceTable)
          .select()
          .eq('id', invoiceId)
          .single();

      return InvoiceModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw BillingException(e.message);
    } catch (e) {
      throw BillingException('Failed to create invoice: $e');
    }
  }

  //--------------------------
  // Invoice Items
  //--------------------------
  Future<void> _insertInvoiceItems({
    required String invoiceId,
    required List<InvoiceItemModel> items,
  }) async {
    try {
      final invoiceItems = items.map((item) {
        return item.copyWith(id: '', invoiceId: invoiceId).toJson();
      }).toList();

      await _supabase.from(_invoiceItemsTable).insert(invoiceItems);
    } on PostgrestException catch (e) {
      throw BillingException(e.message);
    } catch (e) {
      throw BillingException('Failed to save invoice items: $e');
    }
  }

  //--------------------------
  // Inventory
  //--------------------------

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
