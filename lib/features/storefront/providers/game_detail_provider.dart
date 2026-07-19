import 'package:flutter/material.dart';
import '../data/models/game_detail_model.dart';
import '../data/repositories/game_repository.dart';

enum GameDetailStatus { initial, loading, loaded, error }

/// Provider quản lý state cho màn hình Game Detail.
class GameDetailProvider extends ChangeNotifier {
  final GameRepository _repository;

  GameDetailProvider(this._repository);

  GameDetailModel? _game;
  GameDetailStatus _status = GameDetailStatus.initial;
  String? _errorMessage;

  GameDetailModel? get game => _game;
  GameDetailStatus get status => _status;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _status == GameDetailStatus.loading;
  bool get hasData => _game != null;

  Future<void> loadGame(int gameId) async {
    // Nếu đang load cùng game thì bỏ qua
    if (_status == GameDetailStatus.loading) return;
    if (_game != null && _game!.id == gameId) return;

    _status = GameDetailStatus.loading;
    _errorMessage = null;
    _game = null;
    notifyListeners();

    final result = await _repository.getGameDetail(gameId);

    if (result != null) {
      _game = result;
      _status = GameDetailStatus.loaded;
    } else {
      _status = GameDetailStatus.error;
      _errorMessage = 'Không tìm thấy thông tin game.';
    }
    notifyListeners();
  }

  void reset() {
    _game = null;
    _status = GameDetailStatus.initial;
    _errorMessage = null;
  }
}
