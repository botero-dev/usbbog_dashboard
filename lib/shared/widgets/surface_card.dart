import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// A rounded block of the dashboard: 24 px radius, optional 2 px white border.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.all(12),
    this.color,
    this.borderColor = AppColors.onDark,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
          border: _border(),
        ),
        child: child,
      ),
    );
  }

  Border? _border() {
    final color = borderColor;
    if (color == null) {
      return null;
    }
    return Border.all(color: color, width: AppSpacing.cardBorder);
  }
}
