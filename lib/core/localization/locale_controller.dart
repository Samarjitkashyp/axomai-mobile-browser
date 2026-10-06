import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/core/theme/theme_controller.dart';

/// Supported locales in Axomai Browser.
abstract final class SupportedLocales {
  static const List<Locale> all = [
    Locale('en'),
    Locale('hi'),
    Locale('as'),
    Locale('bn'),
  ];

  static String getNativeName(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return 'हिन्दी (Hindi)';
      case 'as':
        return 'অসমীয়া (Assamese)';
      case 'bn':
        return 'বাংলা (Bengali)';
      case 'en':
      default:
        return 'English';
    }
  }
}

/// Notifier managing application locale switching and persistence.
class LocaleNotifier extends StateNotifier<Locale?> {
  final SharedPreferences? _prefs;
  static const String _keyLocale = 'axomai_selected_locale';

  LocaleNotifier(this._prefs) : super(null) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final prefs = _prefs;
    if (prefs == null) return;
    final langCode = prefs.getString(_keyLocale);
    if (langCode != null) {
      state = Locale(langCode);
    }
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    final prefs = _prefs;
    if (prefs != null) {
      if (locale != null) {
        await prefs.setString(_keyLocale, locale.languageCode);
      } else {
        await prefs.remove(_keyLocale);
      }
    }
  }
}

/// Provider exposing the selected locale.
final localeControllerProvider = StateNotifierProvider<LocaleNotifier, Locale?>(
  (ref) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return LocaleNotifier(prefs);
  },
);
