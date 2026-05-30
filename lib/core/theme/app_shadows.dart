import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  const AppShadows._();

  static final List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.18),
      blurRadius: 50,
      offset: const Offset(0, 16),
    ),
  ];

  static final List<BoxShadow> featured = [
    BoxShadow(
      color: AppColors.primary.withValues(alpha: 0.14),
      blurRadius: 90,
      offset: const Offset(0, 28),
    ),
  ];

  static final List<BoxShadow> overlay = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.46),
      blurRadius: 100,
      offset: const Offset(0, 34),
    ),
  ];

  static final List<BoxShadow> focusGlow = [
    BoxShadow(
      color: AppColors.focusGlow.withValues(alpha: 0.24),
      blurRadius: 24,
      spreadRadius: 1,
    ),
  ];
}