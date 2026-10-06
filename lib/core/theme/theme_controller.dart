import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/core/theme/app_theme_type.dart';

/// State representation for active theme preferences.
class ThemeState {
  final AppThemeType themeType;
  final ThemeMode themeMode;

  const ThemeState({
    this.themeType = AppThemeType.teaGarden,
    this.themeMode = ThemeMode.system,
  });

  ThemeState copyWith({AppThemeType? themeType, ThemeMode? themeMode}) {
    return ThemeState(
      themeType: themeType ?? this.themeType,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

/// SharedPreferences instance provider.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferences in main()');
});

/// Notifier managing theme switching and persistence.
class ThemeNotifier extends StateNotifier<ThemeState> {
  final SharedPreferences? _prefs;
  static const String _keyThemeType = 'axomai_theme_type';
  static const String _keyThemeMode = 'axomai_theme_mode';

  ThemeNotifier(this._prefs) : super(const ThemeState()) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final prefs = _prefs;
    if (prefs == null) return;

    final themeTypeStr = prefs.getString(_keyThemeType);
    final themeModeStr = prefs.getString(_keyThemeMode);

    AppThemeType type = AppThemeType.teaGarden;
    if (themeTypeStr != null) {
      for (final t in AppThemeType.values) {
        if (t.nameId == themeTypeStr) {
          type = t;
          break;
        }
      }
    }

    ThemeMode mode = ThemeMode.system;
    if (themeModeStr != null) {
      for (final m in ThemeMode.values) {
        if (m.name == themeModeStr) {
          mode = m;
          break;
        }
      }
    }

    state = ThemeState(themeType: type, themeMode: mode);
  }

  Future<void> setThemeType(AppThemeType type) async {
    state = state.copyWith(themeType: type);
    final prefs = _prefs;
    if (prefs != null) {
      await prefs.setString(_keyThemeType, type.nameId);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = _prefs;
    if (prefs != null) {
      await prefs.setString(_keyThemeMode, mode.name);
    }
  }
}

/// Provider exposing the active theme state.
final themeControllerProvider =
    StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return ThemeNotifier(prefs);
    });
