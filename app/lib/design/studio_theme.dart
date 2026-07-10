import 'package:flutter/material.dart';

import 'studio_colors.dart';
import 'studio_typography.dart';

/// Builds the app [ThemeData] from Studio design tokens.
abstract final class StudioTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: StudioColors.rust,
      brightness: Brightness.light,
      surface: StudioColors.paper,
      primary: StudioColors.rust,
      onPrimary: StudioColors.card,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: StudioColors.sand,
      canvasColor: StudioColors.sand,
      dividerColor: StudioColors.lineDefault,
      textTheme: TextTheme(
        displayLarge: StudioType.display,
        headlineLarge: StudioType.h1,
        headlineMedium: StudioType.h2,
        titleMedium: StudioType.h3,
        bodyLarge: StudioType.bodyLarge,
        bodyMedium: StudioType.body,
        bodySmall: StudioType.small,
        labelSmall: StudioType.label,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: StudioColors.sand,
        foregroundColor: StudioColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: StudioColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: StudioColors.lineDefault),
        ),
        margin: EdgeInsets.zero,
      ),
      splashFactory: NoSplash.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
