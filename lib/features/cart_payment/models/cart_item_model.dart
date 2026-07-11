class CartItemModel {
  final int gameId;
  final String gameName;
  final double price;
  final double discountPrice;
  final double originalPrice;
  final String? thumbnailUrl;

  const CartItemModel({
    required this.gameId,
    required this.gameName,
    required this.price,
    this.discountPrice = 0,
    this.originalPrice = 0,
    this.thumbnailUrl,
  });

  bool get hasDiscount => originalPrice > price;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final price = (json['price'] as num?)?.toDouble() ?? 0;
    final originalPrice = (json['originalPrice'] as num?)?.toDouble() ?? price;
    return CartItemModel(
      gameId: json['id'] as int,
      gameName: json['title'] as String? ?? 'Unknown Game',
      price: price,
      discountPrice: (json['discountPrice'] as num?)?.toDouble() ?? 0,
      originalPrice: originalPrice,
      thumbnailUrl: json['imageUrl'] as String?,
    );
  }
}
