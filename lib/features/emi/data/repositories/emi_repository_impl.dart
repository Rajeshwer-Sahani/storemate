import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/emi_installment_model.dart';
import '../models/emi_payment_model.dart';
import '../models/emi_plan_model.dart';
import '../requests/create_emi_plan_request.dart';
import '../requests/record_emi_payment_request.dart';
import 'emi_repository.dart';

class EmiRepositoryImpl implements EmiRepository {
  EmiRepositoryImpl({
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? Supabase.instance.client;

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

    return (response as List)
        .map(
          (json) => EmiPlanModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  @override
  Future<EmiPlanModel> getEmiPlanById(
    String emiPlanId,
  ) async {
    final response = await _supabase
        .from('emi_plans')
        .select()
        .eq('id', emiPlanId)
        .single();

    return EmiPlanModel.fromJson(
      Map<String, dynamic>.from(response),
    );
  }

  // ===========================================================================
  // Create EMI Plan
  // ===========================================================================

  @override
  Future<EmiPlanModel> createEmiPlan(
    CreateEmiPlanRequest request,
  ) async {
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
     *
     * Therefore, fetch the complete EMI plan row after
     * the RPC succeeds instead of constructing the model
     * from Flutter-side calculations.
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

    final planResponse = await _supabase
        .from('emi_plans')
        .select()
        .eq('id', emiPlanId)
        .single();

    return EmiPlanModel.fromJson(
      Map<String, dynamic>.from(planResponse),
    );
  }

  // ===========================================================================
  // Installments
  // ===========================================================================

  @override
  Future<List<EmiInstallmentModel>> getInstallments(
    String emiPlanId,
  ) async {
    final response = await _supabase
        .from('emi_installments')
        .select()
        .eq('emi_plan_id', emiPlanId)
        .order('installment_number', ascending: true);

    return (response as List)
        .map(
          (json) => EmiInstallmentModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // ===========================================================================
  // Payments
  // ===========================================================================

  @override
  Future<List<EmiPaymentModel>> getPayments(
    String emiPlanId,
  ) async {
    final response = await _supabase
        .from('emi_payments')
        .select()
        .eq('emi_plan_id', emiPlanId)
        .order('payment_date', ascending: false)
        .order('created_at', ascending: false);

    return (response as List)
        .map(
          (json) => EmiPaymentModel.fromJson(
            Map<String, dynamic>.from(json),
          ),
        )
        .toList();
  }

  // ===========================================================================
  // Record Payment
  // ===========================================================================

  @override
  Future<EmiPaymentModel> recordPayment(
    RecordEmiPaymentRequest request,
  ) async {
    final response = await _supabase.rpc(
      'record_emi_payment',
      params: request.toRpcParams(),
    );

    if (response is! List || response.isEmpty) {
      throw const FormatException(
        'Invalid response received from record_emi_payment RPC.',
      );
    }

    final result = Map<String, dynamic>.from(
      response.first as Map,
    );

    /*
     * The RPC returns payment_id and financial summary fields,
     * while emi_payments contains the complete payment record.
     *
     * Fetch the authoritative payment row after the RPC succeeds.
     */

    final paymentId = result['payment_id'] as String?;

    if (paymentId == null || paymentId.isEmpty) {
      throw const FormatException(
        'Payment ID was not returned by record_emi_payment RPC.',
      );
    }

    final paymentResponse = await _supabase
        .from('emi_payments')
        .select()
        .eq('id', paymentId)
        .single();

    return EmiPaymentModel.fromJson(
      Map<String, dynamic>.from(paymentResponse),
    );
  }
}