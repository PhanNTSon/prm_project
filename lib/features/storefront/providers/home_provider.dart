import 'package:flutter/material.dart';
import '../data/models/game_basic_model.dart';
import '../data/models/category_model.dart';
import '../data/repositories/game_repository.dart';

/// Provider quản lý state cho HomeScreen.
/// Chịu trách nhiệm load featured games (random 5 game) và toàn bộ categories.
class HomeProvider extends ChangeNotifier {
  final GameRepository _repository;

  HomeProvider(this._repository);

  // === STATE ===
  List<GameBasicModel> _featuredGames = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  // === GETTERS ===
  List<GameBasicModel> get featuredGames => _featuredGames;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get hasFeatured => _featuredGames.isNotEmpty;
  bool get hasCategories => _categories.isNotEmpty;

  /// Load cả featured games và categories song song
  Future<void> loadHomeData() async {
    if (_isLoading) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getRandomFeaturedGames(count: 5),
        _repository.getAllCategories(),
      ]);

      final allCategories = results[1] as List<CategoryModel>;
      allCategories.shuffle();
      _categories = allCategories.take(5).toList();
    } catch (e) {
      _errorMessage = 'Không thể tải dữ liệu trang chủ.';
      debugPrint('HomeProvider loadHomeData error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Refresh featured games (random lại)
  Future<void> refreshFeatured() async {
    try {
      final games = await _repository.getRandomFeaturedGames(count: 5);
      _featuredGames = games;
      notifyListeners();
    } catch (e) {
      debugPrint('HomeProvider refreshFeatured error: $e');
    }
  }
}
