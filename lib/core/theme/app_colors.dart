import 'package:flutter/material.dart';

/// Light Minimal color system (ratified 2026-06-11).
///
/// See `docs/design/JOB_CONNECT_UI_SYSTEM.md` §2. Monochrome ink/gray surfaces
/// with exactly one accent (orange). Dark mode is a pure derivation — same app
/// with the lights off; the accent stays full saturation, never dimmed.
///
/// Prefer the brightness-aware accessors (`surfaceFor`, `inkFor`, …) in new
/// code. The legacy unsuffixed names below resolve to the LIGHT value (light is
/// now the default) and exist so pre-redesign widgets keep compiling; they are
/// migrated to the accessors during the UI-11 → UI-14 screen sweeps.
class AppColors {
  const AppColors._();

  // ---------------------------------------------------------------------------
  // Brand accent — THE one color. Identical in both modes (§2 "orange rule").
  // ---------------------------------------------------------------------------
  static const Color accent = Color(0xFFF97316);
  static const Color onAccent = Color(0xFFFFFFFF);
  static const Color accentSoft = Color(0xFFFFF4EA); // rare tinted fill (light)
  static const Color accentSoftDark = Color(0xFF2A1C10); // tinted fill (dark)

  // ---------------------------------------------------------------------------
  // Neutral palette — light (default)
  // ---------------------------------------------------------------------------
  static const Color canvas = Color(0xFFFAFAFA); // main background
  static const Color surface = Color(0xFFFFFFFF); // cards, sheets, bars
  static const Color surfaceVariant = Color(0xFFF4F4F5); // fills, tags
  static const Color ink = Color(0xFF111113); // primary text
  static const Color gray600 = Color(0xFF52525B); // supporting text
  static const Color gray400 = Color(0xFFA1A1AA); // metadata, placeholders
  static const Color hairline = Color(0xFFE4E4E7); // all 1px borders/dividers

  // ---------------------------------------------------------------------------
  // Neutral palette — dark (pure derivation)
  // ---------------------------------------------------------------------------
  static const Color canvasDark = Color(0xFF0F0F0F); // warm near-black
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color surfaceVariantDark = Color(0xFF242427);
  static const Color inkDark = Color(0xFFF5F5F5);
  static const Color gray600Dark = Color(0xFFB0B0B8);
  static const Color gray400Dark = Color(0xFF6E6E76);
  static const Color hairlineDark = Color(0x17FFFFFF); // ~9% white

  // ---------------------------------------------------------------------------
  // Status — dot/text only (§7). Light values are the defaults; dark variants
  // lift brightness so dots read on the warm near-black canvas.
  // ---------------------------------------------------------------------------
  static const Color success = Color(0xFF059669);
  static const Color successDark = Color(0xFF10B981);
  static const Color error = Color(0xFFDC2626);
  static const Color errorDark = Color(0xFFF87171);
  static const Color warning = Color(0xFFD97706); // amber — text only
  static const Color warningDark = Color(0xFFF59E0B);

  // ---------------------------------------------------------------------------
  // Legacy aliases — kept so pre-redesign widgets compile. They map onto the
  // new tokens (light values, since light is the default mode). Migrate call
  // sites to the accessors / new names during UI-11 → UI-14.
  // ---------------------------------------------------------------------------
  static const Color primary = accent;
  static const Color primaryLight = accent;
  static const Color onPrimary = onAccent;
  static const Color primarySoft = Color(0xFFFB923C);
  static const Color aiAccent = accent;
  static const Color aiAccentLight = accent;
  static const Color aiAccentStrong = Color(0xFFEA580C);
  static const Color focusGlow = accent;
  static const Color focusGlowLight = accent;

  static const Color background = canvas;
  static const Color backgroundLight = canvas;
  static const Color backgroundLightTint = Color(0xFFF4F4F5);
  static const Color backgroundElevated = surface;
  static const Color backgroundDark = canvasDark;
  static const Color surfaceLight = surface;
  static const Color surfaceLightSoft = surfaceVariant;
  static const Color surfaceGlass = Color(0x0A111113);

  static const Color outline = hairline;
  static const Color outlineLight = hairline;
  static const Color divider = hairline;

  static const Color textPrimary = ink;
  static const Color textPrimaryLight = ink;
  static const Color textPrimaryDark = inkDark;
  static const Color textSecondary = gray600;
  static const Color textSecondaryLight = gray600;
  static const Color textSecondaryDark = gray600Dark;
  static const Color textTertiary = gray400;
  static const Color textTertiaryLight = gray400;

  // ---------------------------------------------------------------------------
  // Brightness-aware accessors — the preferred API.
  // ---------------------------------------------------------------------------
  static Color canvasFor(Brightness b) =>
      b == Brightness.dark ? canvasDark : canvas;

  static Color backgroundFor(Brightness b) => canvasFor(b);

  static Color surfaceFor(Brightness b) =>
      b == Brightness.dark ? surfaceDark : surface;

  static Color surfaceVariantFor(Brightness b) =>
      b == Brightness.dark ? surfaceVariantDark : surfaceVariant;

  static Color hairlineFor(Brightness b) =>
      b == Brightness.dark ? hairlineDark : hairline;

  static Color outlineFor(Brightness b) => hairlineFor(b);

  static Color inkFor(Brightness b) => b == Brightness.dark ? inkDark : ink;

  static Color textPrimaryFor(Brightness b) => inkFor(b);

  static Color gray600For(Brightness b) =>
      b == Brightness.dark ? gray600Dark : gray600;

  static Color textSecondaryFor(Brightness b) => gray600For(b);

  static Color gray400For(Brightness b) =>
      b == Brightness.dark ? gray400Dark : gray400;

  static Color textTertiaryFor(Brightness b) => gray400For(b);

  static Color accentSoftFor(Brightness b) =>
      b == Brightness.dark ? accentSoftDark : accentSoft;

  static Color successFor(Brightness b) =>
      b == Brightness.dark ? successDark : success;

  static Color errorFor(Brightness b) =>
      b == Brightness.dark ? errorDark : error;

  static Color warningFor(Brightness b) =>
      b == Brightness.dark ? warningDark : warning;
}
