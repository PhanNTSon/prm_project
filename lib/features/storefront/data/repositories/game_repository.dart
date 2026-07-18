import 'package:flutter/material.dart';
import '../../../../core/network/dio_client.dart';
import '../models/game_basic_model.dart';
import '../models/category_model.dart';

/// Wrapper chứa kết quả phân trang từ backend (Spring Page object).
class GamePage {
  final List<GameBasicModel> games;
  final int currentPage;
  final int totalPages;
  final int totalElements;

  GamePage({
    required this.games,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
  });
}

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

  /// Lấy danh sách game có phân trang, sắp xếp theo tên (A-Z).
  /// API: GET /game/?page={page}&size={size}&sort=name&dir=asc
  /// Trả về GamePage chứa list game và thông tin phân trang.
  Future<GamePage> getGamesPaged({
    int page = 0,
    int size = 20,
    String sort = 'name',
    String dir = 'asc',
  }) async {
    try {
      final response = await _dioClient.get(
        '/game',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
          'dir': dir,
        },
      );

      // === DEBUG: In ra JSON thực tế backend trả về ===
      debugPrint('=== [GameRepository] Raw response type: ${response.data.runtimeType}');
      debugPrint('=== [GameRepository] Raw response data: ${response.data}');

      final data = response.data as Map<String, dynamic>;
      debugPrint('=== [GameRepository] Keys in response: ${data.keys.toList()}');
      debugPrint('=== [GameRepository] content value: ${data['content']}');
      debugPrint('=== [GameRepository] totalPages: ${data['totalPages']}');
      debugPrint('=== [GameRepository] number: ${data['number']}');

      // Lấy list game từ key 'content'
      final rawContent = data['content'];
      if (rawContent == null) {
        debugPrint('=== [GameRepository] WARNING: content is null! Full data: $data');
        return GamePage(games: [], currentPage: 0, totalPages: 0, totalElements: 0);
      }

      final List<GameBasicModel> games = (rawContent as List)
          .map((json) => GameBasicModel.fromJson(json as Map<String, dynamic>))
          .toList();

      debugPrint('=== [GameRepository] Parsed ${games.length} games');

      return GamePage(
        games: games,
        currentPage: data['number'] ?? 0,
        totalPages: data['totalPages'] ?? 1,
        totalElements: data['totalElements'] ?? 0,
      );
    } catch (e) {
      debugPrint('Lỗi getGamesPaged: $e');
      // Trả về trang rỗng nếu lỗi
      return GamePage(games: [], currentPage: 0, totalPages: 0, totalElements: 0);
    }
  }

  /// Lấy ngẫu nhiên [count] game để hiển thị ở phần Featured.
  /// API: GET /game/random?count={count}
  /// Nếu backend chưa có endpoint này, dùng getGamesPaged rồi shuffle phía client.
  Future<List<GameBasicModel>> getRandomFeaturedGames({int count = 5}) async {
    try {
      // Thử gọi endpoint random nếu backend có
      final response = await _dioClient.get(
        '/game/random',
        queryParameters: {'count': count},
      );
      if (response.data is List) {
        return (response.data as List)
            .map((json) => GameBasicModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Lỗi getRandomFeaturedGames (thử fallback): $e');
      // Fallback: lấy trang đầu rồi shuffle
      try {
        final page = await getGamesPaged(page: 0, size: 50);
        final list = List<GameBasicModel>.from(page.games)..shuffle();
        return list.take(count).toList();
      } catch (e2) {
        debugPrint('Lỗi fallback getRandomFeaturedGames: $e2');
        return [];
      }
    }
  }

  /// Lấy toàn bộ danh mục (category) của game.
  /// API: GET /category (hoặc /game/categories)
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await _dioClient.get('/category');
      if (response.data is List) {
        return (response.data as List)
            .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      debugPrint('Lỗi getAllCategories: $e');
      return [];
    }
  }
}

