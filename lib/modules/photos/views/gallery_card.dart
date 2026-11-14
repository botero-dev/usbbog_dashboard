import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/async_view.dart';
import '../../../shared/widgets/surface_card.dart';
import '../services/immich_provider.dart';
import '../view_models/gallery_view_model.dart';
import 'photo_view.dart';

/// Dashboard gallery tile (`1:31`). Shows one photo of the day from Immich.
class GalleryCard extends StatefulWidget {
  const GalleryCard({
    super.key,
    this.accountId,
    this.albumId,
    this.onLongPress,
  });

  /// Immich account; empty falls back to the demo account.
  final String? accountId;

  /// Empty means "anywhere in the library".
  final String? albumId;
  final VoidCallback? onLongPress;

  @override
  State<GalleryCard> createState() => _GalleryCardState();
}

class _GalleryCardState extends State<GalleryCard> {
  late final GalleryViewModel _viewModel = GalleryViewModel(
    ImmichProvider.serviceFor(widget.accountId),
    albumId: widget.albumId,
  )..load();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      height: 168,
      padding: EdgeInsets.zero,
      borderColor: null,
      color: AppColors.imagePlaceholder,
      onLongPress: widget.onLongPress,
      child: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, _) => AsyncView(
          isLoading: _viewModel.isLoading,
          error: _viewModel.error,
          onRetry: _viewModel.refresh,
          foreground: AppColors.onLight,
          builder: (context) => _photo(_viewModel),
        ),
      ),
    );
  }

  Widget _photo(GalleryViewModel viewModel) {
    final photo = viewModel.photo!;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                PhotoView(photo: photo, imageHeaders: viewModel.imageHeaders),
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Image.network(
          photo.thumbnailUrl,
          headers: viewModel.imageHeaders,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, _, _) => const _PhotoFallback(),
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : const _PhotoFallback(),
        ),
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.imagePlaceholder,
      child: Center(
        child: Icon(Icons.image_outlined, size: 32, color: AppColors.onLight),
      ),
    );
  }
}
