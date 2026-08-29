import 'package:flutter/foundation.dart';

import '../../data/models/emi_payment_model.dart';
import '../../data/requests/record_emi_payment_request.dart';
import '../../data/services/emi_service.dart';

class RecordEmiPaymentController extends ChangeNotifier {
  RecordEmiPaymentController({required EmiService service})
    : _service = service;

  final EmiService _service;

  // ===========================================================================
  // State
  // ===========================================================================

  bool _isLoading = false;

  EmiPaymentModel? _recordedPayment;

  String? _errorMessage;

  // ===========================================================================
  // Getters
  // ===========================================================================

  bool get isLoading => _isLoading;

  EmiPaymentModel? get recordedPayment => _recordedPayment;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  bool get hasRecordedPayment => _recordedPayment != null;

  // ===========================================================================
  // Record Payment
  // ===========================================================================

  Future<EmiPaymentModel?> recordPayment(
    RecordEmiPaymentRequest request,
  ) async {
    _setLoading(true);

    _errorMessage = null;
    _recordedPayment = null;

    try {
      final payment = await _service.recordPayment(request);

      _recordedPayment = payment;

      return payment;
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
    _recordedPayment = null;
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
