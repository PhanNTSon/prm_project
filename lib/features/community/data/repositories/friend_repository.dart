import 'package:prm_project/core/network/dio_client.dart';
import 'package:prm_project/features/community/data/models/friend_model.dart';
import 'package:prm_project/features/community/data/models/user_search_model.dart';
import 'package:prm_project/features/community/data/models/friend_invite_model.dart';
import 'package:dio/dio.dart';

class FriendRepository {
  final DioClient _dioClient;

  FriendRepository(this._dioClient);

  Future<List<FriendModel>> getFriends() async {
    try {
      final response = await _dioClient.get('/user/friends');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => FriendModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load friends: $e');
    }
  }

  Future<UserSearchModel?> findUser(String userId) async {
    try {
      final response = await _dioClient.get('/user/find/$userId');
      if (response.statusCode == 200 && response.data != null && response.data.toString().isNotEmpty) {
        // Có thể BE trả về rỗng nếu không thấy hoặc 404
        return UserSearchModel.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw Exception('Failed to find user: $e');
    } catch (e) {
      return null;
    }
  }

  Future<bool> sendInvite(String friendId) async {
    try {
      final response = await _dioClient.post('/user/sendinvite/$friendId');
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<List<FriendInviteModel>> getReceivedInvites() async {
    try {
      final response = await _dioClient.get('/user/pendinginvite/receive');
      if (response.statusCode == 200 && response.data['data'] != null) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => FriendInviteModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> acceptInvite(String friendId) async {
    try {
      final response = await _dioClient.patch('/user/acceptinvite/$friendId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> declineInvite(String friendId) async {
    try {
      final response = await _dioClient.delete('/user/declineinvite/$friendId');
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
