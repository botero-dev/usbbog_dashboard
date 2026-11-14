import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Artwork with the design's pale-blue placeholder behind it.
class PokemonArtwork extends StatelessWidget {
  const PokemonArtwork({
    super.key,
    required this.imageUrl,
    this.size = 131,
    this.radius = 8,
  });

  final String? imageUrl;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        borderRadius: BorderRadius.circular(radius),
      ),
    );

    final url = imageUrl;
    if (url == null) {
      return placeholder;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.imagePlaceholder,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        url,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : const SizedBox.shrink(),
      ),
    );
  }
}
