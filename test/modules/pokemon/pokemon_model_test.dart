import 'package:flutter_test/flutter_test.dart';
import 'package:usbbog_dashboard/modules/pokemon/models/pokemon.dart';

const _haunter = {
  'id': 93,
  'name': 'haunter',
  'height': 16,
  'weight': 1,
  'sprites': {
    'front_default': 'https://example.test/sprite/93.png',
    'other': {
      'official-artwork': {'front_default': 'https://example.test/art/93.png'},
    },
  },
  // Deliberately out of order: the model sorts by slot.
  'types': [
    {
      'slot': 2,
      'type': {'name': 'poison'},
    },
    {
      'slot': 1,
      'type': {'name': 'ghost'},
    },
  ],
};

const _haunterSpecies = {
  'flavor_text_entries': [
    {
      'flavor_text': 'English text',
      'language': {'name': 'en'},
    },
    {
      'flavor_text': 'Cuando tienes la sensación de que te están\nobservando, seguro que es un Haunter.',
      'language': {'name': 'es'},
    },
  ],
};

void main() {
  group('Pokemon.fromJson', () {
    test('converts decimeters to centimetres and hectograms to grams', () {
      final pokemon = Pokemon.fromJson(_haunter);

      expect(pokemon.heightCm, 160);
      expect(pokemon.weightG, 100);
    });

    test('translates and sorts types by slot', () {
      final pokemon = Pokemon.fromJson(_haunter);

      expect(pokemon.types, ['Fantasma', 'Veneno']);
    });

    test('prefers the official artwork over the sprite', () {
      expect(
        Pokemon.fromJson(_haunter).imageUrl,
        'https://example.test/art/93.png',
      );
    });

    test('falls back to the sprite when there is no artwork', () {
      final withoutArtwork = {
        ..._haunter,
        'sprites': {'front_default': 'https://example.test/sprite/93.png'},
      };

      expect(
        Pokemon.fromJson(withoutArtwork).imageUrl,
        'https://example.test/sprite/93.png',
      );
    });

    test('prefers Spanish flavour text and strips line breaks', () {
      final pokemon = Pokemon.fromJson(_haunter, speciesJson: _haunterSpecies);

      expect(
        pokemon.description,
        contains('sensación de que te están observando'),
      );
      expect(pokemon.description, isNot(contains('\n')));
      expect(pokemon.description, startsWith('Cuando'));
    });

    test('capitalises the display name', () {
      expect(Pokemon.fromJson(_haunter).displayName, 'Haunter');
    });

    test('survives a missing species payload', () {
      final pokemon = Pokemon.fromJson(_haunter, speciesJson: null);

      expect(pokemon.description, isEmpty);
      expect(pokemon.displayName, 'Haunter');
    });
  });

  group('pokemonIdForDate', () {
    test('is stable for the same day', () {
      final date = DateTime(2026, 11, 16, 9);
      final later = DateTime(2026, 11, 16, 21);

      expect(pokemonIdForDate(date, 1025), pokemonIdForDate(later, 1025));
    });

    test('changes the next day', () {
      expect(
        pokemonIdForDate(DateTime(2026, 11, 16), 1025),
        isNot(pokemonIdForDate(DateTime(2026, 11, 17), 1025)),
      );
    });

    test('stays inside 1..dexCount', () {
      for (var day = 0; day < 366; day++) {
        final id = pokemonIdForDate(
          DateTime(2026).add(Duration(days: day)),
          1025,
        );
        expect(id, inInclusiveRange(1, 1025));
      }
    });

    test('handles an unknown dex size', () {
      expect(pokemonIdForDate(DateTime(2026, 11, 16), 0), 1);
    });
  });
}
