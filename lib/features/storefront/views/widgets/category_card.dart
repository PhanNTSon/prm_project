import 'package:flutter/material.dart';
import '../../data/models/category_model.dart';

/// Widget hiển thị một category card trong phần "Browse by Category".
/// Có nền ảnh (từ asset) + gradient overlay + tên category.
class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF16202D),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // === Ảnh nền từ web Steam ===
            Image.network(
              _getSteamImageUrl(category.name),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback 1: Local asset nếu có
                if (category.imageAsset != null) {
                  return Image.asset(
                    category.imageAsset!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildDefaultBg(),
                  );
                }
                // Fallback 2: Màu nền mặc định
                return _buildDefaultBg();
              },
            ),

            // === Gradient overlay ===
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _categoryColor(category.name).withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.70),
                  ],
                ),
              ),
            ),

            // === Tên category ===
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon tượng trưng
                  Icon(
                    _categoryIcon(category.name),
                    color: Colors.white.withValues(alpha: 0.85),
                    size: 18,
                  ),
                  const SizedBox(height: 4),
                  // Tên
                  Text(
                    category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                      height: 1.15,
                      shadows: [
                        Shadow(blurRadius: 4, color: Colors.black),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDefaultBg() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _categoryColor(category.name).withValues(alpha: 0.4),
            const Color(0xFF0A1628),
          ],
        ),
      ),
    );
  }

  /// Màu accent tương ứng với tên category (dùng hash để tự động assign)
  Color _categoryColor(String name) {
    final colors = [
      const Color(0xFF1F6FEB), // xanh dương
      const Color(0xFF8957E5), // tím
      const Color(0xFF2DA44E), // xanh lá
      const Color(0xFFD29922), // vàng
      const Color(0xFFDA3633), // đỏ
      const Color(0xFF0FBED0), // cyan
      const Color(0xFFE36209), // cam
      const Color(0xFFBF4B8A), // hồng
    ];
    return colors[name.hashCode.abs() % colors.length];
  }

  /// Icon tương ứng với tên category
  IconData _categoryIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('action')) return Icons.flash_on;
    if (lower.contains('rpg') || lower.contains('role')) return Icons.shield;
    if (lower.contains('sport')) return Icons.sports_soccer;
    if (lower.contains('strategy')) return Icons.account_tree;
    if (lower.contains('adventure')) return Icons.explore;
    if (lower.contains('simulation') || lower.contains('sim')) return Icons.settings_suggest;
    if (lower.contains('horror') || lower.contains('survival')) return Icons.dangerous;
    if (lower.contains('puzzle') || lower.contains('casual')) return Icons.extension;
    if (lower.contains('racing') || lower.contains('race')) return Icons.speed;
    if (lower.contains('shooter') || lower.contains('fps')) return Icons.gps_fixed;
    if (lower.contains('fighting') || lower.contains('fight')) return Icons.sports_martial_arts;
    if (lower.contains('music') || lower.contains('rhythm')) return Icons.music_note;
    return Icons.sports_esports;
  }

  /// Format tên category thành dạng url slug an toàn
  String _getSteamImageUrl(String name) {
    // VD: "Action" -> "action", "Sports & Racing" -> "sportsracing"
    // URL format: https://store.fastly.steamstatic.com/categories/homepageimage/category/[tên]?cc=us&l=tchinese&v=2
    final safeName = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    return 'https://store.fastly.steamstatic.com/categories/homepageimage/category/$safeName?cc=us&l=tchinese&v=2';
  }
}
