/// Model ánh xạ từ CategoryDTO của backend.
class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? imageAsset; // Đường dẫn ảnh local asset (người dùng tự gán sau)

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageAsset,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? json['tagId'] ?? 0,
      name: json['name'] ?? json['tagName'] ?? '',
      description: json['description'],
    );
  }

  /// Tạo bản copy với imageAsset được gán
  CategoryModel withAsset(String asset) {
    return CategoryModel(
      id: id,
      name: name,
      description: description,
      imageAsset: asset,
    );
  }
}
