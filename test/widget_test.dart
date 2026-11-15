import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:usbbog_dashboard/app.dart';
import 'package:usbbog_dashboard/modules/photos/models/immich_account.dart';
import 'package:usbbog_dashboard/modules/photos/services/immich_provider.dart';
import 'package:usbbog_dashboard/modules/photos/services/immich_service.dart';
import 'package:usbbog_dashboard/modules/photos/views/gallery_card.dart';
import 'package:usbbog_dashboard/modules/pokemon/services/pokemon_provider.dart';
import 'package:usbbog_dashboard/modules/tasks/services/caldav_provider.dart';
import 'package:usbbog_dashboard/modules/tasks/services/caldav_service.dart';
import 'package:usbbog_dashboard/modules/tasks/views/tasks_card.dart';
import 'package:usbbog_dashboard/modules/pokemon/services/pokemon_service.dart';

import 'support/fake_caldav_session.dart';
import 'support/fake_immich.dart';
import 'support/fake_pokeapi.dart';

void main() {
  // A tall surface so the whole card stack is laid out and tappable.
  void useTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(412, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  /// No network: the provider hands out a fake-backed service.
  void useApi({bool failing = false}) {
    PokemonProvider.service = PokemonService(
      client: failing ? failingPokeApi() : fakePokeApi(),
      now: () => DateTime(2026, 11, 16, 9, 32),
    );
  }

  /// Same idea for Immich: the demo host is never contacted in tests. Every
  /// account — demo or added in the flow — gets a fake-backed service.
  void useImmich({int status = 200}) {
    ImmichProvider.builder = (baseUrl, apiKey) => ImmichService(
      baseUrl: baseUrl,
      apiKey: apiKey,
      client: fakeImmich(status: status),
      now: () => DateTime(2026, 11, 16, 9, 32),
    );
  }

  /// CalDAV never reaches a real server either; the fake session records writes.
  final caldavSessions = <FakeCalDavSession>[];

  void useCalDav({bool failOnWrite = false}) {
    CalDavProvider.reset();
    CalDavProvider.builder = (account) {
      final session = FakeCalDavSession(
        tasks: {'l1': defaultTasks},
        failOnWrite: failOnWrite,
      );
      caldavSessions.add(session);
      return CalDavService(account: account, connect: (_) async => session);
    };
  }

  setUp(() {
    useApi();
    // The app ships without demo credentials; tests enable a demo account so
    // the Add Account flow has one to reuse.
    ImmichProvider.demoAccount = const ImmichAccount(
      id: ImmichProvider.demoAccountId,
      label: 'Demo · demo.immich.app',
      baseUrl: 'https://demo.immich.app',
      apiKey: 'demo-key',
      isDemo: true,
    );
    ImmichProvider.reset();
    useImmich();
    caldavSessions.clear();
    useCalDav();
  });

  tearDown(() {
    PokemonProvider.reset();
    ImmichProvider.reset();
    CalDavProvider.reset();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    useTallSurface(tester);
    await tester.pumpWidget(const UsbbogDashboardApp());
  }

  /// Route transitions plus the Pokémon request completing.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('dashboard renders the greeting and the seeded cards', (
    tester,
  ) async {
    await pumpApp(tester);
    await settle(tester);

    expect(find.text('Hola, Andrés'), findsOneWidget);
    expect(find.text('Tus tareas:'), findsOneWidget);
    expect(find.text('Haunter'), findsOneWidget);

    // Unmount so the clock timer is cancelled before the test ends.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the Pokémon card shows real PokeAPI data', (tester) async {
    await pumpApp(tester);
    await settle(tester);

    expect(find.text('Pokemon del día'), findsOneWidget);
    expect(find.text('Haunter'), findsOneWidget);
    expect(find.textContaining('observando'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the Pokémon card shows an error with a retry', (tester) async {
    useApi(failing: true);
    await pumpApp(tester);
    await settle(tester);

    expect(find.textContaining('servidor'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the Pokemon card opens the Pokedex with types and stats', (
    tester,
  ) async {
    await pumpApp(tester);
    await settle(tester);

    await tester.tap(find.text('Haunter'));
    await settle(tester);

    expect(find.text('Fantasma'), findsOneWidget);
    expect(find.text('Veneno'), findsOneWidget);
    expect(find.text('Tamaño'), findsOneWidget);
    expect(find.text('1,6 m'), findsOneWidget);
    expect(find.text('100 g'), findsOneWidget);

    // Back returns to the dashboard.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await settle(tester);
    expect(find.text('Hola, Andrés'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the + tile opens Add widget', (tester) async {
    await pumpApp(tester);
    await settle(tester);

    await tester.tap(find.text('+'));
    await settle(tester);

    expect(find.text('Add widget'), findsOneWidget);
    expect(find.text('Galería Immich'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('add gallery: widget type -> account -> albums -> new card', (
    tester,
  ) async {
    await pumpApp(tester);
    await settle(tester);

    // The gallery card is not seeded: it needs an account.
    expect(find.byType(GalleryCard), findsNothing);

    await tester.tap(find.text('+'));
    await settle(tester);

    await tester.tap(find.text('Galería Immich'));
    await settle(tester);

    // The demo account is offered first, next to "Add Account".
    expect(find.text('Select Account'), findsOneWidget);
    expect(find.text('Demo · demo.immich.app'), findsOneWidget);
    expect(find.text('Add Account'), findsOneWidget);

    await tester.tap(find.text('Demo · demo.immich.app'));
    await settle(tester);

    expect(find.text('Select List'), findsOneWidget);
    expect(find.text('Holiday'), findsOneWidget);
    expect(find.text('Birthday'), findsOneWidget);
    // Empty albums are hidden, so there is nothing to tap that would yield a
    // blank card.
    expect(find.text('Empty Album'), findsNothing);

    await tester.tap(find.text('Holiday'));
    await settle(tester);

    expect(find.text('Hola, Andrés'), findsOneWidget);
    expect(find.byType(GalleryCard), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('add gallery: a new server account is validated and reused', (
    tester,
  ) async {
    await pumpApp(tester);
    await settle(tester);

    await tester.tap(find.text('+'));
    await settle(tester);
    await tester.tap(find.text('Galería Immich'));
    await settle(tester);

    await tester.tap(find.text('Add Account'));
    await settle(tester);

    expect(find.text('API Key'), findsOneWidget);

    // Empty fields are rejected before any request.
    await tester.tap(find.text('Connect'));
    await settle(tester);
    expect(find.textContaining('Completa servidor'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'photos.example.com');
    await tester.enterText(fields.at(1), 'secret-key');

    await tester.tap(find.text('Connect'));
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 200));
    await settle(tester);

    // Connect goes straight to the album list, and the account is now stored.
    expect(find.text('Select List'), findsOneWidget);
    expect(
      ImmichProvider.accounts.map((a) => a.label),
      contains('photos.example.com'),
    );

    await tester.tap(find.text('Holiday'));
    await settle(tester);

    expect(find.byType(GalleryCard), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the gallery card reports an Immich failure', (tester) async {
    useImmich(status: 401);
    useTallSurface(tester);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GalleryCard(accountId: ImmichProvider.demoAccountId),
        ),
      ),
    );
    await settle(tester);

    expect(find.textContaining('clave de API'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the seeded tasks card asks for CalDAV setup', (tester) async {
    await pumpApp(tester);
    await settle(tester);

    // No account configured yet, so it invites setup instead of erroring.
    expect(
      find.text('Agrega una cuenta CalDAV desde el botón +'),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('add tasks: Connect skips back to Select List', (tester) async {
    await pumpApp(tester);
    await settle(tester);

    await tester.tap(find.text('+'));
    await settle(tester);

    await tester.tap(find.text('Lista de Tareas'));
    await settle(tester);
    expect(find.text('Select Account'), findsOneWidget);

    await tester.tap(find.text('Add Account'));
    await settle(tester);
    expect(find.text('Add Account'), findsOneWidget);
    expect(find.text('Connect'), findsOneWidget);

    // Empty fields are rejected before any request.
    await tester.tap(find.text('Connect'));
    await settle(tester);
    expect(find.textContaining('Completa servidor'), findsOneWidget);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'https://cal.example.com');
    await tester.enterText(fields.at(1), 'andres@example.com');
    await tester.enterText(fields.at(2), 'app-password');

    await tester.tap(find.text('Connect'));
    await settle(tester);
    await settle(tester);

    // Connect goes straight to Select List, as in the prototype.
    expect(find.text('Select List'), findsOneWidget);
    expect(
      CalDavProvider.accounts.map((a) => a.username),
      contains('andres@example.com'),
    );

    await tester.tap(find.text('Mis Tareas'));
    await settle(tester);

    // A second tasks card was added, now backed by the fake session.
    expect(find.byType(TasksCard), findsNWidgets(2));
    expect(find.text('Leer los 4 acuerdos'), findsWidgets);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('checking a task writes through to CalDAV', (tester) async {
    await pumpApp(tester);
    await settle(tester);

    await tester.tap(find.text('+'));
    await settle(tester);
    await tester.tap(find.text('Lista de Tareas'));
    await settle(tester);
    await tester.tap(find.text('Add Account'));
    await settle(tester);

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'https://cal.example.com');
    await tester.enterText(fields.at(1), 'andres@example.com');
    await tester.enterText(fields.at(2), 'app-password');
    await tester.tap(find.text('Connect'));
    await settle(tester);
    await settle(tester);
    await tester.tap(find.text('Mis Tareas'));
    await settle(tester);

    // The new card resolves its tasks from the session.
    expect(find.text('Leer los 4 acuerdos'), findsWidgets);

    await tester.tap(find.text('Leer los 4 acuerdos').last);
    await settle(tester);

    expect(caldavSessions.expand((s) => s.writes), contains('t1:true'));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the gear opens the About screen in an app bar', (tester) async {
    await pumpApp(tester);
    await settle(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await settle(tester);

    expect(find.widgetWithText(AppBar, 'Acerca de'), findsOneWidget);
    expect(find.text('PokeAPI'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await settle(tester);
    expect(find.text('Hola, Andrés'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the Pokedex app bar draws a random Pokémon', (tester) async {
    useTallSurface(tester);

    // The daily id (320) and Haunter (93) keep the fake payload; any other id
    // answers as Zubat, so the random action is observable.
    final base = fakePokeApi();
    PokemonProvider.service = PokemonService(
      client: MockClient((request) async {
        final match = RegExp(r'/pokemon/(\d+)$').firstMatch(request.url.path);
        if (match != null && !['93', '320'].contains(match.group(1))) {
          return http.Response(
            jsonEncode({
              ...haunterJson,
              'id': int.parse(match.group(1)!),
              'name': 'zubat',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return base.get(request.url);
      }),
      now: () => DateTime(2026, 11, 16, 9, 32),
      random: _FixedRandom(500),
    );

    await tester.pumpWidget(const UsbbogDashboardApp());
    await settle(tester);

    await tester.tap(find.text('Haunter'));
    await settle(tester);
    expect(find.text('Haunter'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.shuffle));
    await settle(tester);

    // 1 + 500 % 1025 = 501, served by the fake as Zubat.
    expect(find.text('Zubat'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Zubat'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}

/// Always returns the same offset, so the random Pokémon is deterministic.
class _FixedRandom implements Random {
  _FixedRandom(this.offset);

  final int offset;

  @override
  int nextInt(int max) => offset % max;

  @override
  double nextDouble() => 0;

  @override
  bool nextBool() => false;
}
