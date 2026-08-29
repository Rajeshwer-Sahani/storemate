import 'package:storemate/features/emi/data/models/record_emi_payment_response.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/emi_installment_model.dart';
import '../models/emi_payment_model.dart';
import '../models/emi_plan_model.dart';
import '../requests/create_emi_plan_request.dart';
import '../requests/record_emi_payment_request.dart';
import 'emi_repository.dart';

class EmiRepositoryImpl implements EmiRepository {
  EmiRepositoryImpl({SupabaseClient? supabase})
    : _supabase = supabase ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  // ===========================================================================
  // EMI Plans
  // ===========================================================================

  @override
  Future<List<EmiPlanModel>> getEmiPlans() async {
    final response = await _supabase
        .from('emi_plans')
        .select()
        .order('created_at', ascending: false);

    final rows = (response as List)
        .map((json) => Map<String, dynamic>.from(json))
        .toList();

    return _buildPlansWithIdentity(rows);
  }

  @override
  Future<EmiPlanModel> getEmiPlanById(String emiPlanId) async {
    final response = await _supabase
        .from('emi_plans')
        .select()
        .eq('id', emiPlanId)
        .single();

    final row = Map<String, dynamic>.from(response);

    final plans = await _buildPlansWithIdentity([row]);

    if (plans.isEmpty) {
      throw const FormatException(
        'Unable to load EMI plan identity information.',
      );
    }

    return plans.first;
  }

  // ===========================================================================
  // EMI Plan Identity
  // ===========================================================================

  /// Enriches EMI plan rows with human-readable customer and invoice
  /// information.
  ///
  /// We intentionally keep:
  ///
  /// customerId / invoiceId
  ///
  /// as the authoritative database relationships while adding:
  ///
  /// customerName / customerPhone / invoiceNumber
  ///
  /// for UI identification.
  ///
  /// Customer and invoice data are fetched in bulk so that 100 EMI plans
  /// do not result in 200 additional database requests.
  Future<List<EmiPlanModel>> _buildPlansWithIdentity(
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) {
      return [];
    }

    // -------------------------------------------------------------------------
    // Collect relationship IDs
    // -------------------------------------------------------------------------

    final customerIds = rows
        .map((row) => row['customer_id'])
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    final invoiceIds = rows
        .map((row) => row['invoice_id'])
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet()
        .toList();

    // -------------------------------------------------------------------------
    // Fetch related records in parallel
    // -------------------------------------------------------------------------

    final results = await Future.wait([
      _fetchCustomers(customerIds),
      _fetchInvoices(invoiceIds),
    ]);

    final customers = results[0] as Map<String, Map<String, dynamic>>;

    final invoices = results[1] as Map<String, Map<String, dynamic>>;

    // -------------------------------------------------------------------------
    // Build enriched models
    // -------------------------------------------------------------------------

    return rows.map((row) {
      final customerId = row['customer_id'] as String;
      final invoiceId = row['invoice_id'] as String;

      final customer = customers[customerId];
      final invoice = invoices[invoiceId];

      final enrichedRow = Map<String, dynamic>.from(row);

      // -----------------------------------------------------------------------
      // Customer identity
      // -----------------------------------------------------------------------

      enrichedRow['customer_name'] = customer?['full_name'] as String?;

      enrichedRow['customer_phone'] = customer?['phone_number'] as String?;

      // -----------------------------------------------------------------------
      // Invoice identity
      // -----------------------------------------------------------------------

      enrichedRow['invoice_number'] = invoice?['invoice_number'] as String?;

      return EmiPlanModel.fromJson(enrichedRow);
    }).toList();
  }

  // ===========================================================================
  // Customers
  // ===========================================================================

  Future<Map<String, Map<String, dynamic>>> _fetchCustomers(
    List<String> customerIds,
  ) async {
    if (customerIds.isEmpty) {
      return {};
    }

    final response = await _supabase
        .from('customers')
        .select('id, full_name, phone_number')
        .inFilter('id', customerIds);

    final rows = (response as List)
        .map((json) => Map<String, dynamic>.from(json))
        .toList();

    return {for (final customer in rows) customer['id'] as String: customer};
  }

  // ===========================================================================
  // Invoices
  // ===========================================================================

  Future<Map<String, Map<String, dynamic>>> _fetchInvoices(
    List<String> invoiceIds,
  ) async {
    if (invoiceIds.isEmpty) {
      return {};
    }

    final response = await _supabase
        .from('invoices')
        .select('id, invoice_number')
        .inFilter('id', invoiceIds);

    final rows = (response as List)
        .map((json) => Map<String, dynamic>.from(json))
        .toList();

    return {for (final invoice in rows) invoice['id'] as String: invoice};
  }

  // ===========================================================================
  // Create EMI Plan
  // ===========================================================================

  @override
  Future<EmiPlanModel> createEmiPlan(CreateEmiPlanRequest request) async {
    final response = await _supabase.rpc(
      'create_emi_plan',
      params: request.toRpcParams(),
    );

    /*
     * The create_emi_plan RPC returns the ID of the newly
     * created EMI plan.
     *
     * The database remains authoritative for:
     * - financed amount
     * - total payable amount
     * - installment schedule
     * - installment rounding
     * - initial paid/remaining amounts
     * - plan status
     */

    if (response == null) {
      throw const FormatException(
        'EMI plan creation failed. No plan ID was returned.',
      );
    }

    if (response is! String || response.isEmpty) {
      throw const FormatException(
        'Invalid response received from create_emi_plan RPC.',
      );
    }

    final emiPlanId = response;

    /*
     * Use getEmiPlanById instead of directly constructing the model.
     *
     * This ensures the newly created plan also receives:
     * - customer name
     * - customer phone
     * - invoice number
     */
    return getEmiPlanById(emiPlanId);
  }

  // ===========================================================================
  // Installments
  // ===========================================================================

  @override
  Future<List<EmiInstallmentModel>> getInstallments(String emiPlanId) async {
    final response = await _supabase
        .from('emi_installments')
        .select()
        .eq('emi_plan_id', emiPlanId)
        .order('installment_number', ascending: true);

    return (response as List)
        .map(
          (json) =>
              EmiInstallmentModel.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();
  }

  // ===========================================================================
  // Payments
  // ===========================================================================

  @override
  Future<List<EmiPaymentModel>> getPayments(String emiPlanId) async {
    final response = await _supabase
        .from('emi_payments')
        .select()
        .eq('emi_plan_id', emiPlanId)
        .order('payment_date', ascending: false)
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (json) => EmiPaymentModel.fromJson(Map<String, dynamic>.from(json)),
        )
        .toList();
  }

  // ===========================================================================
  // Record Payment
  // ===========================================================================

  @override
  Future<EmiPaymentModel> recordPayment(RecordEmiPaymentRequest request) async {
    final response = await _supabase.rpc(
      'record_emi_payment',
      params: request.toRpcParams(),
    );

    if (response is! List || response.isEmpty) {
      throw const FormatException(
        'Invalid response received from record_emi_payment RPC.',
      );
    }

    final rawResult = response.first;

    if (rawResult is! Map) {
      throw const FormatException(
        'Invalid result received from record_emi_payment RPC.',
      );
    }

    final result = Map<String, dynamic>.from(rawResult);

    final rpcResult = RecordEmiPaymentResponse.fromJson(result);

    final paymentResponse = await _supabase
        .from('emi_payments')
        .select()
        .eq('id', rpcResult.paymentId)
        .single();

    return EmiPaymentModel.fromJson(Map<String, dynamic>.from(paymentResponse));
  }
}
