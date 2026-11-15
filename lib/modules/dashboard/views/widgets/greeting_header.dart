import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// "Hola, Andrés" + the settings gear (`9:84`).
class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.name, this.onSettings});

  final String name;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 59,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Hola, $name',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.title,
            ),
          ),
          IconButton(
            onPressed: onSettings,
            tooltip: 'Acerca de',
            icon: const Icon(
              Icons.settings_outlined,
              size: 24,
              color: AppColors.onDark,
            ),
          ),
        ],
      ),
    );
  }
}
