import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerGameCard extends StatelessWidget {
  const ShimmerGameCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.surface,
      highlightColor: colorScheme.surfaceContainerHighest,
      child: Card(child: SizedBox(width: 180, height: 220)),
    );
  }
}
