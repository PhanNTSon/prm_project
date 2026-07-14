
class TagModel {
  final int tagId;
  final String tagName;

  TagModel({
    required this.tagId,
    required this.tagName,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      tagId: json['tagId'] ?? 0,
      tagName: json['tagName'] ?? '',
    );
  }
}
