import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Light Minimal type system (§3). Inter for all UI/body, Lora (serif) reserved
/// for exactly two hero moments — launch/auth titles and hero greetings /
/// identity names. Never use Lora for body, buttons, or nav.
///
/// Numbers are a typographic feature: salary, stats and match % use [number]
/// with tabular figures so digits stay aligned as they animate.
class AppTextStyles {
  const AppTextStyles._();

  static const String inter = 'Inter';
  static const String lora = 'Lora';

  // ---------------------------------------------------------------------------
  // Display / hero — Lora serif, the only two hero moments (§3).
  // ---------------------------------------------------------------------------
  static const TextStyle displayHero = TextStyle(
    fontFamily: lora,
    fontSize: 38,
    fontWeight: FontWeight.w600,
    height: 1.1,
    letterSpacing: -0.4,
  );

  static const TextStyle display = TextStyle(
    fontFamily: lora,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.15,
    letterSpacing: -0.2,
  );

  // ---------------------------------------------------------------------------
  // Inter UI roles.
  // ---------------------------------------------------------------------------
  static const TextStyle headline = TextStyle(
    fontFamily: inter,
    fontSize: 24,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.48, // −2%
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: inter,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle title = TextStyle(
    fontFamily: inter,
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  static const TextStyle body = TextStyle(
    fontFamily: inter,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  /// Tabular-figure numerals for salary, dashboard stats, and match scores.
  static const TextStyle number = TextStyle(
    fontFamily: inter,
    fontWeight: FontWeight.w800,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  static TextTheme textTheme(Brightness brightness) {
    final color = AppColors.textPrimaryFor(brightness);

    return const TextTheme(
      displayLarge: displayHero,
      displayMedium: display,
      headlineLarge: headline,
      headlineMedium: sectionTitle,
      titleLarge: title,
      titleMedium: bodyMedium,
      bodyLarge: body,
      bodyMedium: bodyMedium,
      bodySmall: bodySmall,
      labelLarge: label,
      labelMedium: caption,
      labelSmall: bodySmall,
    ).apply(
      bodyColor: color,
      displayColor: color,
    );
  }
}
