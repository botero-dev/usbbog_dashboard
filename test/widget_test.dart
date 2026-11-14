import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usbbog_dashboard/app.dart';
import 'package:usbbog_dashboard/modules/photos/services/immich_provider.dart';
import 'package:usbbog_dashboard/modules/photos/services/immich_service.dart';
import 'package:usbbog_dashboard/modules/photos/views/gallery_card.dart';
import 'package:usbbog_dashboard/modules/pokemon/services/pokemon_provider.dart';
import 'package:usbbog_dashboard/modules/pokemon/services/pokemon_service.dart';

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

  setUp(() {
    useApi();
    ImmichProvider.reset();
    useImmich();
  });

  tearDown(() {
    PokemonProvider.reset();
    ImmichProvider.reset();
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

    expect(find.byType(GalleryCard), findsOneWidget);

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
    expect(find.byType(GalleryCard), findsNWidgets(2));

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

    expect(find.byType(GalleryCard), findsNWidgets(2));

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('the gallery card reports an Immich failure', (tester) async {
    useImmich(status: 401);
    await pumpApp(tester);
    await settle(tester);

    expect(find.textContaining('clave de API'), findsOneWidget);

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

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'https://cal.example.com');
    await tester.enterText(fields.at(1), 'andres');
    await tester.enterText(fields.at(2), 'secret');

    await tester.tap(find.text('Connect'));
    await settle(tester);
    await tester.pump(const Duration(milliseconds: 700));
    await settle(tester);

    // Connect goes straight to Select List, as in the prototype.
    expect(find.text('Select List'), findsOneWidget);

    await tester.tap(find.text('Mis Tareas'));
    await settle(tester);

    // A second tasks card was added to the dashboard.
    expect(find.text('Tus tareas:'), findsNWidgets(2));

    await tester.pumpWidget(const SizedBox());
  });
}
