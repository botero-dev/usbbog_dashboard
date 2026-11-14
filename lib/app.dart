import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'modules/dashboard/view_models/dashboard_view_model.dart';
import 'modules/dashboard/views/dashboard_view.dart';

class UsbbogDashboardApp extends StatefulWidget {
  const UsbbogDashboardApp({super.key});

  @override
  State<UsbbogDashboardApp> createState() => _UsbbogDashboardAppState();
}

class _UsbbogDashboardAppState extends State<UsbbogDashboardApp> {
  final DashboardViewModel _dashboard = DashboardViewModel.seeded();

  @override
  void dispose() {
    _dashboard.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tablero',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(),
      home: DashboardView(viewModel: _dashboard),
    );
  }
}
