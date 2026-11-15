import 'package:flutter_test/flutter_test.dart';
import 'package:usbbog_dashboard/modules/photos/models/immich_account.dart';
import 'package:usbbog_dashboard/modules/photos/services/immich_provider.dart';
import 'package:usbbog_dashboard/modules/photos/services/immich_service.dart';

import '../../support/fake_immich.dart';

void main() {
  final built = <String>[];

  const demo = ImmichAccount(
    id: ImmichProvider.demoAccountId,
    label: 'Demo · demo.immich.app',
    baseUrl: 'https://demo.immich.app',
    apiKey: 'demo-key',
    isDemo: true,
  );

  setUp(() {
    built.clear();
    // The app ships without credentials, so tests opt in to a demo account.
    ImmichProvider.demoAccount = demo;
    ImmichProvider.reset();
    ImmichProvider.builder = (baseUrl, apiKey) {
      built.add('$baseUrl|$apiKey');
      return ImmichService(
        baseUrl: baseUrl,
        apiKey: apiKey,
        client: fakeImmich(),
      );
    };
  });

  tearDown(() {
    ImmichProvider.demoAccount = null;
    ImmichProvider.reset();
  });

  test('without demo credentials no account is offered', () {
    ImmichProvider.demoAccount = null;
    ImmichProvider.reset();

    expect(ImmichProvider.accounts, isEmpty);
    expect(
      () => ImmichProvider.serviceFor('anything'),
      throwsA(isA<ImmichException>()),
    );
  });

  test('starts with only the demo account', () {
    expect(ImmichProvider.accounts, hasLength(1));
    expect(ImmichProvider.accounts.single.id, ImmichProvider.demoAccountId);
    expect(ImmichProvider.accounts.single.isDemo, isTrue);
  });

  test('added accounts are listed after the demo one', () {
    ImmichProvider.add(
      const ImmichAccount(
        id: 'a1',
        label: 'photos.example.com',
        baseUrl: 'https://photos.example.com',
        apiKey: 'k',
      ),
    );

    expect(ImmichProvider.accounts.map((a) => a.id), [
      ImmichProvider.demoAccountId,
      'a1',
    ]);
  });

  test('serviceFor builds from the account credentials and caches them', () {
    const account = ImmichAccount(
      id: 'a1',
      label: 'photos.example.com',
      baseUrl: 'https://photos.example.com',
      apiKey: 'secret',
    );
    ImmichProvider.add(account);

    final first = ImmichProvider.serviceFor('a1');
    final second = ImmichProvider.serviceFor('a1');

    expect(identical(first, second), isTrue);
    expect(built, ['https://photos.example.com|secret']);
  });

  test('serviceFor falls back to the demo account for a stale id', () {
    final service = ImmichProvider.serviceFor('no-longer-exists');

    expect(service.baseUrl, demo.baseUrl);
    expect(built.single, startsWith(demo.baseUrl));
  });

  test('reset clears added accounts and cached services', () {
    ImmichProvider.add(
      const ImmichAccount(
        id: 'a1',
        label: 'x',
        baseUrl: 'https://x.example.com',
        apiKey: 'k',
      ),
    );
    ImmichProvider.serviceFor('a1');

    ImmichProvider.reset();

    expect(ImmichProvider.accounts, hasLength(1));
    expect(ImmichProvider.account('a1'), isNull);
  });
}
