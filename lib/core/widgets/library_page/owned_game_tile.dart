import 'package:flutter/material.dart';

import '../../../features/library/data/models/library_game.dart';

class OwnedGameTile extends StatelessWidget {
  final LibraryGame game;

  const OwnedGameTile({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),

      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),

          child: Image.network(game.imageUrl, width: 90, fit: BoxFit.cover),
        ),

        title: Text(game.title),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 6),

            Text(
              "${game.playHours.toStringAsFixed(1)} hrs played",
              style: theme.textTheme.bodySmall,
            ),

            Text(
              "Last played: ${game.lastPlayed}",
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
