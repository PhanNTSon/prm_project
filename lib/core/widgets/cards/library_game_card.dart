import 'package:flutter/material.dart';

class LibraryGameCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double playHours;
  final VoidCallback onTap;

  const LibraryGameCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.playHours,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(imageUrl, width: 80, fit: BoxFit.cover),
      ),
      title: Text(title),
      subtitle: Text(
        '${playHours.toStringAsFixed(1)} hrs played',
        style: theme.textTheme.bodySmall,
      ),
    );
  }
}
