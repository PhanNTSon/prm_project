import 'package:flutter/material.dart';
import 'package:prm_project/features/library/data/models/library_game.dart';
import 'package:prm_project/features/library/data/repositories/library_repository.dart';

class LibraryProvider extends ChangeNotifier {
  final LibraryRepository repository;

  LibraryProvider(this.repository);

  List<LibraryGame> games = [];

  bool isLoading = false;

  bool isError = false;

  bool isSuccess = false;

  int currentPage = 0;

  final int pageSize = 20;

  int totalPages = 0;

  bool hasMore = true;

  String sort = "name,asc";

  Future<void> loadLibrary({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      currentPage = 0;

      games.clear();

      hasMore = true;
    }

    if (!hasMore) return;

    isLoading = true;

    notifyListeners();

    try {
      final page = await repository.getLibrary(
        page: currentPage,

        size: pageSize,

        sort: [sort],
      );

      games.addAll(page.content);

      totalPages = page.totalPages;

      hasMore = !page.last;

      currentPage++;

      isSuccess = true;

      isError = false;
    } catch (e) {
      isError = true;
    }

    isLoading = false;

    notifyListeners();
  }

  List<LibraryGame> get sortedGames {
    final list = [...games];

    switch (sort) {
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
    }

    return list;
  }
}
