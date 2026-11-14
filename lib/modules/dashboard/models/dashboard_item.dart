import 'widget_config.dart';

/// One card in the dashboard stack.
class DashboardItem {
  const DashboardItem({
    required this.id,
    required this.order,
    required this.config,
  });

  final String id;
  final int order;
  final WidgetConfig config;

  DashboardItem copyWith({int? order}) {
    return DashboardItem(id: id, order: order ?? this.order, config: config);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order': order,
      'kind': config.kind.name,
      'config': config.toJson(),
    };
  }

  static DashboardItem fromJson(Map<String, dynamic> json) {
    final kind = WidgetKind.values.byName(json['kind'] as String);
    final config =
        (json['config'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};

    return DashboardItem(
      id: json['id'] as String,
      order: json['order'] as int,
      config: WidgetConfig.fromJson(kind, config),
    );
  }
}
