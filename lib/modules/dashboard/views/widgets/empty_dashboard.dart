import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Shown while the dashboard has no cards.
class EmptyDashboard extends StatelessWidget {
  const EmptyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Image.asset(
            'assets/images/empty_board.png',
            width: 120,
            height: 120,
            semanticLabel: 'Tablero vacío',
          ),
          const SizedBox(height: 16),
          Text(
            'Agrega tu primer widget con el botón +',
            textAlign: TextAlign.center,
            style: AppText.body.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
