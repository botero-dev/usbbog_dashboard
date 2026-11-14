import 'package:flutter/material.dart';

import '../models/account.dart';

/// Backs `Add Account` (`9:85`): Server / User / Pass / Connect.
class AddAccountViewModel extends ChangeNotifier {
  final server = TextEditingController();
  final user = TextEditingController();
  final pass = TextEditingController();

  bool isConnecting = false;
  String? error;

  bool _disposed = false;

  /// Validates the fields and returns the account to save.
  ///
  /// M4 swaps the delay for a real `CalDavClient.connect` / Immich login.
  Future<Account?> connect(AccountKind kind) async {
    if (server.text.trim().isEmpty ||
        user.text.trim().isEmpty ||
        pass.text.isEmpty) {
      error = 'Completa servidor, usuario y contraseña';
      _notify();
      return null;
    }

    isConnecting = true;
    error = null;
    _notify();

    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (_disposed) {
      return null;
    }

    isConnecting = false;
    _notify();

    return Account(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      kind: kind,
      label: user.text.trim(),
      server: server.text.trim(),
      user: user.text.trim(),
    );
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
