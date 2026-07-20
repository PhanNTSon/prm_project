import 'package:flutter/foundation.dart';

import '../../library/data/models/library_game.dart';
import '../../library/data/models/page_model.dart';
import '../../library/data/repositories/library_repository.dart';

class LibraryProvider extends ChangeNotifier {
  final LibraryRepository _repository;

  LibraryProvider(this._repository);

  // =========================
  // Data
  // =========================

  final List<LibraryGame> _games = [];

  List<LibraryGame> get games => List.unmodifiable(_games);

  // =========================
  // State
  // =========================

  bool _isLoading = false;
  bool _isError = false;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;

  bool get isError => _isError;

  bool get isSuccess => _isSuccess;

  // =========================
  // Pagination
  // =========================

  int _currentPage = 0;

  final int _pageSize = 20;

  int _totalPages = 0;

  bool _hasMore = true;

  int get currentPage => _currentPage;

  int get totalPages => _totalPages;

  bool get hasMore => _hasMore;

  // =========================
  // Sort
  // =========================

  String _sort = "az";

  String get sort => _sort;

  // =========================
  // Load Library
  // =========================

  Future<void> loadLibrary({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _games.clear();
      _currentPage = 0;
      _totalPages = 0;
      _hasMore = true;
      _isError = false;
      _isSuccess = false;
    }

    if (!_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final PageResponse<LibraryGame> page = await _repository.getLibrary(
        page: _currentPage,
        size: _pageSize,
      );

      _games.addAll(page.content);

      _currentPage++;

      _totalPages = page.totalPages;

      _hasMore = !page.last;

      _isSuccess = true;
      _isError = false;

      debugPrint('''
========== Library ==========
Loaded page : $_currentPage
Games       : ${_games.length}
Total Pages : $_totalPages
Has More    : $_hasMore
=============================
''');
    } catch (e, stackTrace) {
      _isError = true;
      _isSuccess = false;

      debugPrint("LibraryProvider Error: $e");
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshLibrary() async {
    await loadLibrary(refresh: true);
  }

  // =========================
  // Sort (Local Only)
  // =========================

  void changeSort(String value) {
    if (_sort == value) return;

    _sort = value;

    notifyListeners();
  }

  List<LibraryGame> get sortedGames {
    final list = [..._games];

    switch (_sort) {
      case "az":
        list.sort((a, b) => a.name.compareTo(b.name));
        break;

      case "za":
        list.sort((a, b) => b.name.compareTo(a.name));
        break;

      case "priceLowHigh":
        list.sort((a, b) => a.price.compareTo(b.price));
        break;

      case "priceHighLow":
        list.sort((a, b) => b.price.compareTo(a.price));
        break;

      default:
        break;
    }

    return list;
  }

  // =========================
  // Search
  // =========================

  List<LibraryGame> searchGames(String keyword) {
    final query = keyword.trim().toLowerCase();

    if (query.isEmpty) {
      return sortedGames;
    }

    return sortedGames.where((game) {
      return game.name.toLowerCase().contains(query) ||
          game.publisherName.toLowerCase().contains(query);
    }).toList();
  }

  // =========================
  // Infinite Scroll
  // =========================

  Future<void> loadNextPage() async {
    if (_isLoading || !_hasMore) return;

    await loadLibrary();
  }

  // =========================
  // Clear
  // =========================

  void clear() {
    _games.clear();

    _currentPage = 0;
    _totalPages = 0;

    _hasMore = true;

    _isLoading = false;
    _isError = false;
    _isSuccess = false;

    _sort = "az";

    notifyListeners();
  }
}
