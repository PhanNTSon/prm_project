import 'tag_model.dart';

/// Model ánh xạ từ GameBasicDTO của backend.
/// Dùng cho danh sách game trong kết quả tìm kiếm, browse, filter.
class GameBasicModel {
  final int id;
  final String title;
  final String? imageUrl;
  final double price;
  final double? discountPrice;
  final double? originalPrice;
  final List<TagModel> tags;

  GameBasicModel({
    required this.id,
    required this.title,
    this.imageUrl,
    required this.price,
    this.discountPrice,
    this.originalPrice,
    this.tags = const [],
  });

  factory GameBasicModel.fromJson(Map<String, dynamic> json) {
    // Parse danh sách tags nếu có
    List<TagModel> parsedTags = [];
    if (json['tags'] != null && json['tags'] is List) {
      parsedTags = (json['tags'] as List)
          .map((tag) => TagModel.fromJson(tag as Map<String, dynamic>))
          .toList();
    }

    return GameBasicModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      imageUrl: json['imageUrl'],
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discountPrice']?.toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      tags: parsedTags,
    );
  }

  /// Kiểm tra game có đang giảm giá không
  bool get isOnSale => discountPrice != null && discountPrice! < price;

  /// Giá hiển thị (ưu tiên giá giảm)
  double get displayPrice => discountPrice ?? price;
}
