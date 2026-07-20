import 'package:dio/dio.dart';
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
    List<String>? sort,
  }) async {
    try {
      final response = await _dioClient.get(
        "/user/library",
        queryParameters: {
          "page": page,
          "size": size,
          if (sort != null && sort.isNotEmpty) "sort": sort,
        },
      );
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Response: ${response.data}");

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      debugPrint(data.toString());
      final List<dynamic> content = (data["content"] as List<dynamic>?) ?? [];

      final List<LibraryGame> games = content.map((item) {
        final Map<String, dynamic> libraryItem = item as Map<String, dynamic>;

        final Map<String, dynamic> game =
            libraryItem["gameDetail"] as Map<String, dynamic>;

        return LibraryGame(
          gameId: game["gameId"] as int,
          name: game["name"] as String,
          price: (game["price"] as num).toDouble(),
          iconUrl: game["iconUrl"] as String? ?? "",
          publisherName:
              (game["publisher"] as Map<String, dynamic>)["publisherName"]
                  as String? ??
              "",
          playtimeInMillis:
              (libraryItem["playtimeInMillis"] as num?)?.toInt() ?? 0,
          lastTimePlayed: libraryItem["lastTimePlayed"] != null
              ? DateTime.tryParse(libraryItem["lastTimePlayed"].toString())
              : null,
        );
      }).toList();

      debugPrint("Library API loaded ${games.length} games.");

      return PageResponse<LibraryGame>(
        content: games,
        totalPages: data["totalPages"] as int? ?? 0,
        totalElements: data["totalElements"] as int? ?? 0,
        page: data["number"] as int? ?? page,
        size: data["size"] as int? ?? size,
        last: data["last"] as bool? ?? true,
      );
    } on DioException catch (e) {
      debugPrint("Status: ${e.response?.statusCode}");
      debugPrint("Body: ${e.response?.data}");

      rethrow;
    } catch (e, stackTrace) {
      debugPrint("LibraryRepository Error: $e");
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}
