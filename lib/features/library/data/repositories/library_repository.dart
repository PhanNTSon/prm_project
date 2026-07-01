import '../models/library_game.dart';

class LibraryRepository {
  Future<List<LibraryGame>> fetchOwnedGames() async {
    await Future.delayed(const Duration(seconds: 1));

    return const [
      LibraryGame(
        id: 1,
        title: "Cyberpunk 2077",
        imageUrl:
            "https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/1091500/header.jpg",
        playHours: 122.6,
        lastPlayed: "Today",
      ),

      LibraryGame(
        id: 2,
        title: "Elden Ring",
        imageUrl:
            "https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/1245620/header.jpg",
        playHours: 75.4,
        lastPlayed: "Yesterday",
      ),

      LibraryGame(
        id: 3,
        title: "Hades II",
        imageUrl:
            "https://shared.cloudflare.steamstatic.com/store_item_assets/steam/apps/1145350/header.jpg",
        playHours: 31.8,
        lastPlayed: "3 days ago",
      ),
    ];
  }
}
