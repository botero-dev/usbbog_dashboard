import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// App bar + circular back button shared by the internal screens ("Add ...",
/// "Select ...", Pokedex, photo viewer, settings).
class WireframeScaffold extends StatelessWidget {
  const WireframeScaffold({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.actions,
    this.backgroundColor = Colors.white,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final List<Widget>? actions;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.header,
        foregroundColor: AppColors.onLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: AppSpacing.headerHeight,
        centerTitle: true,
        leadingWidth: 90,
        leading: Padding(
          padding: const EdgeInsets.only(left: 33),
          child: Center(
            child: SizedBox(
              width: 57,
              height: 57,
              child: Material(
                color: AppColors.surface,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onBack ?? () => Navigator.of(context).maybePop(),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 24,
                    color: AppColors.onLight,
                  ),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.screenTitle,
        ),
        actions: actions,
        actionsPadding: const EdgeInsets.only(right: 16),
      ),
      body: child,
    );
  }
}
