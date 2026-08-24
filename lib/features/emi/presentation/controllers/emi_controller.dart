import 'package:flutter/foundation.dart';

import '../../data/models/emi_installment_model.dart';
import '../../data/models/emi_payment_model.dart';
import '../../data/models/emi_plan_model.dart';
import '../../data/requests/record_emi_payment_request.dart';
import '../../data/repositories/emi_repository.dart';

class EmiController extends ChangeNotifier {
  EmiController({
    required EmiRepository repository,
  }) : _repository = repository;

  final EmiRepository _repository;

  // ===========================================================================
  // EMI Plans
  // ===========================================================================

  List<EmiPlanModel> _emiPlans = [];

  List<EmiPlanModel> get emiPlans => List.unmodifiable(_emiPlans);

  EmiPlanModel? _selectedPlan;

  EmiPlanModel? get selectedPlan => _selectedPlan;

  // ===========================================================================
  // Installments
  // ===========================================================================

  List<EmiInstallmentModel> _installments = [];

  List<EmiInstallmentModel> get installments =>
      List.unmodifiable(_installments);

  // ===========================================================================
  // Payments
  // ===========================================================================

  List<EmiPaymentModel> _payments = [];

  List<EmiPaymentModel> get payments => List.unmodifiable(_payments);

  // ===========================================================================
  // Loading States
  // ===========================================================================

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  bool _isLoadingDetails = false;

  bool get isLoadingDetails => _isLoadingDetails;

  bool _isRecordingPayment = false;

  bool get isRecordingPayment => _isRecordingPayment;

  // ===========================================================================
  // Error State
  // ===========================================================================

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  // ===========================================================================
  // EMI Plans
  // ===========================================================================

  Future<void> loadEmiPlans() async {
    _setLoading(true);
    _clearError();

    try {
      _emiPlans = await _repository.getEmiPlans();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // EMI Plan Details
  // ===========================================================================

  Future<void> loadEmiPlanDetails(String emiPlanId) async {
    _setLoadingDetails(true);
    _clearError();

    try {
      final results = await Future.wait([
        _repository.getEmiPlanById(emiPlanId),
        _repository.getInstallments(emiPlanId),
        _repository.getPayments(emiPlanId),
      ]);

      _selectedPlan = results[0] as EmiPlanModel;
      _installments = results[1] as List<EmiInstallmentModel>;
      _payments = results[2] as List<EmiPaymentModel>;
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoadingDetails(false);
    }
  }

  // ===========================================================================
  // Installments
  // ===========================================================================

  Future<void> loadInstallments(String emiPlanId) async {
    _clearError();

    try {
      _installments = await _repository.getInstallments(emiPlanId);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
  }

  // ===========================================================================
  // Payments
  // ===========================================================================

  Future<void> loadPayments(String emiPlanId) async {
    _clearError();

    try {
      _payments = await _repository.getPayments(emiPlanId);
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    }
  }

  // ===========================================================================
  // Record EMI Payment
  // ===========================================================================

  Future<EmiPaymentModel?> recordPayment(
    RecordEmiPaymentRequest request,
  ) async {
    _setRecordingPayment(true);
    _clearError();

    try {
      final payment = await _repository.recordPayment(request);

      /*
       * The database RPC is authoritative for:
       * - payment creation
       * - installment allocation
       * - installment balances
       * - EMI plan balances
       * - EMI plan status
       *
       * Refresh the related data from the database after a successful
       * payment so the UI always reflects the authoritative state.
       */

      await loadEmiPlanDetails(request.emiPlanId);

      return payment;
    } catch (e) {
      _setError(_getErrorMessage(e));
      return null;
    } finally {
      _setRecordingPayment(false);
    }
  }

  // ===========================================================================
  // Refresh
  // ===========================================================================

  Future<void> refreshEmiPlan(String emiPlanId) async {
    await loadEmiPlanDetails(emiPlanId);
  }

  Future<void> refreshEmiPlans() async {
    await loadEmiPlans();
  }

  // ===========================================================================
  // Selection
  // ===========================================================================

  void clearSelectedPlan() {
    _selectedPlan = null;
    _installments = [];
    _payments = [];
    _clearError();
    notifyListeners();
  }

  // ===========================================================================
  // Error Handling
  // ===========================================================================

  void clearError() {
    _clearError();
  }

  // ===========================================================================
  // Internal State Helpers
  // ===========================================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setLoadingDetails(bool value) {
    _isLoadingDetails = value;
    notifyListeners();
  }

  void _setRecordingPayment(bool value) {
    _isRecordingPayment = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(Object error) {
    if (error is FormatException) {
      return error.message;
    }

    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }
}