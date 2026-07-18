import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/game_basic_model.dart';
import '../data/repositories/game_repository.dart';

/// Provider quản lý state cho tính năng Tìm kiếm Game.
/// Dùng ChangeNotifier để UI tự động rebuild khi state thay đổi.
class GameSearchProvider extends ChangeNotifier {
  final GameRepository _repository;

  GameSearchProvider(this._repository);

  // === STATE ===
  List<GameBasicModel> _searchResults = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentTerm = '';
  Timer? _debounceTimer;

  // === GETTERS ===
  List<GameBasicModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentTerm => _currentTerm;

  /// Có kết quả tìm kiếm hay không
  bool get hasResults => _searchResults.isNotEmpty;

  /// User đã gõ gì chưa
  bool get hasSearched => _currentTerm.isNotEmpty;

  /// Tìm kiếm game với debounce 500ms.
  /// Tránh gọi API liên tục mỗi lần user gõ 1 ký tự.
  void search(String term) {
    _currentTerm = term;

    // Hủy timer cũ nếu user vẫn đang gõ
    _debounceTimer?.cancel();

    // Nếu user xóa hết text → reset ngay
    if (term.trim().isEmpty) {
      _searchResults = [];
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Đợi 500ms sau khi user ngừng gõ mới gọi API
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(term.trim());
    });
  }

  /// Gọi API tìm kiếm thực sự
  Future<void> _performSearch(String term) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _repository.searchGames(term);
      _searchResults = results;
    } catch (e) {
      _errorMessage = 'Không thể tìm kiếm. Vui lòng thử lại.';
      _searchResults = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Xóa kết quả tìm kiếm
  void clearSearch() {
    _debounceTimer?.cancel();
    _searchResults = [];
    _currentTerm = '';
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
