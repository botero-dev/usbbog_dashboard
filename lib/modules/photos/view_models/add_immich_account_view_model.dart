import 'package:flutter/material.dart';

import '../models/immich_account.dart';
import '../services/immich_provider.dart';
import '../services/immich_service.dart';

/// Backs "Add Account" for Immich: Server + API key → Connect.
class AddImmichAccountViewModel extends ChangeNotifier {
  final server = TextEditingController();
  final apiKey = TextEditingController();

  bool isConnecting = false;
  String? error;

  bool _disposed = false;

  /// Validates the credentials against the server; returns the account on
  /// success and leaves a readable [error] otherwise.
  Future<ImmichAccount?> connect() async {
    final rawServer = server.text.trim();
    final rawKey = apiKey.text.trim();

    if (rawServer.isEmpty || rawKey.isEmpty) {
      error = 'Completa servidor y clave de API';
      _notify();
      return null;
    }

    isConnecting = true;
    error = null;
    _notify();

    final baseUrl = ImmichService.normalizeBaseUrl(rawServer);
    final service = ImmichProvider.builder(baseUrl, rawKey);

    try {
      // Listing albums is the cheapest call that proves the key works.
      await service.albums();
    } on ImmichException catch (failure) {
      error = failure.message;
      isConnecting = false;
      _notify();
      return null;
    }

    final account = ImmichAccount(
      id: 'immich-${DateTime.now().microsecondsSinceEpoch}',
      label: Uri.parse(baseUrl).authority,
      baseUrl: baseUrl,
      apiKey: rawKey,
    );
    ImmichProvider.add(account, service: service);

    isConnecting = false;
    _notify();
    return account;
  }

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    server.dispose();
    apiKey.dispose();
    super.dispose();
  }
}
