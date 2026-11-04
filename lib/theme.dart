import 'package:flutter/material.dart';

/// Brand colours taken from the app icon.
class KColors {
  static const green = Color(0xFF3F9A12);
  static const greenLight = Color(0xFF7BC41A);
  static const greenDark = Color(0xFF2E7D0F);
  static const deep = Color(0xFF1F5E0A);
  static const lime = Color(0xFF9BE22A);
  static const mint = Color(0xFFEAF5DD); // soft green fill for chips and tiles
  static const cream = Color(0xFFF7F6EF);
  static const ink = Color(0xFF1C2416);
  static const muted = Color(0xFF6B7363);
  static const fresh = Color(0xFF43A047);
  static const amber = Color(0xFFF9A825);
  static const tomato = Color(0xFFE53935);
  static const blush = Color(0xFFFDECEC); // soft red fill for risk cards
}

const kBrandGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [KColors.greenLight, KColors.greenDark],
);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: KColors.green,
    primary: KColors.greenDark,
    secondary: KColors.lime,
    error: KColors.tomato,
    surface: KColors.cream,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: KColors.cream,
    appBarTheme: const AppBarTheme(
      backgroundColor: KColors.cream,
      foregroundColor: KColors.ink,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: KColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: KColors.greenDark,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: KColors.mint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

/// Colour for a 0–100 safety score.
Color scoreColor(int score) {
  if (score >= 75) return KColors.fresh;
  if (score >= 50) return KColors.amber;
  return KColors.tomato;
}
