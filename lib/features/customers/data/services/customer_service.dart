import 'package:storemate/features/customers/data/models/customer_activity_model.dart';
import 'package:storemate/features/customers/data/models/customer_summary_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/customer_model.dart';

class CustomerService {
  CustomerService({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _customersTable = 'customers';
  static const String _storesTable = 'stores';
  static const String _invoicesTable = 'invoices';
  static const String _emiPlansTable = 'emi_plans';

  /// Returns the current user's store ID.
  Future<String> _getStoreId() async {
    final user = _client.auth.currentUser;

    if (user == null) {
      throw Exception('User is not authenticated.');
    }

    final response = await _client
        .from(_storesTable)
        .select('id')
        .eq('owner_id', user.id)
        .single();

    return response['id'] as String;
  }

  // ===========================================================================
  // Customers
  // ===========================================================================

  /// Fetch all active customers.
  Future<List<CustomerModel>> getCustomers() async {
    final storeId = await _getStoreId();

    final response = await _client
        .from(_customersTable)
        .select()
        .eq('store_id', storeId)
        .eq('is_archived', false)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CustomerModel.fromJson(json))
        .toList();
  }

  /// Fetch a customer by ID.
  Future<CustomerModel> getCustomerById(String customerId) async {
    final response = await _client
        .from(_customersTable)
        .select()
        .eq('id', customerId)
        .single();

    return CustomerModel.fromJson(response);
  }

  /// Add a new customer.
  Future<void> addCustomer({
    required String fullName,
    required String phoneNumber,
    String? email,
    String? address,
    String? notes,
  }) async {
    final storeId = await _getStoreId();

    await _client.from(_customersTable).insert({
      'store_id': storeId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'email': email,
      'address': address,
      'notes': notes,
    });
  }

  /// Update customer.
  Future<void> updateCustomer(CustomerModel customer) async {
    await _client
        .from(_customersTable)
        .update({
          'full_name': customer.fullName,
          'phone_number': customer.phoneNumber,
          'email': customer.email,
          'address': customer.address,
          'notes': customer.notes,
        })
        .eq('id', customer.id);
  }

  /// Archive customer.
  Future<void> archiveCustomer(String customerId) async {
    await _client
        .from(_customersTable)
        .update({'is_archived': true})
        .eq('id', customerId);
  }

  /// Fetch all archived customers.
  Future<List<CustomerModel>> getArchivedCustomers() async {
    final storeId = await _getStoreId();

    final response = await _client
        .from(_customersTable)
        .select()
        .eq('store_id', storeId)
        .eq('is_archived', true)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => CustomerModel.fromJson(json))
        .toList();
  }

  /// Restore archived customer.
  Future<void> restoreCustomer(String customerId) async {
    await _client
        .from(_customersTable)
        .update({'is_archived': false})
        .eq('id', customerId);
  }

  /// Search customers.
  Future<List<CustomerModel>> searchCustomers(String query) async {
    final storeId = await _getStoreId();

    final response = await _client
        .from(_customersTable)
        .select()
        .eq('store_id', storeId)
        .eq('is_archived', false)
        .or('full_name.ilike.%$query%,phone_number.ilike.%$query%')
        .order('full_name');

    return (response as List)
        .map((json) => CustomerModel.fromJson(json))
        .toList();
  }

  // ===========================================================================
  // Customer Purchase Summary
  // ===========================================================================

  /// Returns the customer's total net purchase amount.
  ///
  /// Purchase value is calculated from the invoice's current/net value:
  ///
  ///   grand_total - returned_amount
  ///
  /// This prevents returned products from continuing to contribute to the
  /// customer's lifetime purchase amount.
  Future<double> getCustomerPurchaseTotal(String customerId) async {
    final storeId = await _getStoreId();

    final response = await _client
        .from(_invoicesTable)
        .select('grand_total, returned_amount')
        .eq('store_id', storeId)
        .eq('customer_id', customerId);

    double total = 0;

    for (final row in response as List) {
      final data = Map<String, dynamic>.from(row);

      final grandTotal = (data['grand_total'] as num?)?.toDouble() ?? 0.0;

      final returnedAmount =
          (data['returned_amount'] as num?)?.toDouble() ?? 0.0;

      final netAmount = grandTotal - returnedAmount;

      // Protect against invalid negative values.
      total += netAmount > 0 ? netAmount : 0;
    }

    return total;
  }

