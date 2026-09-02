import '../models/profile_data_model.dart';

abstract class ProfileRepository {
  Future<ProfileDataModel> getProfileData();
}