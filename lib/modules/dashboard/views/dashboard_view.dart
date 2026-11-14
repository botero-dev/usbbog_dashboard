import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../models/widget_config.dart';
import '../view_models/dashboard_view_model.dart';
import '../widget_factory.dart';
import 'add_widget_view.dart';
import 'widgets/add_widget_tile.dart';
import 'widgets/empty_dashboard.dart';
import 'widgets/greeting_header.dart';

/// `1:4` — the scrollable card stack.
class DashboardView extends StatelessWidget {
  const DashboardView({
    super.key,
    required this.viewModel,
    this.userName = 'Andrés',
  });

  final DashboardViewModel viewModel;
  final String userName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.dashboardBackground(),
        child: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: viewModel,
            builder: (context, _) {
              final items = viewModel.items;
              final blocks = <Widget>[
                GreetingHeader(
                  name: userName,
                  onSettings: () => _openSettings(context),
                ),
                if (items.isEmpty)
                  const EmptyDashboard()
                else
                  for (final item in items)
                    WidgetFactory.build(
                      context,
                      item,
                      onLongPress: () => viewModel.remove(item.id),
                    ),
                AddWidgetTile(onTap: () => _addWidget(context)),
              ];

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.page,
                  AppSpacing.page,
                  AppSpacing.block,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var index = 0; index < blocks.length; index++) ...[
                      if (index > 0) const SizedBox(height: AppSpacing.block),
                      blocks[index],
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _addWidget(BuildContext context) async {
    final config = await Navigator.of(context).push<WidgetConfig>(
      MaterialPageRoute(builder: (_) => const AddWidgetView()),
    );
    if (config != null) {
      viewModel.add(config);
    }
  }

  void _openSettings(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ajustes: sin diseño todavía')),
    );
  }
}
