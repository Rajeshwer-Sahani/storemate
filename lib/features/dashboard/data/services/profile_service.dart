import '../models/profile_data_model.dart';
import '../repositories/profile_repository.dart';

class ProfileService {
  ProfileService({
    required ProfileRepository repository,
  }) : _repository = repository;

  final ProfileRepository _repository;

  Future<ProfileDataModel> getProfileData() {
    return _repository.getProfileData();
  }
}