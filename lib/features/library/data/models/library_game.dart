class LibraryGame {
  final int gameId;
  final String name;
  final double price;
  final String iconUrl;
  final String publisherName;
  final int playtimeInMillis;
  final DateTime? lastTimePlayed;

  const LibraryGame({
    required this.gameId,
    required this.name,
    required this.price,
    required this.iconUrl,
    required this.publisherName,
    required this.playtimeInMillis,
    this.lastTimePlayed,
  });

  double get playHours => playtimeInMillis / 1000 / 60 / 60;
}
