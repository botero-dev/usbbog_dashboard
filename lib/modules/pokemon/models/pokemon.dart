class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.summary,
    required this.description,
    required this.types,
    required this.heightCm,
    required this.weightG,
  });

  final int id;
  final String name;

  /// Text shown on the dashboard card.
  final String summary;

  /// Text shown on the Pokedex screen.
  final String description;

  final List<String> types;
  final int heightCm;
  final int weightG;
}

/// Placeholder until `pokemon_service` talks to PokeAPI (M3).
const demoPokemon = Pokemon(
  id: 93,
  name: 'Haunter',
  summary:
      'Descripcion del pokemon Descripcion del pokemon Descripcion del pokemon',
  description: 'Haunter es un Pokemon que asusta.',
  types: ['Fantasma'],
  heightCm: 123,
  weightG: 185,
);
