import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usbbog_dashboard/app.dart';
import 'package:usbbog_dashboard/modules/pokemon/services/pokemon_provider.dart';
import 'package:usbbog_dashboard/modules/pokemon/services/pokemon_service.dart';

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

  setUp(() => useApi());
  tearDown(PokemonProvider.reset);

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

  testWidgets('add gallery: widget type -> account -> list -> new card', (
    tester,
  ) async {
    await pumpApp(tester);
    await settle(tester);

    await tester.tap(find.text('+'));
    await settle(tester);

    await tester.tap(find.text('Galería Immich'));
    await settle(tester);
    expect(find.text('Select Account'), findsOneWidget);

    await tester.tap(find.text('boterock@gmail.com'));
    await settle(tester);
    expect(find.text('Select List'), findsOneWidget);

    await tester.tap(find.text('Paseo a la finca'));
    await settle(tester);

    expect(find.text('Hola, Andrés'), findsOneWidget);
    expect(find.textContaining('Paseo a la finca'), findsOneWidget);

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
