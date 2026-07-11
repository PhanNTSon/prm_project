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
      gameId: json['id'] as int,                           // BE trả về 'id'
      gameName: json['title'] as String? ?? 'Unknown Game', // BE trả về 'title'
      price: (json['price'] as num?)?.toDouble() ?? 0,
      thumbnailUrl: json['imageUrl'] as String?,            // BE trả về 'imageUrl'
    );
  }
}