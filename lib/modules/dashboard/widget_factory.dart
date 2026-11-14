import 'package:flutter/material.dart';

import '../clock/views/clock_card.dart';
import '../photos/views/gallery_card.dart';
import '../pokemon/views/pokemon_card.dart';
import '../tasks/views/tasks_card.dart';
import 'models/dashboard_item.dart';
import 'models/widget_config.dart';

/// Maps a stored [WidgetConfig] to the card that renders it.
class WidgetFactory {
  const WidgetFactory._();

  static Widget build(
    BuildContext context,
    DashboardItem item, {
    VoidCallback? onLongPress,
  }) {
    final key = ValueKey(item.id);

    return switch (item.config) {
      ClockConfig() => ClockCard(key: key, onLongPress: onLongPress),
      PokemonConfig() => PokemonCard(key: key, onLongPress: onLongPress),
      GalleryConfig(:final label) => GalleryCard(
        key: key,
        label: label,
        onLongPress: onLongPress,
      ),
      TasksConfig() => TasksCard(key: key, onLongPress: onLongPress),
    };
  }
}
