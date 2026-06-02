import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppGradients {
  const AppGradients._();

  static const LinearGradient darkBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.backgroundElevated,
      AppColors.background,
      AppColors.background,
    ],
    stops: [0, 0.52, 1],
  );

  static const LinearGradient lightBackground = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.backgroundLightTint,
      AppColors.backgroundLight,
      Color(0xFFFFFFFF),
    ],
  );

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.primary,
      AppColors.primarySoft,
    ],
  );

  static const LinearGradient ai = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.aiAccent,
      AppColors.aiAccentStrong,
    ],
  );

  static const LinearGradient connectionLoop = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.focusGlow,
      AppColors.primary,
      AppColors.aiAccent,
    ],
  );

  static final LinearGradient skeleton = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Colors.white.withValues(alpha: 0.0),
      Colors.white.withValues(alpha: 0.16),
      Colors.white.withValues(alpha: 0.0),
    ],
  );
}