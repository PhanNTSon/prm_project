import 'tag_model.dart';

/// Model chi tiết game từ backend (GameDetailDTO).
class GameDetailModel {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? headerImageUrl;
  final double price;
  final double? discountPrice;
  final double? originalPrice;
  final List<TagModel> tags;
  final String? developer;
  final String? publisher;
  final String? releaseDate;
  final double? rating;
  final int? reviewCount;
  final List<String> screenshots;

  GameDetailModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.headerImageUrl,
    required this.price,
    this.discountPrice,
    this.originalPrice,
    this.tags = const [],
    this.developer,
    this.publisher,
    this.releaseDate,
    this.rating,
    this.reviewCount,
    this.screenshots = const [],
  });

  factory GameDetailModel.fromJson(Map<String, dynamic> json) {
    List<TagModel> parsedTags = [];
    if (json['tags'] != null && json['tags'] is List) {
      parsedTags = (json['tags'] as List).map((tag) {
        if (tag is String) return TagModel(tagId: 0, tagName: tag);
        if (tag is Map<String, dynamic>) return TagModel.fromJson(tag);
        return TagModel(tagId: 0, tagName: tag.toString());
      }).toList();
    }

    List<String> parsedScreenshots = [];
    if (json['media'] != null && json['media'] is List) {
      parsedScreenshots = (json['media'] as List).map((m) {
        if (m is Map) {
          return m['mediaUrl']?.toString() ??
                 m['url']?.toString() ??
                 m['link']?.toString() ??
                 '';
        }
        return m.toString();
      }).where((s) => s.isNotEmpty).toList();
    } else if (json['screenshots'] != null && json['screenshots'] is List) {
      parsedScreenshots = (json['screenshots'] as List)
          .map((s) => s.toString())
          .toList();
    }

    return GameDetailModel(
      id: json['gameId'] ?? json['id'] ?? 0,
      title: json['name'] ?? json['title'] ?? '',
      description: json['fullDescription'] ?? json['shortDescription'] ?? json['description'],
      imageUrl: json['iconUrl'] ?? json['imageUrl'] ?? json['gameUrl'],
      headerImageUrl: json['gameUrl'] ?? json['headerImageUrl'] ?? json['backgroundUrl'] ?? (parsedScreenshots.isNotEmpty ? parsedScreenshots.first : null),
      price: (json['price'] ?? 0).toDouble(),
      discountPrice: json['discountPrice']?.toDouble(),
      originalPrice: json['originalPrice']?.toDouble(),
      tags: parsedTags,
      developer: json['developer']?.toString() ??
          json['developerName']?.toString(),
      publisher: json['publisher'] is Map
          ? json['publisher']['publisherName']?.toString() ?? json['publisher']['name']?.toString()
          : json['publisher']?.toString() ?? json['publisherName']?.toString(),
      releaseDate: json['releaseDate']?.toString(),
      rating: json['rating']?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      screenshots: parsedScreenshots,
    );
  }

  bool get isOnSale =>
      discountPrice != null && discountPrice! < price && discountPrice! > 0;

  double get displayPrice => discountPrice ?? price;

  int get discountPercent {
    if (!isOnSale) return 0;
    return (((price - displayPrice) / price) * 100).round();
  }
}
