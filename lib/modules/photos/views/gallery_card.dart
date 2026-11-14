import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/surface_card.dart';

/// Dashboard gallery tile (`1:31`). The photo itself arrives with the Immich
/// service in M5; until then the card shows the album it is bound to.
class GalleryCard extends StatelessWidget {
  const GalleryCard({super.key, required this.label, this.onLongPress});

  final String label;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      height: 168,
      padding: EdgeInsets.zero,
      color: AppColors.imagePlaceholder,
      borderColor: null,
      onLongPress: onLongPress,
      child: Center(
        child: Text(
          'Galería Immich\n$label',
          textAlign: TextAlign.center,
          style: AppText.body.copyWith(color: AppColors.onLight),
        ),
      ),
    );
  }
}
