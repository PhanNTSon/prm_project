import 'package:flutter/material.dart';
import '../../../../core/network/dio_client.dart';
import '../models/game_basic_model.dart';

/// Repository chịu trách nhiệm gọi API liên quan đến Game.
/// Nhận DioClient qua constructor (Dependency Injection).
class GameRepository {
  final DioClient _dioClient;

  GameRepository(this._dioClient);

  /// Tìm kiếm game theo từ khóa.
  /// API: GET /game/search?term={keyword}
  /// Trả về danh sách GameBasicModel, hoặc list rỗng nếu lỗi.
  Future<List<GameBasicModel>> searchGames(String term) async {
    try {
      final response = await _dioClient.get(
        '/game/search',
        queryParameters: {'term': term},
      );

      // Response là List<GameBasicDTO>
      if (response.data is List) {
        return (response.data as List)
            .map((json) => GameBasicModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Lỗi searchGames: $e');
      return [];
    }
  }
}
