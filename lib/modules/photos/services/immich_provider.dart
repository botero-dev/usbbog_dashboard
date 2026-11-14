import '../models/immich_account.dart';
import 'immich_service.dart';

/// Static access point for Immich: the account list plus one service per
/// account, so several servers can coexist behind the same dashboard.
///
/// The built-in demo account is Immich's public instance. Override its host and
/// key at build time with `--dart-define=IMMICH_BASE_URL=...` and
/// `--dart-define=IMMICH_API_KEY=...` instead of editing this file.
abstract final class ImmichProvider {
  static const demoBaseUrl = 'https://demo.immich.app';
  static const demoApiKey = 'FAmXXMMZHctXJrHybUsqamZHvCcRTTlLFeOOqEnbRE';

  static const _envBaseUrl = String.fromEnvironment(
    'IMMICH_BASE_URL',
    defaultValue: demoBaseUrl,
  );
  static const _envApiKey = String.fromEnvironment(
    'IMMICH_API_KEY',
    defaultValue: demoApiKey,
  );

  static const demoAccountId = 'immich-demo';

  static final ImmichAccount demoAccount = ImmichAccount(
    id: demoAccountId,
    label: 'Demo · demo.immich.app',
    baseUrl: _envBaseUrl,
    apiKey: _envApiKey,
    isDemo: true,
  );

  /// Builds a service; tests replace this to inject an `http.Client`.
  static ImmichService Function(String baseUrl, String apiKey) builder = (
    baseUrl,
    apiKey,
  ) => ImmichService(baseUrl: baseUrl, apiKey: apiKey);

  static final List<ImmichAccount> _accounts = [demoAccount];
  static final Map<String, ImmichService> _services = {};

  static List<ImmichAccount> get accounts => List.unmodifiable(_accounts);

  static ImmichAccount? account(String? id) {
    for (final account in _accounts) {
      if (account.id == id) {
        return account;
      }
    }
    return null;
  }

  /// Service for [accountId], falling back to the demo account when the id is
  /// empty or no longer exists (e.g. a stale stored config).
  static ImmichService serviceFor(String? accountId) {
    final resolved = account(accountId) ?? demoAccount;
    return _services.putIfAbsent(
      resolved.id,
      () => builder(resolved.baseUrl, resolved.apiKey),
    );
  }

  static void add(ImmichAccount account, {ImmichService? service}) {
    _accounts.add(account);
    if (service != null) {
      _services[account.id] = service;
    }
  }

  static void reset() {
    _accounts
      ..clear()
      ..add(demoAccount);
    _services.clear();
    builder = (baseUrl, apiKey) =>
        ImmichService(baseUrl: baseUrl, apiKey: apiKey);
  }
}
