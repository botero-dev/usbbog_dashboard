/// One Immich asset, with the two thumbnail renditions the UI needs.
class Photo {
  const Photo({
    required this.id,
    required this.thumbnailUrl,
    required this.previewUrl,
  });

  final String id;

  /// Small rendition for the dashboard card (`size=thumbnail`).
  final String thumbnailUrl;

  /// Larger rendition for the fullscreen viewer (`size=preview`).
  final String previewUrl;
}
