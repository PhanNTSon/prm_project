import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/game_basic_model.dart';

/// Widget hiển thị một card game trong Featured slider.
/// Thiết kế theo phong cách Steam: ảnh lớn + overlay gradient + tên + giá.
class FeaturedGameCard extends StatelessWidget {
  final GameBasicModel game;
  final VoidCallback? onTap;

  const FeaturedGameCard({
    super.key,
    required this.game,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 320,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF16202D),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // === Ảnh nền ===
            Positioned.fill(
              child: game.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: game.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildPlaceholder(),
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),

            // === Gradient overlay phía dưới ===
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),

            // === Thông tin game ở góc dưới ===
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Tên game
                  Text(
                    game.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 4,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Giá
                  _buildPriceRow(),
                ],
              ),
            ),

            // === Badge "FEATURED" ===
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF66C0F4),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'FEATURED',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1E3144),
      child: const Center(
        child: Icon(
          Icons.sports_esports,
          color: Color(0xFF4A6B8A),
          size: 48,
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    if (game.price <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF4C6B22),
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Text(
          'FREE TO PLAY',
          style: TextStyle(
            color: Color(0xFFBEEE11),
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (game.isOnSale) {
      final discountPct = (((game.price - game.displayPrice) / game.price) * 100).round();
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Phần trăm giảm
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF4C6B22),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '-$discountPct%',
              style: const TextStyle(
                color: Color(0xFFBEEE11),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Giá gốc
          Text(
            '\$${game.price.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 11,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 4),
          // Giá giảm
          Text(
            '\$${game.displayPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    return Text(
      '\$${game.price.toStringAsFixed(2)}',
      style: const TextStyle(
        color: Color(0xFFACDBF5),
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
