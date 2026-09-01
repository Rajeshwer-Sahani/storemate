import 'package:flutter/foundation.dart';

import 'package:storemate/features/dashboard/data/models/dashboard_data_model.dart';
import 'package:storemate/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:storemate/features/dashboard/data/services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider({required DashboardService service}) : _service = service;

  final DashboardService _service;

  // ===========================================================================
  // State
  // ===========================================================================

  DashboardDataModel? _dashboardData;

  bool _isLoading = false;

  String? _errorMessage;

  // ===========================================================================
  // Getters
  // ===========================================================================

  DashboardDataModel? get dashboardData => _dashboardData;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasData => _dashboardData != null;

  bool get hasError =>
      _errorMessage != null && _errorMessage!.trim().isNotEmpty;

  // ===========================================================================
  // Load Dashboard
  // ===========================================================================

  Future<void> loadDashboard() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _dashboardData = await _service.getDashboardData();
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ===========================================================================
  // Refresh Dashboard
  // ===========================================================================

  Future<void> refreshDashboard() async {
    _errorMessage = null;

    notifyListeners();

    try {
      _dashboardData = await _service.getDashboardData();
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
    } finally {
      notifyListeners();
    }
  }

  // ===========================================================================
  // Error Handling
  // ===========================================================================

  String _getErrorMessage(Object error) {
    if (error is DashboardException) {
      return error.message;
    }

    return 'Failed to load dashboard data. Please try again.';
  }
}
