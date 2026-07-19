import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/game_basic_model.dart';

class HorizontalGameCard extends StatelessWidget {
  final GameBasicModel game;
  final VoidCallback? onTap;

  const HorizontalGameCard({
    super.key,
    required this.game,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          color: const Color(0xFF16202D),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh thumbnail
            Expanded(
              child: SizedBox(
                width: 140,
              child: game.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: game.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildPlaceholder(),
                      errorWidget: (context, url, error) => _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
              ),
            ),
            
            // Tên và giá
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildPriceRow(),
                ],
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
          size: 32,
        ),
      ),
    );
  }

  Widget _buildPriceRow() {
    if (game.price <= 0) {
      return const Text(
        'Free To Play',
        style: TextStyle(
          color: Color(0xFFBEEE11),
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (game.isOnSale) {
      final discountPct = (((game.price - game.displayPrice) / game.price) * 100).round();
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF4C6B22),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              '-$discountPct%',
              style: const TextStyle(
                color: Color(0xFFBEEE11),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '\$${game.displayPrice.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
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
        fontSize: 11,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
