import 'package:flutter/material.dart';

import '../models/caldav_account.dart';
import '../services/caldav_provider.dart';
import '../services/caldav_service.dart';

/// Backs "Add Account" for CalDAV: Server / User / Pass → Connect.
class AddCaldavAccountViewModel extends ChangeNotifier {
  final server = TextEditingController();
  final user = TextEditingController();
  final pass = TextEditingController();

  bool isConnecting = false;
  String? error;

  bool _disposed = false;

  /// Connects and lists task lists to prove the credentials work before the
  /// account is stored.
  Future<CaldavAccount?> connect() async {
    final baseUrl = server.text.trim();
    final username = user.text.trim();
    final password = pass.text;

    if (baseUrl.isEmpty || username.isEmpty || password.isEmpty) {
      error = 'Completa servidor, usuario y contraseña';
      _notify();
      return null;
    }

    isConnecting = true;
    error = null;
    _notify();

    final account = CaldavAccount(
      id: 'caldav-${DateTime.now().microsecondsSinceEpoch}',
      label: username,
      baseUrl: baseUrl,
      username: username,
      password: password,
    );
    final service = CalDavProvider.builder(account);

    try {
      await service.taskLists();
    } on CalDavException catch (failure) {
      service.close();
      error = failure.message;
      isConnecting = false;
      _notify();
      return null;
    }

    CalDavProvider.add(account, service: service);

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
    user.dispose();
    pass.dispose();
    super.dispose();
  }
}
