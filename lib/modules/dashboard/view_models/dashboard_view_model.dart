import 'package:flutter/foundation.dart';

import '../models/dashboard_item.dart';
import '../models/widget_config.dart';

/// Owns the card order. Persistence arrives in M2 (`dashboard.v1`).
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({List<DashboardItem>? items})
    : _items = [...?items]..sort((a, b) => a.order.compareTo(b.order));

  /// Same cards as the Figma dashboard, so every button is reachable on launch.
  factory DashboardViewModel.seeded() {
    return DashboardViewModel(
      items: const [
        DashboardItem(id: 'clock', order: 0, config: ClockConfig()),
        DashboardItem(id: 'pokemon', order: 1, config: PokemonConfig()),
        DashboardItem(
          id: 'gallery',
          order: 2,
          config: GalleryConfig(
            accountId: 'immich-demo',
            albumId: '',
            label: 'Galería',
          ),
        ),
        DashboardItem(
          id: 'tasks',
          order: 3,
          config: TasksConfig(
            accountId: 'demo',
            listId: 'mis-tareas',
            label: 'Mis Tareas',
          ),
        ),
      ],
    );
  }

  final List<DashboardItem> _items;

  List<DashboardItem> get items => List.unmodifiable(_items);

  void add(WidgetConfig config) {
    _items.add(
      DashboardItem(
        id: 'widget-${DateTime.now().microsecondsSinceEpoch}',
        order: _items.length,
        config: config,
      ),
    );
    notifyListeners();
  }

  void remove(String id) {
    _items.removeWhere((item) => item.id == id);
    for (var index = 0; index < _items.length; index++) {
      _items[index] = _items[index].copyWith(order: index);
    }
    notifyListeners();
  }
}
