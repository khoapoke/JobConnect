import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_mode_provider.g.dart';

/// App theme mode: follows the system setting by default, with a manual
/// override that persists across launches (§2 dark-mode rules).
///
/// Settings UI to toggle the override lands with Profile work (UI-13); this is
/// the provider/plumbing it will drive.
@riverpod
class ThemeModeController extends _$ThemeModeController {
  static const _storageKey = 'theme_mode';
  static const _storage = FlutterSecureStorage();

  @override
  ThemeMode build() {
    _restore();
    return ThemeMode.system;
  }

  Future<void> _restore() async {
    final saved = await _storage.read(key: _storageKey);
    final restored = _parse(saved);
    if (restored != null && restored != state) {
      state = restored;
    }
  }

  /// Set the theme mode and persist the choice.
  Future<void> setMode(ThemeMode mode) async {
    if (mode == state) return;
    state = mode;
    await _storage.write(key: _storageKey, value: mode.name);
  }

  static ThemeMode? _parse(String? value) => switch (value) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => null,
      };
}
