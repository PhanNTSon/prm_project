import 'package:flutter/foundation.dart';

import '../../../../core/network/dio_client.dart';
import '../models/library_game.dart';
import '../models/page_model.dart';

class LibraryRepository {
  final DioClient _dioClient;

  LibraryRepository(this._dioClient);

  Future<PageResponse<LibraryGame>> getLibrary({
    required int page,
    required int size,
  }) async {
    final response = await _dioClient.get(
      "/user/library",
      queryParameters: {"page": page, "size": size},
    );

    final data = response.data;

    final List<LibraryGame> games = (data["content"] as List<dynamic>).map((
      libraryItem,
    ) {
      final game = libraryItem["gameDetail"] as Map<String, dynamic>;

      String imageUrl = "";

      // Ưu tiên iconUrl
      if (game["iconUrl"] != null && game["iconUrl"].toString().isNotEmpty) {
        imageUrl = game["iconUrl"];
      }

      // Nếu iconUrl rỗng thì lấy image_header
      if (imageUrl.isEmpty && game["media"] != null) {
        final mediaList = List<Map<String, dynamic>>.from(game["media"]);

        for (final media in mediaList) {
          if (media["type"] == "image_header") {
            imageUrl = media["url"] ?? "";
            break;
          }
        }

        if (imageUrl.isEmpty && mediaList.isNotEmpty) {
          imageUrl = mediaList.first["url"] ?? "";
        }
      }

      debugPrint("--------------------------------");
      debugPrint("Game: ${game["name"]}");
      debugPrint("Image: $imageUrl");

      return LibraryGame(
        gameId: (game["gameId"] as num).toInt(),
        name: game["name"] ?? "",
        price: (game["price"] as num).toDouble(),
        iconUrl: imageUrl,
        publisherName: (game["publisher"]?["publisherName"] ?? "") as String,
        playtimeInMillis:
            (libraryItem["playtimeInMillis"] as num?)?.toInt() ?? 0,
        lastTimePlayed: libraryItem["lastTimePlayed"] != null
            ? DateTime.tryParse(libraryItem["lastTimePlayed"].toString())
            : null,
      );
    }).toList();

    return PageResponse(
      content: games,
      totalPages: (data["totalPages"] as num).toInt(),
      totalElements: (data["totalElements"] as num).toInt(),
      page: (data["number"] as num).toInt(),
      size: (data["size"] as num).toInt(),
      last: data["last"] as bool,
    );
  }
}
