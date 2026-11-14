import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/wireframe_scaffold.dart';
import '../models/photo.dart';

/// Fullscreen viewer for one Immich asset.
class PhotoView extends StatelessWidget {
  const PhotoView({
    super.key,
    required this.photo,
    required this.imageHeaders,
    this.title = 'Foto',
  });

  final Photo photo;
  final Map<String, String> imageHeaders;
  final String title;

  @override
  Widget build(BuildContext context) {
    return WireframeScaffold(
      title: title,
      backgroundColor: Colors.black,
      child: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Image.network(
            photo.previewUrl,
            headers: imageHeaders,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No se pudo cargar la foto', style: AppText.body),
            ),
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const CircularProgressIndicator(color: AppColors.onDark),
          ),
        ),
      ),
    );
  }
}
