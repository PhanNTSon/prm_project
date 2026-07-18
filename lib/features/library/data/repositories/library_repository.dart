import 'package:dio/dio.dart';
import 'package:prm_project/features/library/data/models/library_game.dart';
import 'package:prm_project/features/library/data/models/page_model.dart';

class LibraryRepository {
  Future<PageResponse<LibraryGame>> getLibrary({
    required int page,

    required int size,

    List<String>? sort,
  }) async {
    try {
      final response = await Dio().get(
        "/user/library",

        queryParameters: {
          "page": page,

          "size": size,

          if (sort != null) "sort": sort,
        },
      );

      final data = response.data;

      final games = (data["content"] as List).map((item) {
        final game = item["gameDetail"];

        return LibraryGame(
          gameId: game["gameId"],

          name: game["name"],

          price: (game["price"] as num).toDouble(),

          iconUrl: game["iconUrl"],

          publisherName: game["publisher"]["publisherName"],

          playtimeInMillis: item["playtimeInMillis"],

          lastTimePlayed: DateTime.tryParse(item["lastTimePlayed"] ?? ""),
        );
      }).toList();

      return PageResponse(
        content: games,

        totalPages: data["totalPages"],

        totalElements: data["totalElements"],

        page: data["number"],

        size: data["size"],

        last: data["last"],
      );
    } catch (_) {
      rethrow;
    }
  }
}
