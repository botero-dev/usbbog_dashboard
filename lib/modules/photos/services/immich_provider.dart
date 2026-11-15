import '../models/immich_account.dart';
import 'immich_service.dart';

/// Static access point for Immich: the account list plus one service per
/// account, so several servers can coexist behind the same dashboard.
///
/// There is no credential in the repository. To try the integration against a
/// server, pass it at build time:
///
/// ```
/// flutter run --dart-define=IMMICH_BASE_URL=http://192.168.1.10:2283 \
///             --dart-define=IMMICH_API_KEY=<key>
/// ```
///
/// Without a key no demo account is offered, so the Add Account flow is the
/// only way in.
abstract final class ImmichProvider {
  static const demoAccountId = 'immich-demo';

  static const _envBaseUrl = String.fromEnvironment(
    'IMMICH_BASE_URL',
    defaultValue: 'https://demo.immich.app',
  );
  static const _envApiKey = String.fromEnvironment('IMMICH_API_KEY');

  /// The built-in account, only present when `IMMICH_API_KEY` was provided at
  /// build time. Tests assign one before calling [reset].
  static ImmichAccount? demoAccount = _envApiKey.isEmpty
      ? null
      : ImmichAccount(
          id: demoAccountId,
          label: 'Demo · ${_hostLabel(_envBaseUrl)}',
          baseUrl: _envBaseUrl,
          apiKey: _envApiKey,
          isDemo: true,
        );

  /// `http://192.168.1.10:2283` → `192.168.1.10:2283`, so the button label
  /// stays readable.
  static String _hostLabel(String baseUrl) {
    final uri = Uri.tryParse(baseUrl);
    if (uri == null || uri.host.isEmpty) {
      return baseUrl;
    }
    return uri.hasPort ? '${uri.host}:${uri.port}' : uri.host;
  }

  /// Builds a service; tests replace this to inject an `http.Client`.
  static ImmichService Function(String baseUrl, String apiKey) builder = (
    baseUrl,
    apiKey,
  ) => ImmichService(baseUrl: baseUrl, apiKey: apiKey);

  static final List<ImmichAccount> _accounts = [..._withDemo()];
  static final Map<String, ImmichService> _services = {};

  static List<ImmichAccount> _withDemo() {
    final demo = demoAccount;
    return demo == null ? const [] : [demo];
  }

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
    if (resolved == null) {
      throw const ImmichException('Agrega tu servidor Immich desde el botón +');
    }
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
      ..addAll(_withDemo());
    _services.clear();
    builder = (baseUrl, apiKey) =>
        ImmichService(baseUrl: baseUrl, apiKey: apiKey);
  }
}
