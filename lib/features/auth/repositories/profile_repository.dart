import '../../../../core/network/dio_client.dart';
import '../models/profile_model.dart';

class ProfileRepository {
  final DioClient _dioClient;

  ProfileRepository(this._dioClient);

  Future<ProfileModel> getUserProfile(String userId) async {
    try {
      final response = await _dioClient.get('/user/profile/$userId');
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Không thể tải thông tin profile');
    }
  }

  Future<ProfileModel> updateProfile({
    required String userId,
    required String profileName,
    required String country,
    required String gender,
    required String dob,
    required String summary,
  }) async {
    try {
      final response = await _dioClient.put(
        '/user/profile/$userId/edit/info',
        data: {
          'profileName': profileName,
          'country': country,
          'gender': gender,
          'dob': dob,
          'summary': summary,
        },
      );
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Cập nhật profile thất bại');
    }
  }
}