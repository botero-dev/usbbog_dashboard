import 'package:flutter/foundation.dart';

import '../models/account.dart';

/// Backs `Select Account` (`9:60`). Persistence arrives in M4 with
/// `account_service`.
class SelectAccountViewModel extends ChangeNotifier {
  SelectAccountViewModel({required this.kind, List<Account>? accounts})
    : _accounts = [...?accounts];

  factory SelectAccountViewModel.demo(AccountKind kind) {
    return SelectAccountViewModel(
      kind: kind,
      accounts: [
        Account(
          id: 'demo-1',
          kind: kind,
          label: 'boterock@gmail.com',
          server: 'https://demo.local',
          user: 'boterock@gmail.com',
        ),
        Account(
          id: 'demo-2',
          kind: kind,
          label: 'correo@gmail.com',
          server: 'https://demo.local',
          user: 'correo@gmail.com',
        ),
      ],
    );
  }

  final AccountKind kind;
  final List<Account> _accounts;

  List<Account> get accounts => List.unmodifiable(_accounts);

  void add(Account account) {
    _accounts.add(account);
    notifyListeners();
  }
}
