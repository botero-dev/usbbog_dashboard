import '../models/caldav_account.dart';
import 'caldav_service.dart';

/// Static access point for CalDAV, mirroring `ImmichProvider`.
///
/// There is no demo account: credentials are personal. To skip the Add Account
/// form during development, pass them at build time (never commit them):
///
/// ```
/// flutter run --dart-define=CALDAV_BASE_URL=https://caldav.example.com \
///             --dart-define=CALDAV_USERNAME=me@example.com \
///             --dart-define=CALDAV_PASSWORD=app-password
/// ```
abstract final class CalDavProvider {
  static const _envBaseUrl = String.fromEnvironment('CALDAV_BASE_URL');
  static const _envUsername = String.fromEnvironment('CALDAV_USERNAME');
  static const _envPassword = String.fromEnvironment('CALDAV_PASSWORD');

  static CalDavService Function(CaldavAccount account) builder = (account) =>
      CalDavService(account: account);

  static final List<CaldavAccount> _accounts = [
    if (_envBaseUrl.isNotEmpty &&
        _envUsername.isNotEmpty &&
        _envPassword.isNotEmpty)
      CaldavAccount(
        id: 'caldav-env',
        label: _envUsername,
        baseUrl: _envBaseUrl,
        username: _envUsername,
        password: _envPassword,
      ),
  ];

  static final Map<String, CalDavService> _services = {};

  static List<CaldavAccount> get accounts => List.unmodifiable(_accounts);

  static CaldavAccount? account(String? id) {
    for (final account in _accounts) {
      if (account.id == id) {
        return account;
      }
    }
    return null;
  }

  /// `null` when no account matches, so the card can ask for setup instead of
  /// showing a connection error.
  static CalDavService? serviceFor(String? accountId) {
    final resolved = account(accountId);
    if (resolved == null) {
      return null;
    }
    return _services.putIfAbsent(resolved.id, () => builder(resolved));
  }

  static void add(CaldavAccount account, {CalDavService? service}) {
    _accounts.add(account);
    if (service != null) {
      _services[account.id] = service;
    }
  }

  static void reset() {
    for (final service in _services.values) {
      service.close();
    }
    _services.clear();
    _accounts.clear();
    builder = (account) => CalDavService(account: account);
  }
}
