import 'package:flutter/foundation.dart';

import '../models/album.dart';
import '../services/immich_service.dart';

/// Backs the "Select List" step of the gallery widget.
class AlbumPickerViewModel extends ChangeNotifier {
  AlbumPickerViewModel(this._service);

  final ImmichService _service;

  List<Album> albums = const [];
  bool isLoading = false;
  String? error;

  bool _disposed = false;

  Future<void> load() async {
    if (isLoading) {
      return;
    }

    isLoading = true;
    error = null;
    _notify();

    try {
      // Empty albums are hidden: picking one would only produce an empty card.
      albums = (await _service.albums())
          .where((album) => !album.isEmpty)
          .toList();
    } on ImmichException catch (failure) {
      error = failure.message;
    }

    isLoading = false;
    _notify();
  }

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
