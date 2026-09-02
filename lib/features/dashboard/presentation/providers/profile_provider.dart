import 'package:flutter/foundation.dart';

import '../../data/models/profile_data_model.dart';
import '../../data/services/profile_service.dart';

class ProfileProvider extends ChangeNotifier {
  ProfileProvider({
    required ProfileService service,
  }) : _service = service;

  final ProfileService _service;

  ProfileDataModel? _profileData;

  bool _isLoading = false;
  String? _errorMessage;

  ProfileDataModel? get profileData => _profileData;

  bool get isLoading => _isLoading;

  bool get hasData => _profileData != null;

  bool get hasError => _errorMessage != null;

  String? get errorMessage => _errorMessage;

  Future<void> loadProfile() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _profileData = await _service.getProfileData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    try {
      _profileData = await _service.getProfileData();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    notifyListeners();
  }
}