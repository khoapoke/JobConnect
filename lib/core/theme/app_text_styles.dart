import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const String inter = 'Inter';
  static const String spaceGrotesk = 'SpaceGrotesk';

  static const TextStyle displayHero = TextStyle(
    fontFamily: spaceGrotesk,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.05,
    letterSpacing: -1.2,
  );

  static const TextStyle display = TextStyle(
    fontFamily: spaceGrotesk,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -0.8,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: inter,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    height: 1.15,
    letterSpacing: -0.6,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontFamily: inter,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    height: 1.2,
    letterSpacing: -0.3,
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
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: inter,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontFamily: inter,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: inter,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static TextTheme textTheme(Brightness brightness) {
    final bodyColor = AppColors.textPrimaryFor(brightness);
    final displayColor = AppColors.textPrimaryFor(brightness);

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
      bodyColor: bodyColor,
      displayColor: displayColor,
    );
  }
}