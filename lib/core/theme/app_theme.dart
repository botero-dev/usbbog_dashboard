import 'package:flutter/material.dart';

/// Colors taken from the "Tablero" Figma file.
abstract final class AppColors {
  static const backgroundTop = Color(0xFF2B2917);
  static const backgroundBottom = Color(0xFF847F66);
  static const onDark = Color(0xFFFFFFFF);

  static const onLight = Color(0xFF1A1A1A);

  /// Wireframe screens: header bar, buttons and the primary (Connect) action.
  static const header = Color(0xFF62B2EB);
  static const surface = Color(0xFFD8D8D8);
  static const accent = Color(0xFF9FADFF);

  /// Pokedex screen.
  static const pokedex = Color(0xFFEF5DA8);
  static const imagePlaceholder = Color(0xFFCEE6FF);
}

abstract final class AppText {
  static const clock = TextStyle(
    fontSize: 64,
    height: 1.2,
    color: AppColors.onDark,
  );
  static const title = TextStyle(
    fontSize: 32,
    height: 1.2,
    color: AppColors.onDark,
  );
  static const body = TextStyle(
    fontSize: 16,
    height: 1.2,
    color: AppColors.onDark,
  );
  static const caption = TextStyle(
    fontSize: 12,
    height: 1.25,
    color: AppColors.onDark,
  );

  static const weekday = TextStyle(
    fontSize: 10,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.onDark,
  );
  static const dayNumber = TextStyle(
    fontSize: 10,
    height: 1.4,
    color: AppColors.onDark,
  );

  static const screenTitle = TextStyle(
    fontSize: 32,
    height: 1.2,
    color: AppColors.onLight,
  );
  static const button = TextStyle(
    fontSize: 32,
    height: 1.2,
    color: AppColors.onLight,
  );
}

abstract final class AppSpacing {
  static const page = 20.0;
  static const block = 31.0;
  static const cardRadius = 24.0;
  static const cardBorder = 2.0;

  /// Wireframe screens use a 40 px gutter and 30 px between controls.
  static const screenGutter = 40.0;
  static const controlGap = 30.0;
  static const controlHeight = 87.0;
  static const headerHeight = 106.0;
}

abstract final class AppTheme {
  static ThemeData build() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent),
      scaffoldBackgroundColor: Colors.white,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static BoxDecoration dashboardBackground() {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.backgroundTop, AppColors.backgroundBottom],
      ),
    );
  }

  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
      border: Border.all(color: AppColors.onDark, width: AppSpacing.cardBorder),
    );
  }
}
