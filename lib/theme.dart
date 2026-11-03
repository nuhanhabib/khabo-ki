import 'package:flutter/material.dart';

/// Brand colours taken from the Khabo Ki? poster.
class KColors {
  static const olive = Color(0xFF4B5E1A);
  static const leaf = Color(0xFF7BA428);
  static const cream = Color(0xFFF7F6EF);
  static const tomato = Color(0xFFE53935);
  static const amber = Color(0xFFF9A825);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: KColors.olive,
    primary: KColors.olive,
    secondary: KColors.leaf,
    error: KColors.tomato,
    surface: KColors.cream,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: KColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: KColors.cream,
      foregroundColor: KColors.olive,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: KColors.olive,
        fontSize: 22,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.06)),
      ),
    ),
  );
}

/// Colour for a 0–100 safety score.
Color scoreColor(int score) {
  if (score >= 75) return KColors.leaf;
  if (score >= 50) return KColors.amber;
  return KColors.tomato;
}
