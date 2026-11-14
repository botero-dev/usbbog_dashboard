/// A Pokémon, already translated from the PokeAPI payload.
class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.description,
    required this.types,
    required this.heightCm,
    required this.weightG,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String description;

  /// Already in Spanish, e.g. `['Fantasma', 'Veneno']`.
  final List<String> types;

  final int heightCm;
  final int weightG;
  final String? imageUrl;

  /// `haunter` → `Haunter`
  String get displayName =>
      name.isEmpty ? name : name[0].toUpperCase() + name.substring(1);

  /// Builds a Pokémon from `/pokemon/{id}`. [speciesJson] is the optional
  /// `/pokemon-species/{id}` payload that carries the flavour text.
  factory Pokemon.fromJson(
    Map<String, dynamic> json, {
    Map<String, dynamic>? speciesJson,
  }) {
    final heightDm = (json['height'] as num?)?.toInt() ?? 0;
    final weightHg = (json['weight'] as num?)?.toInt() ?? 0;

    return Pokemon(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? 'Desconocido',
      description: pickDescription(speciesJson),
      types: pickTypes(json),
      heightCm: heightDm * 10,
      weightG: weightHg * 100,
      imageUrl: pickImage(json),
    );
  }
}

const _typeNamesEs = {
  'normal': 'Normal',
  'fire': 'Fuego',
  'water': 'Agua',
  'electric': 'Eléctrico',
  'grass': 'Planta',
  'ice': 'Hielo',
  'fighting': 'Lucha',
  'poison': 'Veneno',
  'ground': 'Tierra',
  'flying': 'Volador',
  'psychic': 'Psíquico',
  'bug': 'Bicho',
  'rock': 'Roca',
  'ghost': 'Fantasma',
  'dragon': 'Dragón',
  'dark': 'Siniestro',
  'steel': 'Acero',
  'fairy': 'Hada',
  'unknown': 'Desconocido',
  'shadow': 'Sombra',
};

List<String> pickTypes(Map<String, dynamic> json) {
  final entries = (json['types'] as List?) ?? const [];
  final sorted = [...entries]
    ..sort(
      (a, b) => ((a['slot'] as num?) ?? 0).compareTo((b['slot'] as num?) ?? 0),
    );

  return [
    for (final entry in sorted)
      _typeNamesEs[(entry['type'] as Map?)?['name'] as String? ?? ''] ??
          (entry['type'] as Map?)?['name'] as String? ??
          '',
  ].where((name) => name.isNotEmpty).toList();
}

/// Prefers the official artwork and falls back to the sprite.
String? pickImage(Map<String, dynamic> json) {
  final sprites = (json['sprites'] as Map?)?.cast<String, dynamic>();
  if (sprites == null) {
    return null;
  }

  final other = (sprites['other'] as Map?)?.cast<String, dynamic>();
  final artwork = (other?['official-artwork'] as Map?)?.cast<String, dynamic>();
  final artworkUrl = artwork?['front_default'] as String?;
  if (artworkUrl != null && artworkUrl.isNotEmpty) {
    return artworkUrl;
  }

  final spriteUrl = sprites['front_default'] as String?;
  return (spriteUrl != null && spriteUrl.isNotEmpty) ? spriteUrl : null;
}

/// Spanish flavour text, then English, cleaned of the markers PokeAPI embeds.
String pickDescription(Map<String, dynamic>? speciesJson) {
  final entries = (speciesJson?['flavor_text_entries'] as List?) ?? const [];
  if (entries.isEmpty) {
    return '';
  }

  String? text;
  for (final language in const ['es', 'en']) {
    for (final entry in entries) {
      final map = entry as Map;
      if ((map['language'] as Map?)?['name'] == language) {
        text = map['flavor_text'] as String?;
        break;
      }
    }
    if (text != null) {
      break;
    }
  }

  return cleanFlavorText(text ?? '');
}

String cleanFlavorText(String text) {
  return text
      .replaceAll(RegExp(r'[\n\r\f]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Deterministic "Pokémon del día": day of year, wrapped into the dex range.
int pokemonIdForDate(DateTime date, int dexCount) {
  if (dexCount <= 0) {
    return 1;
  }
  final dayOfYear = date.difference(DateTime(date.year)).inDays + 1;
  return 1 + (dayOfYear - 1) % dexCount;
}
