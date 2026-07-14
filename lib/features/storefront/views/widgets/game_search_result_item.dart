import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/game_basic_model.dart';

/// Widget hiển thị 1 game trong kết quả tìm kiếm.
/// Thiết kế theo phong cách Steam: ảnh bên trái, thông tin bên phải.
class GameSearchResultItem extends StatelessWidget {
  final GameBasicModel game;
  final VoidCallback onTap;

  const GameSearchResultItem({
    super.key,
    required this.game,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFF2A475E), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            // === Ảnh game (thumbnail) ===
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: SizedBox(
                width: 120,
                height: 45,
                child: game.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: game.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: const Color(0xFF2A475E),
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF66C0F4),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: const Color(0xFF2A475E),
                          child: const Icon(
                            Icons.sports_esports,
                            color: Colors.white38,
                            size: 20,
                          ),
                        ),
                      )
                    : Container(
                        color: const Color(0xFF2A475E),
                        child: const Icon(
                          Icons.sports_esports,
                          color: Colors.white38,
                          size: 20,
                        ),
                      ),
              ),
            ),

            const SizedBox(width: 12),

            // === Thông tin game ===
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tên game
                  Text(
                    game.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  // Tags
                  if (game.tags.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      children: game.tags.take(3).map((tag) {
                        return Text(
                          tag.tagName,
                          style: const TextStyle(
                            color: Color(0xFF8F98A0),
                            fontSize: 11,
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),

            // === Giá ===
            _buildPriceTag(),
          ],
        ),
      ),
    );
  }

  /// Widget hiển thị giá theo phong cách Steam.
  Widget _buildPriceTag() {
    // Game miễn phí
    if (game.price <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF2A475E),
          borderRadius: BorderRadius.circular(2),
        ),
        child: const Text(
          'Free',
          style: TextStyle(
            color: Color(0xFFACDBF5),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    // Game đang giảm giá
    if (game.isOnSale) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Giá gốc (gạch ngang)
          Text(
            '\$${game.price.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Color(0xFF8F98A0),
              fontSize: 11,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 6),
          // Giá giảm
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF4C6B22),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              '\$${game.displayPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Color(0xFFBEEE11),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }

    // Giá bình thường
    return Text(
      '\$${game.price.toStringAsFixed(2)}',
      style: const TextStyle(
        color: Color(0xFFACDBF5),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
