import 'package:flutter/material.dart';

import '../../library/data/models/library_game.dart';
import '../../library/data/repositories/library_repository.dart';

class LibraryProvider extends ChangeNotifier {
  final LibraryRepository repository;

  LibraryProvider(this.repository);

  bool isLoading = false;

  bool isError = false;

  bool isSuccess = false;

  String errorMessage = "";

  List<LibraryGame> games = [];

  Future<void> loadLibrary() async {
    isLoading = true;
    isError = false;

    notifyListeners();

    try {
      games = await repository.fetchOwnedGames();

      isSuccess = true;
    } catch (e) {
      isError = true;
      errorMessage = e.toString();
    }

    isLoading = false;

    notifyListeners();
  }
}
