enum WidgetKind { clock, pokemon, gallery, tasks }

/// Configuration of one dashboard card. Persisted as `{kind, config}` inside a
/// `DashboardItem`.
sealed class WidgetConfig {
  const WidgetConfig();

  WidgetKind get kind;

  Map<String, dynamic> toJson();

  static WidgetConfig fromJson(WidgetKind kind, Map<String, dynamic> json) {
    return switch (kind) {
      WidgetKind.clock => const ClockConfig(),
      WidgetKind.pokemon => PokemonConfig(pokemonId: json['pokemonId'] as int?),
      WidgetKind.gallery => GalleryConfig(
        accountId: json['accountId'] as String? ?? '',
        albumId: json['albumId'] as String? ?? '',
        label: json['label'] as String? ?? 'Galería',
      ),
      WidgetKind.tasks => TasksConfig(
        accountId: json['accountId'] as String? ?? '',
        listId: json['listId'] as String? ?? '',
        label: json['label'] as String? ?? 'Tareas',
      ),
    };
  }
}

/// Clock + mini calendar + long date. No fields.
final class ClockConfig extends WidgetConfig {
  const ClockConfig();

  @override
  WidgetKind get kind => WidgetKind.clock;

  @override
  Map<String, dynamic> toJson() => const {};
}

final class PokemonConfig extends WidgetConfig {
  const PokemonConfig({this.pokemonId});

  /// `null` means "today's Pokémon".
  final int? pokemonId;

  @override
  WidgetKind get kind => WidgetKind.pokemon;

  @override
  Map<String, dynamic> toJson() => {
    if (pokemonId != null) 'pokemonId': pokemonId,
  };
}

final class GalleryConfig extends WidgetConfig {
  const GalleryConfig({
    required this.accountId,
    required this.albumId,
    required this.label,
  });

  final String accountId;
  final String albumId;
  final String label;

  @override
  WidgetKind get kind => WidgetKind.gallery;

  @override
  Map<String, dynamic> toJson() => {
    'accountId': accountId,
    'albumId': albumId,
    'label': label,
  };
}

final class TasksConfig extends WidgetConfig {
  const TasksConfig({
    required this.accountId,
    required this.listId,
    required this.label,
  });

  final String accountId;

  /// CalDAV calendar uid.
  final String listId;
  final String label;

  @override
  WidgetKind get kind => WidgetKind.tasks;

  @override
  Map<String, dynamic> toJson() => {
    'accountId': accountId,
    'listId': listId,
    'label': label,
  };
}
