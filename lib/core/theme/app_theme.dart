import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

/// Light Minimal Material theme (ratified 2026-06-11).
///
/// Light-first, monochrome surfaces with a single orange accent. Dark mode is a
/// pure derivation of the same tokens (§2). Most of the look arrives here and in
/// the shared primitives; feature screens are swept in UI-11 → UI-14.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _buildTheme(Brightness.light);

  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final canvas = AppColors.canvasFor(brightness);
    final surface = AppColors.surfaceFor(brightness);
    final surfaceVariant = AppColors.surfaceVariantFor(brightness);
    final hairline = AppColors.hairlineFor(brightness);
    final ink = AppColors.inkFor(brightness);
    final gray600 = AppColors.gray600For(brightness);
    final gray400 = AppColors.gray400For(brightness);
    final error = AppColors.errorFor(brightness);
    const accent = AppColors.accent; // identical in both modes (§2)

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: AppColors.onAccent,
      // The system is monochrome + one accent; secondary stays neutral ink so
      // stray Material widgets never introduce a second color.
      secondary: ink,
      onSecondary: surface,
      error: error,
      onError: AppColors.onAccent,
      surface: surface,
      onSurface: ink,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: gray600,
      outline: hairline,
      outlineVariant: hairline,
      shadow: AppColors.ink,
      scrim: AppColors.ink.withValues(alpha: 0.5),
      inverseSurface: isDark ? AppColors.surface : AppColors.surfaceDark,
      onInverseSurface: isDark ? AppColors.ink : AppColors.inkDark,
      inversePrimary: accent,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      splashFactory: NoSplash.splashFactory,
      fontFamily: AppTextStyles.inter,
      textTheme: AppTextStyles.textTheme(brightness),
      dividerColor: hairline,
      dividerTheme: DividerThemeData(
        color: hairline,
        thickness: 1,
        space: 1,
      ),
      cardColor: surface,
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: AppTextStyles.headline.copyWith(color: ink),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.card,
          side: BorderSide(color: hairline),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: Colors.transparent, // no pill — active = orange (§8)
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
            height: 1.1,
            color: selected ? accent : gray400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? accent : gray400,
            size: 24,
          );
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: gray400,
        selectedLabelStyle: AppTextStyles.caption.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 11,
          height: 1.1,
        ),
        unselectedLabelStyle: AppTextStyles.caption.copyWith(
          fontSize: 11,
          height: 1.1,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          backgroundColor: accent,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: surfaceVariant,
          disabledForegroundColor: gray400,
          textStyle: AppTextStyles.label,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
          elevation: 0,
          shadowColor: Colors.transparent,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          backgroundColor: accent,
          foregroundColor: AppColors.onAccent,
          textStyle: AppTextStyles.label,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          textStyle: AppTextStyles.label,
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
          foregroundColor: ink,
          textStyle: AppTextStyles.label,
          side: BorderSide(color: hairline),
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.space4,
          vertical: AppSpacing.space4,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: gray400),
        border: const OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: hairline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: accent, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadii.input,
          borderSide: BorderSide(color: error, width: 1.6),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: ink,
        disabledColor: surfaceVariant,
        side: BorderSide(color: hairline),
        labelStyle: AppTextStyles.bodySmall.copyWith(color: ink),
        secondaryLabelStyle: AppTextStyles.bodySmall.copyWith(color: surface),
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.pill),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.card,
          side: BorderSide(color: hairline),
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        titleTextStyle: AppTextStyles.title.copyWith(color: ink),
        contentTextStyle: AppTextStyles.body.copyWith(color: gray600),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.sheet),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: ink,
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(color: surface),
        actionTextColor: accent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.button),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
