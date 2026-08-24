import 'package:flutter/foundation.dart';

import '../../data/models/emi_plan_model.dart';
import '../../data/requests/create_emi_plan_request.dart';
import '../../data/services/emi_service.dart';

class CreateEmiPlanController extends ChangeNotifier {
  CreateEmiPlanController({
    required EmiService service,
  }) : _service = service;

  final EmiService _service;

  // ===========================================================================
  // State
  // ===========================================================================

  bool _isLoading = false;

  EmiPlanModel? _createdPlan;

  String? _errorMessage;

  // ===========================================================================
  // Getters
  // ===========================================================================

  bool get isLoading => _isLoading;

  EmiPlanModel? get createdPlan => _createdPlan;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  bool get hasCreatedPlan => _createdPlan != null;

  // ===========================================================================
  // Create EMI Plan
  // ===========================================================================

  Future<EmiPlanModel?> createEmiPlan(
    CreateEmiPlanRequest request,
  ) async {
    _setLoading(true);

    _errorMessage = null;
    _createdPlan = null;

    try {
      final plan = await _service.createEmiPlan(request);

      _createdPlan = plan;

      return plan;
    } catch (e) {
      _errorMessage = _mapError(e);

      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ===========================================================================
  // State Helpers
  // ===========================================================================

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _createdPlan = null;
    _errorMessage = null;

    notifyListeners();
  }

  // ===========================================================================
  // Internal Helpers
  // ===========================================================================

  void _setLoading(bool value) {
    if (_isLoading == value) {
      return;
    }

    _isLoading = value;

    notifyListeners();
  }

  String _mapError(Object error) {
    if (error is FormatException) {
      return error.message;
    }

    return error.toString();
  }
}