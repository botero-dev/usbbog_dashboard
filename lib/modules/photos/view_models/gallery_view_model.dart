import 'package:flutter/foundation.dart';

import '../models/photo.dart';
import '../services/immich_service.dart';

/// Backs the dashboard gallery card and the fullscreen viewer.
class GalleryViewModel extends ChangeNotifier {
  GalleryViewModel(this._service, {this.albumId});

  /// Empty means "anywhere in the library".
  final String? albumId;

  final ImmichService _service;

  Photo? photo;
  bool isLoading = false;
  String? error;

  bool _disposed = false;

  Map<String, String> get imageHeaders => _service.imageHeaders;

  Future<void> load() async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    error = null;
    _notify();

    try {
      photo = await _service.dailyPhoto(albumId: albumId);
    } on ImmichException catch (failure) {
      error = failure.message;
    }

    isLoading = false;
    _notify();
  }

  Future<void> refresh() => load();

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
