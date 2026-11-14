import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// The "Boton" component of the wireframe screens: 87 px tall, 32 px label.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.enabled = true,
    this.accent = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.controlHeight,
      child: Material(
        color: accent ? AppColors.accent : AppColors.surface,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.button,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