  // ===========================================================================
  // Customer EMI Summary
  // ===========================================================================

  /// Returns the number of EMI plans belonging to the customer.
  ///
  /// This represents EMI plans, not installments or individual EMI payments.
  Future<int> getCustomerEmiCount(String customerId) async {
    final storeId = await _getStoreId();

    final response = await _client
        .from(_emiPlansTable)
        .select('id')
        .eq('store_id', storeId)
        .eq('customer_id', customerId);

    return (response as List).length;
  }

  // ============================================================================
  // Customer Summary
  // ============================================================================

  Future<CustomerSummaryModel> getCustomerSummary(String customerId) async {
    final storeId = await _getStoreId();

    final results = await Future.wait([
      _client
          .from('invoices')
          .select('id, grand_total, returned_amount')
          .eq('store_id', storeId)
          .eq('customer_id', customerId),

      _client
          .from('emi_plans')
          .select('id')
          .eq('store_id', storeId)
          .eq('customer_id', customerId),
    ]);

    final invoices = (results[0] as List)
        .map((json) => Map<String, dynamic>.from(json))
        .toList();

    final emiPlans = (results[1] as List)
        .map((json) => Map<String, dynamic>.from(json))
        .toList();

    double purchaseAmount = 0;

    for (final invoice in invoices) {
      final grandTotal = (invoice['grand_total'] as num?)?.toDouble() ?? 0;

      final returnedAmount =
          (invoice['returned_amount'] as num?)?.toDouble() ?? 0;

      // Purchases represent the customer's net purchase value.
      final netAmount = grandTotal - returnedAmount;

      purchaseAmount += netAmount > 0 ? netAmount : 0;
    }

    return CustomerSummaryModel(
      purchaseAmount: purchaseAmount,
      emiCount: emiPlans.length,
      warrantyCount: 0,
      repairCount: 0,
    );
  }

  // ============================================================================
  // Customer Recent Activity
  // ============================================================================

  // ============================================================================
  // Customer Recent Activity
  // ============================================================================

