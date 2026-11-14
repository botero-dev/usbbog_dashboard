import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Blue header + circular back button shared by the "Add ..." and "Select ..."
/// screens (`1:50`, `9:60`, `9:85`, `9:102`).
class WireframeScaffold extends StatelessWidget {
  const WireframeScaffold({
    super.key,
    required this.title,
    required this.child,
    this.onBack,
    this.backgroundColor = Colors.white,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          SizedBox(
            height: AppSpacing.headerHeight,
            child: ColoredBox(
              color: AppColors.header,
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 90),
                        child: Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.screenTitle,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 33,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: SizedBox(
                          width: 57,
                          height: 57,
                          child: Material(
                            color: AppColors.surface,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap:
                                  onBack ??
                                  () => Navigator.of(context).maybePop(),
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
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
