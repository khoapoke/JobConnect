import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_durations.dart';
import 'app_gradients.dart';
import 'app_radii.dart';
import 'app_shadows.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _buildTheme(Brightness.light);

  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = AppColors.backgroundFor(brightness);
    final surface = AppColors.surfaceFor(brightness);
    final surfaceVariant = AppColors.surfaceVariantFor(brightness);
    final outline = AppColors.outlineFor(brightness);
    final onSurface = AppColors.textPrimaryFor(brightness);
    final onSurfaceVariant = AppColors.textSecondaryFor(brightness);
    final primary = isDark ? AppColors.primary : AppColors.primaryLight;
    final secondary = isDark ? AppColors.aiAccent : AppColors.aiAccentLight;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: AppColors.onPrimary,
      secondary: secondary,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outline,
      shadow: Colors.black,
      scrim: Colors.black.withValues(alpha: 0.5),
      inverseSurface: isDark ? AppColors.surfaceLight : AppColors.surface,
      onInverseSurface: isDark ? AppColors.textPrimaryLight : AppColors.textPrimary,
      inversePrimary: isDark ? AppColors.primaryLight : AppColors.primary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      splashFactory: NoSplash.splashFactory,
      fontFamily: AppTextStyles.inter,
      textTheme: AppTextStyles.textTheme(brightness),
      dividerColor: outline,
      cardColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTextStyles.title.copyWith(color: onSurface),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.lg,
          side: BorderSide(color: outline),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surface : AppColors.surfaceLight,
        height: 76,
        labelTextStyle: WidgetStatePropertyAll(
          AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            height: 1.05,
          ),
        ),
        indicatorColor: primary.withValues(alpha: isDark ? 0.18 : 0.12),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? primary : onSurfaceVariant,
            size: 22,
          );
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surface : AppColors.surfaceLight,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        selectedLabelStyle: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          height: 1.05,
        ),
        unselectedLabelStyle: AppTextStyles.bodySmall.copyWith(
          fontSize: 11,
          height: 1.05,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          backgroundColor: primary,
          foregroundColor: Colors.white,
          textStyle: AppTextStyles.label,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.md),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          foregroundColor: onSurface,
          textStyle: AppTextStyles.label,
          side: BorderSide(color: outline),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.md),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space4,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: AppRadii.lg,
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.lg,
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.lg,
          borderSide: BorderSide(color: primary, width: 1.4),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.lg,
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadii.lg,
          borderSide: BorderSide(color: AppColors.error, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primary.withValues(alpha: isDark ? 0.18 : 0.12),
        disabledColor: surfaceVariant,
        side: BorderSide(color: outline),
        labelStyle: AppTextStyles.bodySmall.copyWith(color: onSurface),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.md),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.xl),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceVariant,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.xl),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: surface,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: onSurface),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.md),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      extensions: [
        _AppThemeExtras(
          backgroundGradient:
              isDark ? AppGradients.darkBackground : AppGradients.lightBackground,
          surfaceShadow: isDark ? AppShadows.card : const [],
          animationDuration: AppDurations.base,
        ),
      ],
    );
  }
}

@immutable
class _AppThemeExtras extends ThemeExtension<_AppThemeExtras> {
  const _AppThemeExtras({
    required this.backgroundGradient,
    required this.surfaceShadow,
    required this.animationDuration,
  });

  final Gradient backgroundGradient;
  final List<BoxShadow> surfaceShadow;
  final Duration animationDuration;

  @override
  ThemeExtension<_AppThemeExtras> copyWith({
    Gradient? backgroundGradient,
    List<BoxShadow>? surfaceShadow,
    Duration? animationDuration,
  }) {
    return _AppThemeExtras(
      backgroundGradient: backgroundGradient ?? this.backgroundGradient,
      surfaceShadow: surfaceShadow ?? this.surfaceShadow,
      animationDuration: animationDuration ?? this.animationDuration,
    );
  }

  @override
  ThemeExtension<_AppThemeExtras> lerp(
    covariant ThemeExtension<_AppThemeExtras>? other,
    double t,
  ) {
    if (other is! _AppThemeExtras) return this;
    return t < 0.5 ? this : other;
  }
}
