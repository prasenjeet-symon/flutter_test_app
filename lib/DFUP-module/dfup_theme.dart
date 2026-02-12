// lib/dfup_theme.dart

import 'package:flutter/material.dart';

class Cx {
  final bool isDark;
  Cx._(this.isDark);
  static Cx of(BuildContext context) => Cx._(Theme.of(context).brightness == Brightness.dark);

  Color get primary       => const Color(0xFF6C5CE7);
  Color get primaryLight  => isDark ? const Color(0xFF9B8FEF) : const Color(0xFFB8B0F5);
  Color get primaryDark   => const Color(0xFF4A3DB5);
  Color get primarySurface=> isDark ? primary.withValues(alpha: 0.15) : primary.withValues(alpha: 0.06);

  Color get surface       => isDark ? const Color(0xFF0F0F1A) : const Color(0xFFF8F9FE);
  Color get card          => isDark ? const Color(0xFF1A1A2E) : Colors.white;
  Color get elevated      => isDark ? const Color(0xFF242442) : const Color(0xFFF0F1FA);
  Color get inputFill     => isDark ? const Color(0xFF1E1E36) : Colors.white;
  Color get sheetBg       => isDark ? const Color(0xFF1A1A2E) : Colors.white;

  Color get accent  => const Color(0xFF00C9A7);
  Color get error   => isDark ? const Color(0xFFFF6B8A) : const Color(0xFFE74C6F);
  Color get warning => const Color(0xFFFFA94D);
  Color get success => const Color(0xFF51CF66);
  Color get info    => const Color(0xFF339AF0);

  Color get text1   => isDark ? const Color(0xFFE8E8F0) : const Color(0xFF1A1A2E);
  Color get text2   => isDark ? const Color(0xFF9CA3B0) : const Color(0xFF6B7280);
  Color get hint    => isDark ? const Color(0xFF5A6070) : const Color(0xFFA0AEC0);
  Color get onPrimary => Colors.white;

  Color get border  => isDark ? const Color(0xFF2E2E4A) : const Color(0xFFE2E8F0);
  Color get divider => isDark ? const Color(0xFF2A2A42) : const Color(0xFFEDF2F7);

  List<BoxShadow> get cardShadow => isDark
      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
      : [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4)),
         BoxShadow(color: primary.withValues(alpha: 0.03), blurRadius: 24, offset: const Offset(0, 8))];

  List<BoxShadow> get elevatedShadow => isDark
      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))]
      : [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8))];

  Color get chipSelectedBg => isDark ? primary.withValues(alpha: 0.25) : primary;
  Color get chipSelectedText => isDark ? primaryLight : Colors.white;
  Color get chipBg => isDark ? elevated : Colors.white;
  Color get chipBorder => isDark ? const Color(0xFF363658) : const Color(0xFFE2E8F0);
}

class S {
  static const double xs = 4, sm = 8, md = 12, lg = 16, xl = 24, xxl = 32, xxxl = 48;
}

class R {
  static const double sm = 8, md = 12, lg = 16, xl = 20, pill = 100;
}

class DfupTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dk = brightness == Brightness.dark;
    final c = Cx._(dk);
    return ThemeData(
      useMaterial3: true, brightness: brightness,
      colorScheme: ColorScheme.fromSeed(seedColor: c.primary, brightness: brightness, primary: c.primary, onPrimary: c.onPrimary, surface: c.surface, error: c.error),
      scaffoldBackgroundColor: c.surface,
      appBarTheme: AppBarTheme(backgroundColor: c.card, foregroundColor: c.text1, elevation: 0, centerTitle: false, scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: c.text1)),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: c.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: S.lg, vertical: S.md),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(R.md), borderSide: BorderSide(color: c.border, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.md), borderSide: BorderSide(color: c.border, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.md), borderSide: BorderSide(color: c.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.md), borderSide: BorderSide(color: c.error, width: 1.5)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(R.md), borderSide: BorderSide(color: c.error, width: 2)),
        labelStyle: TextStyle(color: c.text2, fontSize: 14, fontWeight: FontWeight.w500),
        hintStyle: TextStyle(color: c.hint, fontSize: 14),
        errorStyle: TextStyle(color: c.error, fontSize: 12, fontWeight: FontWeight.w500)),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ElevatedButton.styleFrom(backgroundColor: c.primary, foregroundColor: c.onPrimary, elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: S.xl, vertical: S.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.md)),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: c.primary, textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
      cardTheme: CardThemeData(color: c.card, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(R.lg))),
      tabBarTheme: TabBarThemeData(labelColor: c.primary, unselectedLabelColor: c.text2, indicatorColor: c.primary,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: c.sheetBg,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(R.xl)))),
      dividerTheme: DividerThemeData(color: c.divider, space: 1, thickness: 1),
    );
  }
}
