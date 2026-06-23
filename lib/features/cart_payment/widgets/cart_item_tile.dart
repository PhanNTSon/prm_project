import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../models/cart_item_model.dart';

class CartItemTile extends StatelessWidget {
  final CartItemModel item;
  final VoidCallback onRemove;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onRemove,
  });

  String _formatVnd(double amount) {
    final s = amount.round().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final fromEnd = s.length - i;
      buf.write(s[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write('.');
    }
    return '$buf ₫';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
            child: item.thumbnailUrl != null
                ? CachedNetworkImage(
                    imageUrl: item.thumbnailUrl!,
                    width: 160,
                    height: 90,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => _ThumbnailPlaceholder(),
                    errorWidget: (_, __, ___) => _ThumbnailPlaceholder(),
                  )
                : _ThumbnailPlaceholder(),
          ),
          // Game info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.gameName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primaryTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatVnd(item.price),
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Remove button
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton(
              onPressed: onRemove,
              child: Text(
                'Remove',
                style: TextStyle(
                  color: AppColors.secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbnailPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 90,
      color: AppColors.cardColor,
      child: Icon(
        Icons.videogame_asset_outlined,
        color: AppColors.secondaryTextColor,
        size: 32,
      ),
    );
  }
}