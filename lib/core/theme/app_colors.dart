import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF3B82F6);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primarySoft = Color(0xFF38BDF8);
  static const Color aiAccent = Color(0xFF8B5CF6);
  static const Color aiAccentStrong = Color(0xFFD946EF);
  static const Color focusGlow = Color(0xFF22D3EE);
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFFB7185);

  static const Color background = Color(0xFF070A12);
  static const Color backgroundElevated = Color(0xFF0A0F1D);
  static const Color surface = Color(0xFF101522);
  static const Color surfaceVariant = Color(0xFF171E2F);
  static const Color surfaceGlass = Color(0x11FFFFFF);
  static const Color outline = Color(0x1BFFFFFF);
  static const Color divider = outline;
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xA8F8FAFC);
  static const Color textTertiary = Color(0x6EF8FAFC);

  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundLightTint = Color(0xFFEEF2FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightSoft = Color(0xFFF1F5F9);
  static const Color outlineLight = Color(0xFFE2E8F0);
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF64748B);
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color aiAccentLight = Color(0xFF7C3AED);
  static const Color focusGlowLight = Color(0xFF0891B2);

  static const Color backgroundDark = background;
  static const Color surfaceDark = surface;
  static const Color textPrimaryDark = textPrimary;
  static const Color textSecondaryDark = textSecondary;

  static Color backgroundFor(Brightness brightness) =>
      brightness == Brightness.dark ? background : backgroundLight;

  static Color surfaceFor(Brightness brightness) =>
      brightness == Brightness.dark ? surface : surfaceLight;

  static Color surfaceVariantFor(Brightness brightness) =>
      brightness == Brightness.dark ? surfaceVariant : surfaceLightSoft;

  static Color outlineFor(Brightness brightness) =>
      brightness == Brightness.dark ? outline : outlineLight;

  static Color textPrimaryFor(Brightness brightness) =>
      brightness == Brightness.dark ? textPrimary : textPrimaryLight;

  static Color textSecondaryFor(Brightness brightness) =>
      brightness == Brightness.dark ? textSecondary : textSecondaryLight;

  static Color textTertiaryFor(Brightness brightness) =>
      brightness == Brightness.dark ? textTertiary : textTertiaryLight;
}