import 'package:flutter/material.dart';
import '../data/models/game_basic_model.dart';
import '../data/repositories/game_repository.dart';

/// Provider quản lý state cho màn hình "Tất cả Game".
/// Hỗ trợ phân trang và sắp xếp theo tên A-Z.
class GameListProvider extends ChangeNotifier {
  final GameRepository _repository;

  GameListProvider(this._repository);

  // === STATE ===
  List<GameBasicModel> _games = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 0;
  int _totalPages = 1;
  int _totalElements = 0;

  // === GETTERS ===
  List<GameBasicModel> get games => _games;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalElements => _totalElements;

  /// Có trang trước không
  bool get hasPreviousPage => _currentPage > 0;

  /// Có trang tiếp theo không
  bool get hasNextPage => _currentPage < _totalPages - 1;

  /// Tải trang đầu tiên (gọi khi vào màn hình lần đầu)
  Future<void> loadFirstPage() async {
    _currentPage = 0;
    await _loadPage(0);
  }

  /// Chuyển sang trang tiếp theo
  Future<void> loadNextPage() async {
    if (!hasNextPage || _isLoading) return;
    await _loadPage(_currentPage + 1);
  }

  /// Chuyển về trang trước
  Future<void> loadPreviousPage() async {
    if (!hasPreviousPage || _isLoading) return;
    await _loadPage(_currentPage - 1);
  }

  /// Tải một trang cụ thể
  Future<void> loadPage(int page) async {
    if (_isLoading) return;
    await _loadPage(page);
  }

  /// Hàm thực sự gọi API
  Future<void> _loadPage(int page) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getGamesPaged(
        page: page,
        size: 20,
        sort: 'name', // Sắp xếp theo tên A-Z
        dir: 'asc',
      );

      _games = result.games;
      _currentPage = result.currentPage;
      _totalPages = result.totalPages;
      _totalElements = result.totalElements;
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách game. Vui lòng thử lại.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