  Future<List<CustomerActivityModel>> getCustomerRecentActivity(
    String customerId,
  ) async {
    final storeId = await _getStoreId();

    // --------------------------------------------------------------------------
    // Load customer's invoices first.
    //
    // We need the invoice IDs because invoice payments are related to invoices.
    // --------------------------------------------------------------------------

    final invoiceResponse = await _client
        .from(_invoicesTable)
        .select('''
        id,
        invoice_number,
        invoice_timeline (
          id,
          event_type,
          event_title,
          event_description,
          amount,
          payment_method,
          created_at
        )
      ''')
        .eq('store_id', storeId)
        .eq('customer_id', customerId);

    final invoices = (invoiceResponse as List)
        .map((json) => Map<String, dynamic>.from(json))
        .toList();

    final invoiceIds = invoices
        .map((invoice) => invoice['id'] as String)
        .toList();

    // --------------------------------------------------------------------------
    // Load invoice payments + EMI payments.
    //
    // invoice_payments is the authoritative source for invoice payments.
    // emi_payments is the authoritative source for EMI payments.
    // --------------------------------------------------------------------------

    final results = await Future.wait([
      _getCustomerInvoicePayments(invoiceIds: invoiceIds),

      _getCustomerEmiPayments(customerId: customerId, storeId: storeId),
    ]);

    final invoicePayments = results[0] as List<Map<String, dynamic>>;

    final emiPayments = results[1] as List<Map<String, dynamic>>;

    final activities = <CustomerActivityModel>[];

    // --------------------------------------------------------------------------
    // Build invoice lookup.
    // --------------------------------------------------------------------------

    final invoiceById = <String, Map<String, dynamic>>{
      for (final invoice in invoices) invoice['id'] as String: invoice,
    };

    // ==========================================================================
    // 1. Invoice Timeline Activities
    // ==========================================================================

    for (final invoice in invoices) {
      final invoiceId = invoice['id'] as String;

      final invoiceNumber = invoice['invoice_number'] as String? ?? 'Invoice';

      final timeline = (invoice['invoice_timeline'] as List?) ?? const [];

      for (final event in timeline) {
        final eventJson = Map<String, dynamic>.from(event);

        final eventType = eventJson['event_type'] as String? ?? '';

        final eventTitle =
            eventJson['event_title'] as String? ?? 'Invoice activity';

        // ----------------------------------------------------------------------
        // IMPORTANT:
        //
        // Payment events are intentionally skipped here.
        //
        // They will be added from invoice_payments below so that we don't show
        // the same payment twice.
        // ----------------------------------------------------------------------

        if (_isInvoicePaymentTimelineEvent(
          eventType: eventType,
          eventTitle: eventTitle,
        )) {
          continue;
        }

        final createdAt = DateTime.tryParse(
          eventJson['created_at'] as String? ?? '',
        );

        if (createdAt == null) {
          continue;
        }

        activities.add(
          CustomerActivityModel(
            type: CustomerActivityType.invoice,
            title: eventTitle,
            description:
                eventJson['event_description'] as String? ?? invoiceNumber,
            amount: (eventJson['amount'] as num?)?.toDouble(),
            paymentMethod: eventJson['payment_method'] as String?,
            dateTime: createdAt,
            invoiceId: invoiceId,
            invoiceNumber: invoiceNumber,
          ),
        );
      }
    }

    // ==========================================================================
    // 2. Invoice Payment Activities
    // ==========================================================================

    for (final payment in invoicePayments) {
      final invoiceId = payment['invoice_id'] as String;

      final invoice = invoiceById[invoiceId];

      final invoiceNumber =
          invoice?['invoice_number'] as String? ??
          payment['invoice_number'] as String? ??
          'Invoice';

      final createdAt = DateTime.tryParse(
        payment['created_at'] as String? ?? '',
      );

      if (createdAt == null) {
        continue;
      }

      final amount = (payment['amount'] as num?)?.toDouble() ?? 0;

      final paymentMethod = payment['payment_method'] as String?;

      activities.add(
        CustomerActivityModel(
          type: CustomerActivityType.invoicePayment,
          title: 'Payment Received',
          description: paymentMethod != null && paymentMethod.trim().isNotEmpty
              ? 'Received ${_formatActivityAmount(amount)} via ${_formatPaymentMethod(paymentMethod)}.'
              : 'Received ${_formatActivityAmount(amount)}.',
          amount: amount,
          paymentMethod: paymentMethod,
          dateTime: createdAt,
          invoiceId: invoiceId,
          invoiceNumber: invoiceNumber,
        ),
      );
    }

    // ==========================================================================
    // 3. EMI Payment Activities
    // ==========================================================================

    for (final payment in emiPayments) {
      final paymentDate = DateTime.tryParse(
        payment['payment_date'] as String? ??
            payment['created_at'] as String? ??
            '',
      );

      if (paymentDate == null) {
        continue;
      }

      final amount = (payment['amount'] as num?)?.toDouble() ?? 0;

      final paymentMethod = payment['payment_method'] as String?;

      final invoiceNumber = payment['invoice_number'] as String?;

      final invoiceId = payment['invoice_id'] as String?;

      activities.add(
        CustomerActivityModel(
          type: CustomerActivityType.emiPayment,
          title: 'EMI Payment',
          description: paymentMethod != null && paymentMethod.trim().isNotEmpty
              ? 'Received ${_formatActivityAmount(amount)} via ${_formatPaymentMethod(paymentMethod)}.'
              : 'Received ${_formatActivityAmount(amount)}.',
          amount: amount,
          paymentMethod: paymentMethod,
          dateTime: paymentDate,
          invoiceId: invoiceId,
          invoiceNumber: invoiceNumber,
        ),
      );
    }

    // ==========================================================================
    // Newest activity first
    // ==========================================================================

    activities.sort((a, b) => b.dateTime.compareTo(a.dateTime));

    // Keep the Customer Details page lightweight.
    return activities.take(10).toList();
  }

