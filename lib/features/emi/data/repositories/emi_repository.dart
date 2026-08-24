import 'package:storemate/features/emi/data/requests/create_emi_plan_request.dart';
import 'package:storemate/features/emi/data/requests/record_emi_payment_request.dart';

import '../models/emi_installment_model.dart';
import '../models/emi_payment_model.dart';
import '../models/emi_plan_model.dart';

abstract class EmiRepository {
  // ===========================================================================
  // EMI Plans
  // ===========================================================================

  /// Fetch all EMI plans belonging to the current user's store.
  Future<List<EmiPlanModel>> getEmiPlans();

  /// Fetch a single EMI plan by its ID.
  Future<EmiPlanModel> getEmiPlanById(String emiPlanId);

  /// Create a new EMI plan through the authoritative database RPC.
  ///
  /// The database handles:
  /// - invoice validation
  /// - financed amount calculation
  /// - EMI plan creation
  /// - installment generation
  /// - installment amount calculation
  /// - final installment rounding
  /// - transaction atomicity
  Future<EmiPlanModel> createEmiPlan(
    CreateEmiPlanRequest request,
  );

  // ===========================================================================
  // Installments
  // ===========================================================================

  /// Fetch all installments belonging to an EMI plan.
  Future<List<EmiInstallmentModel>> getInstallments(
    String emiPlanId,
  );

  // ===========================================================================
  // Payments
  // ===========================================================================

  /// Fetch all payments belonging to an EMI plan.
  Future<List<EmiPaymentModel>> getPayments(
    String emiPlanId,
  );

  /// Record an EMI payment through the authoritative database RPC.
  ///
  /// The database handles:
  /// - payment creation
  /// - installment allocation
  /// - installment balance updates
  /// - EMI plan balance updates
  /// - EMI plan status
  Future<EmiPaymentModel> recordPayment(
    RecordEmiPaymentRequest request,
  );
}