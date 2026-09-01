import '../models/dashboard_data_model.dart';
import '../repositories/dashboard_repository.dart';

class DashboardService {
  DashboardService({
    required DashboardRepository repository,
  }) : _repository = repository;

  final DashboardRepository _repository;

  Future<DashboardDataModel> getDashboardData() {
    return _repository.getDashboardData();
  }
}