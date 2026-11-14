import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// The "+" card at the bottom of the dashboard (`1:65`).
class AddWidgetTile extends StatelessWidget {
  const AddWidgetTile({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        height: 95,
        decoration: AppTheme.cardDecoration(),
        child: const Center(child: Text('+', style: AppText.clock)),
      ),
    );
  }
}
