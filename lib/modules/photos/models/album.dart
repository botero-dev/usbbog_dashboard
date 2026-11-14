/// An Immich album.
class Album {
  const Album({
    required this.id,
    required this.name,
    this.assetCount = 0,
    this.thumbnailAssetId,
  });

  final String id;
  final String name;
  final int assetCount;
  final String? thumbnailAssetId;

  /// An album with no assets cannot feed a gallery card.
  bool get isEmpty => assetCount <= 0;

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as String? ?? '',
      name: json['albumName'] as String? ?? 'Álbum',
      assetCount: (json['assetCount'] as num?)?.toInt() ?? 0,
      thumbnailAssetId: json['albumThumbnailAssetId'] as String?,
    );
  }
}
