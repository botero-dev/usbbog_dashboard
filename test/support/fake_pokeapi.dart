import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const haunterJson = {
  'id': 93,
  'name': 'haunter',
  'height': 16,
  'weight': 1,
  'sprites': {
    'other': {
      'official-artwork': {'front_default': 'https://example.test/art/93.png'},
    },
  },
  'types': [
    {
      'slot': 1,
      'type': {'name': 'ghost'},
    },
    {
      'slot': 2,
      'type': {'name': 'poison'},
    },
  ],
};

const haunterSpeciesJson = {
  'flavor_text_entries': [
    {
      'flavor_text': 'Cuando tienes la sensación de que te están\nobservando.',
      'language': {'name': 'es'},
    },
  ],
};

/// Serves the three PokeAPI endpoints `PokemonService` uses, with no network.
http.Client fakePokeApi({bool failSpecies = false}) {
  return MockClient((request) async {
    final path = request.url.path;

    if (path.endsWith('/pokemon-species')) {
      return http.Response(
        jsonEncode({'count': 1025, 'results': []}),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path.startsWith('/api/v2/pokemon-species/')) {
      if (failSpecies) {
        return http.Response('{"detail":"Not found"}', 404);
      }
      return http.Response(
        jsonEncode(haunterSpeciesJson),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    if (path.contains('/pokemon/')) {
      return http.Response(
        jsonEncode(haunterJson),
        200,
        headers: {'content-type': 'application/json'},
      );
    }

    return http.Response('{"detail":"Not found"}', 404);
  });
}

http.Client failingPokeApi() {
  return MockClient((request) async => http.Response('boom', 500));
}
