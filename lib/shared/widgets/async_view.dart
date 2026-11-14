import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Switches between loading, error+retry and content.
class AsyncView extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.isLoading,
    required this.error,
    required this.onRetry,
    required this.builder,
    this.foreground = AppColors.onDark,
  });

  final bool isLoading;
  final String? error;
  final VoidCallback onRetry;
  final WidgetBuilder builder;

  /// Cards sit on the dark gradient, so the default is white.
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2, color: foreground),
        ),
      );
    }

    final message = error;
    if (message != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.caption.copyWith(color: foreground),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: Text('Reintentar', style: TextStyle(color: foreground)),
            ),
          ],
        ),
      );
    }

    return builder(context);
  }
}