  // ============================================================================
  // Customer Invoice Payments
  // ============================================================================

  Future<List<Map<String, dynamic>>> _getCustomerInvoicePayments({
    required List<String> invoiceIds,
  }) async {
    if (invoiceIds.isEmpty) {
      return [];
    }

    final response = await _client
        .from('invoice_payments')
        .select('''
        id,
        invoice_id,
        customer_id,
        amount,
        payment_method,
        notes,
        created_at
      ''')
        .inFilter('invoice_id', invoiceIds)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => Map<String, dynamic>.from(json))
        .toList();
  }

  // ============================================================================
  // Customer EMI Payments
  // ============================================================================

  Future<List<Map<String, dynamic>>> _getCustomerEmiPayments({
    required String customerId,
    required String storeId,
  }) async {
    final response = await _client
        .from('emi_payments')
        .select('''
        id,
        emi_plan_id,
        customer_id,
        amount,
        payment_method,
        payment_date,
        notes,
        created_at,
        emi_plans (
          id,
          invoice_id,
          invoices (
            id,
            invoice_number
          )
        )
      ''')
        .eq('customer_id', customerId)
        .order('payment_date', ascending: false)
        .order('created_at', ascending: false);

    final payments = <Map<String, dynamic>>[];

    for (final rawPayment in response as List) {
      final payment = Map<String, dynamic>.from(rawPayment);

      final emiPlan = payment['emi_plans'] is Map
          ? Map<String, dynamic>.from(payment['emi_plans'] as Map)
          : null;

      final invoice = emiPlan?['invoices'] is Map
          ? Map<String, dynamic>.from(emiPlan!['invoices'] as Map)
          : null;

      payment['invoice_id'] = emiPlan?['invoice_id'] as String?;

      payment['invoice_number'] = invoice?['invoice_number'] as String?;

      // The nested relation is only needed for resolving invoice identity.
      payment.remove('emi_plans');

      payments.add(payment);
    }

    return payments;
  }

  // ============================================================================
  // Invoice Timeline Payment Detection
  // ============================================================================

  bool _isInvoicePaymentTimelineEvent({
    required String eventType,
    required String eventTitle,
  }) {
    final normalizedType = eventType.trim().toLowerCase();

    final normalizedTitle = eventTitle.trim().toLowerCase();

    // Payment events are represented by invoice_payments.
    //
    // Timeline payment events should therefore not be displayed separately,
    // otherwise the customer activity list will contain duplicates.

    const paymentEventTypes = {
      'payment_received',
      'invoice_payment',
      'payment',
    };

    if (paymentEventTypes.contains(normalizedType)) {
      return true;
    }

    // Defensive fallback for older timeline records whose event_type may
    // differ but whose title clearly identifies them as payment events.
    if (normalizedTitle.contains('payment received')) {
      return true;
    }

    return false;
  }

  String _formatActivityAmount(double amount) {
    final rounded = amount.round();

    final digits = rounded.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(',');
      }

      buffer.write(digits[i]);
    }

    return '₹${buffer.toString()}';
  }

  String _formatPaymentMethod(String paymentMethod) {
    final normalized = paymentMethod.trim();

    if (normalized.isEmpty) {
      return normalized;
    }

    if (normalized.toLowerCase() == 'upi') {
      return 'UPI';
    }

    if (normalized.toLowerCase() == 'cash') {
      return 'Cash';
    }

    if (normalized.toLowerCase() == 'card') {
      return 'Card';
    }

    return normalized;
  }
}
