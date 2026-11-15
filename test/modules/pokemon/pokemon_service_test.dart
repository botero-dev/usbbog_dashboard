import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:usbbog_dashboard/modules/pokemon/services/pokemon_service.dart';

import '../../support/fake_pokeapi.dart';

PokemonService buildService(http.Client client, {DateTime? now}) {
  return PokemonService(
    client: client,
    now: () => now ?? DateTime(2026, 11, 16),
  );
}

void main() {
  test('daily() requests the id for that day of the year', () async {
    final paths = <String>[];
    final service = PokemonService(
      client: _RecordingClient(fakePokeApi(), paths.add),
    );

    // 2026-11-16 is day 320 of the year → 1 + (320 - 1) % 1025 = 320.
    final pokemon = await service.daily(day: DateTime(2026, 11, 16));

    expect(paths, contains('/api/v2/pokemon/320'));
    expect(pokemon.displayName, 'Haunter');
    expect(pokemon.types, ['Fantasma', 'Veneno']);
    expect(pokemon.heightCm, 160);
    expect(pokemon.description, contains('observando'));
  });

  test('daily() reuses the same id all day and moves the next day', () async {
    final paths = <String>[];
    final service = PokemonService(
      client: _RecordingClient(fakePokeApi(), paths.add),
    );

    await service.daily(day: DateTime(2026, 11, 16, 6));
    await service.daily(day: DateTime(2026, 11, 16, 23));
    await service.daily(day: DateTime(2026, 11, 17));

    final pokemonCalls = paths
        .where((path) => path.contains('/pokemon/'))
        .toList();

    // Same day is served from the cache; a new day is a new id.
    expect(pokemonCalls, ['/api/v2/pokemon/320', '/api/v2/pokemon/321']);
  });

  test('random() draws an id inside the dex range', () async {
    final paths = <String>[];
    final service = PokemonService(
      client: _RecordingClient(fakePokeApi(), paths.add),
      random: Random(7),
    );

    await service.random();

    // The fake reports 1025 species; the seeded generator is reproducible.
    final expectedId = 1 + Random(7).nextInt(1025);
    expect(paths, contains('/api/v2/pokemon/$expectedId'));
  });

  test('byId() caches the result', () async {
    var requests = 0;
    final client = fakePokeApi();
    final service = PokemonService(
      client: _CountingClient(client, () => requests++),
    );

    await service.byId(93);
    final afterFirst = requests;
    await service.byId(93);

    expect(requests, afterFirst);
  });

  test('a failing species request still returns the Pokémon', () async {
    final service = buildService(fakePokeApi(failSpecies: true));

    final pokemon = await service.byId(93);

    expect(pokemon.displayName, 'Haunter');
    expect(pokemon.description, isEmpty);
  });

  test(
    'a failing API throws ApiException with a user-facing message',
    () async {
      final service = buildService(failingPokeApi());

      expect(
        () => service.byId(93),
        throwsA(
          isA<PokemonException>().having(
            (e) => e.message,
            'message',
            contains('servidor'),
          ),
        ),
      );
    },
  );
}

/// Records each requested path so tests can assert what was fetched.
class _RecordingClient extends http.BaseClient {
  _RecordingClient(this._inner, this._onPath);

  final http.Client _inner;
  final void Function(String path) _onPath;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    _onPath(request.url.path);
    return _inner.send(request);
  }
}

/// Wraps a client to count calls, since `MockClient` cannot report them.
class _CountingClient extends http.BaseClient {
  _CountingClient(this._inner, this._onCall);

  final http.Client _inner;
  final void Function() _onCall;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    _onCall();
    return _inner.send(request);
  }
}
