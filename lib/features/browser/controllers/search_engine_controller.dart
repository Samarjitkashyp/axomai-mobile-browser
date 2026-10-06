import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/core/theme/theme_controller.dart';
import 'package:axomai_browser_mobile/features/browser/domain/search_engine.dart';

/// Notifier for default search engine preference.
class SearchEngineNotifier extends StateNotifier<SearchEngine> {
  final SharedPreferences? _prefs;
  static const String _keySearchEngine = 'axomai_default_search_engine';

  SearchEngineNotifier(this._prefs) : super(SearchEngine.google) {
    _loadFromPrefs();
  }

  void _loadFromPrefs() {
    final prefs = _prefs;
    if (prefs == null) return;
    final engineId = prefs.getString(_keySearchEngine);
    if (engineId != null) {
      for (final engine in SearchEngine.values) {
        if (engine.id == engineId) {
          state = engine;
          break;
        }
      }
    }
  }

  Future<void> setSearchEngine(SearchEngine engine) async {
    state = engine;
    final prefs = _prefs;
    if (prefs != null) {
      await prefs.setString(_keySearchEngine, engine.id);
    }
  }
}

/// Provider exposing the active search engine.
final searchEngineControllerProvider =
    StateNotifierProvider<SearchEngineNotifier, SearchEngine>((ref) {
      final prefs = ref.watch(sharedPreferencesProvider);
      return SearchEngineNotifier(prefs);
    });
