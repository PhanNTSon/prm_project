class CartItemModel {
  final int gameId;
  final String gameName;
  final double price;
  final String? thumbnailUrl;

  const CartItemModel({
    required this.gameId,
    required this.gameName,
    required this.price,
    this.thumbnailUrl,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      gameId: json['gameId'] as int,
      gameName: json['gameName'] as String? ?? 'Unknown Game',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      thumbnailUrl: json['thumbnailUrl'] as String?,
    );
  }
}