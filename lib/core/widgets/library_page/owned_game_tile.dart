import 'package:flutter/material.dart';
import 'package:prm_project/features/library/data/models/library_game.dart';

class OwnedGameTile extends StatelessWidget {
  final LibraryGame game;

  const OwnedGameTile({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: _GameThumbnail(iconUrl: game.iconUrl),

        title: Text(game.name),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),

            Text(
              "${game.playHours.toStringAsFixed(1)} hrs played",
              style: theme.textTheme.bodySmall,
            ),

            Text(
              "Last played: ${game.lastTimePlayed ?? "Never"}",
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _GameThumbnail extends StatelessWidget {
  final String iconUrl;

  const _GameThumbnail({required this.iconUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (iconUrl.trim().isEmpty) {
      return _placeholder(colorScheme);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        iconUrl,
        width: 90,
        height: 60,
        fit: BoxFit.cover,

        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return SizedBox(
            width: 90,
            height: 60,
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },

        errorBuilder: (_, __, ___) {
          return _placeholder(colorScheme);
        },
      ),
    );
  }

  Widget _placeholder(ColorScheme colorScheme) {
    return Container(
      width: 90,
      height: 60,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.sports_esports,
        color: colorScheme.onSurfaceVariant,
        size: 32,
      ),
    );
  }
}
