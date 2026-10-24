// app_theme.dart — BMI+ complete Material 3 light and dark themes
// No external font packages. Uses Flutter's built-in M3 typography.

import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ---------------------------------------------------------------------------
  // Seed color — professional health-tech teal-blue
  // ---------------------------------------------------------------------------
  static const Color _seedColor = Color(0xFF0284C7); // sky-700

  // ---------------------------------------------------------------------------
  // Light ColorScheme — generated from seed via M3 algorithm
  // ---------------------------------------------------------------------------
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.light,
  );

  // ---------------------------------------------------------------------------
  // Dark ColorScheme
  // ---------------------------------------------------------------------------
  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _seedColor,
    brightness: Brightness.dark,
  );

  // ---------------------------------------------------------------------------
  // Text theme — uses M3 built-in typography (no external fonts)
  // ---------------------------------------------------------------------------
  static const TextTheme _textTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
    displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.w400),
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w400),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, letterSpacing: 0),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
    titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
    labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
  );

  // ---------------------------------------------------------------------------
  // Shared component themes
  // ---------------------------------------------------------------------------

  static CardThemeData _cardTheme(ColorScheme cs) => CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: cs.surfaceContainerLow,
        margin: EdgeInsets.zero,
      );

  static AppBarTheme _appBarTheme(ColorScheme cs) => AppBarTheme(
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: cs.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
        ),
      );

  static FilledButtonThemeData _filledButtonTheme(ColorScheme cs) =>
      FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 52),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      );

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme cs) =>
      OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          minimumSize: const Size(double.infinity, 52),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      );

  static InputDecorationTheme _inputDecorationTheme(ColorScheme cs) =>
      InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.3), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        hintStyle: TextStyle(color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
      );

  static NavigationBarThemeData _navBarTheme(ColorScheme cs) =>
      NavigationBarThemeData(
        backgroundColor: cs.surface,
        indicatorColor: cs.primaryContainer,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              color: cs.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            );
          }
          return TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: cs.onPrimaryContainer);
          }
          return IconThemeData(color: cs.onSurfaceVariant);
        }),
      );

  static SnackBarThemeData _snackBarTheme(ColorScheme cs) => SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      );

  // ---------------------------------------------------------------------------
  // Light Theme
  // ---------------------------------------------------------------------------
  static ThemeData get light {
    final cs = _lightColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: _textTheme,
      cardTheme: _cardTheme(cs),
      appBarTheme: _appBarTheme(cs),
      filledButtonTheme: _filledButtonTheme(cs),
      outlinedButtonTheme: _outlinedButtonTheme(cs),
      inputDecorationTheme: _inputDecorationTheme(cs),
      navigationBarTheme: _navBarTheme(cs),
      snackBarTheme: _snackBarTheme(cs),
      scaffoldBackgroundColor: cs.surface,
      dividerTheme: DividerThemeData(color: cs.outlineVariant, space: 1),
    );
  }

  // ---------------------------------------------------------------------------
  // Dark Theme
  // ---------------------------------------------------------------------------
  static ThemeData get dark {
    final cs = _darkColorScheme;
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: _textTheme,
      cardTheme: _cardTheme(cs),
      appBarTheme: _appBarTheme(cs),
      filledButtonTheme: _filledButtonTheme(cs),
      outlinedButtonTheme: _outlinedButtonTheme(cs),
      inputDecorationTheme: _inputDecorationTheme(cs),
      navigationBarTheme: _navBarTheme(cs),
      snackBarTheme: _snackBarTheme(cs),
      scaffoldBackgroundColor: cs.surface,
      dividerTheme: DividerThemeData(color: cs.outlineVariant, space: 1),
    );
  }

  // ---------------------------------------------------------------------------
  // BMI category colors — consistent across light and dark
  // ---------------------------------------------------------------------------

  static Color bmiCategoryColor(String category, {bool dark = false}) {
    switch (category) {
      case 'Underweight':
        return dark ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8); // blue
      case 'Normal':
        return dark ? const Color(0xFF4ADE80) : const Color(0xFF15803D); // green
      case 'Overweight':
        return dark ? const Color(0xFFFBBF24) : const Color(0xFFB45309); // amber
      case 'Obesity':
        return dark ? const Color(0xFFF87171) : const Color(0xFFDC2626); // red
      default:
        return dark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
    }
  }

  static Color bmiCategoryBackground(String category, {bool dark = false}) {
    switch (category) {
      case 'Underweight':
        return dark ? const Color(0xFF1E3A5F) : const Color(0xFFDBEAFE);
      case 'Normal':
        return dark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7);
      case 'Overweight':
        return dark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
      case 'Obesity':
        return dark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2);
      default:
        return dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    }
  }
}
