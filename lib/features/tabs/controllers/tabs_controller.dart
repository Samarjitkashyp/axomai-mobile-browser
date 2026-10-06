import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/core/theme/theme_controller.dart';
import 'package:axomai_browser_mobile/features/tabs/domain/browser_tab.dart';

/// State representation for open browser tabs and active session.
class TabsState {
  final List<BrowserTab> normalTabs;
  final List<BrowserTab> incognitoTabs;
  final String activeTabId;
  final bool isIncognitoMode;

  const TabsState({
    this.normalTabs = const [],
    this.incognitoTabs = const [],
    this.activeTabId = '',
    this.isIncognitoMode = false,
  });

  List<BrowserTab> get currentTabs =>
      isIncognitoMode ? incognitoTabs : normalTabs;

  BrowserTab? get activeTab {
    final list = currentTabs;
    if (list.isEmpty) return null;
    try {
      return list.firstWhere((t) => t.id == activeTabId);
    } catch (_) {
      return list.isNotEmpty ? list.first : null;
    }
  }

  TabsState copyWith({
    List<BrowserTab>? normalTabs,
    List<BrowserTab>? incognitoTabs,
    String? activeTabId,
    bool? isIncognitoMode,
  }) {
    return TabsState(
      normalTabs: normalTabs ?? this.normalTabs,
      incognitoTabs: incognitoTabs ?? this.incognitoTabs,
      activeTabId: activeTabId ?? this.activeTabId,
      isIncognitoMode: isIncognitoMode ?? this.isIncognitoMode,
    );
  }
}

/// Controller managing browser tabs and persistence.
class TabsNotifier extends StateNotifier<TabsState> {
  final SharedPreferences? _prefs;
  static const String _keySavedTabs = 'axomai_saved_tabs';
  static const String _keyActiveTabId = 'axomai_active_tab_id';

  TabsNotifier(this._prefs) : super(const TabsState()) {
    _restoreTabs();
  }

  void _restoreTabs() {
    final prefs = _prefs;
    if (prefs == null) {
      _initDefaultTab();
      return;
    }

    final rawJson = prefs.getString(_keySavedTabs);
    final savedActiveId = prefs.getString(_keyActiveTabId);

    if (rawJson != null && rawJson.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
        final restored = decoded
            .map((item) => BrowserTab.fromJson(item as Map<String, dynamic>))
            .where(
              (tab) => !tab.isIncognito,
            ) // Safety: ensure no incognito tabs
            .toList();

        if (restored.isNotEmpty) {
          final activeId =
              (savedActiveId != null &&
                  restored.any((t) => t.id == savedActiveId))
              ? savedActiveId
              : restored.first.id;

          state = TabsState(
            normalTabs: restored,
            activeTabId: activeId,
            isIncognitoMode: false,
          );
          return;
        }
      } catch (_) {
        // Fallback on decode error
      }
    }

    _initDefaultTab();
  }

  void _initDefaultTab() {
    final initialTab = BrowserTab(
      id: _generateId(),
      url: '',
      title: 'New Tab',
      createdAt: DateTime.now(),
    );

    state = TabsState(
      normalTabs: [initialTab],
      activeTabId: initialTab.id,
      isIncognitoMode: false,
    );
    _saveTabs();
  }

  static int _idCounter = 0;

  String _generateId() {
    _idCounter++;
    return 'tab_${DateTime.now().microsecondsSinceEpoch}_$_idCounter';
  }

  Future<void> _saveTabs() async {
    final prefs = _prefs;
    if (prefs == null) return;

    // Filter out any incognito tabs before saving
    final toSave = state.normalTabs.where((t) => !t.isIncognito).toList();
    final jsonString = jsonEncode(toSave.map((t) => t.toJson()).toList());

    await prefs.setString(_keySavedTabs, jsonString);
    if (!state.isIncognitoMode) {
      await prefs.setString(_keyActiveTabId, state.activeTabId);
    }
  }

  BrowserTab createNewTab({
    bool? isIncognito,
    String initialUrl = '',
    String title = 'New Tab',
  }) {
    final incognito = isIncognito ?? state.isIncognitoMode;
    final newTab = BrowserTab(
      id: _generateId(),
      url: initialUrl,
      title: title,
      isIncognito: incognito,
      createdAt: DateTime.now(),
    );

    if (incognito) {
      final updated = [...state.incognitoTabs, newTab];
      state = state.copyWith(
        incognitoTabs: updated,
        activeTabId: newTab.id,
        isIncognitoMode: true,
      );
    } else {
      final updated = [...state.normalTabs, newTab];
      state = state.copyWith(
        normalTabs: updated,
        activeTabId: newTab.id,
        isIncognitoMode: false,
      );
      _saveTabs();
    }

    return newTab;
  }

  void closeTab(String tabId) {
    if (state.isIncognitoMode) {
      final updated = state.incognitoTabs.where((t) => t.id != tabId).toList();
      String newActiveId = state.activeTabId;

      if (state.activeTabId == tabId) {
        newActiveId = updated.isNotEmpty ? updated.last.id : '';
      }

      if (updated.isEmpty) {
        // If all incognito tabs closed, switch back to normal tabs
        state = state.copyWith(
          incognitoTabs: [],
          isIncognitoMode: false,
          activeTabId: state.normalTabs.isNotEmpty
              ? state.normalTabs.last.id
              : '',
        );
      } else {
        state = state.copyWith(
          incognitoTabs: updated,
          activeTabId: newActiveId,
        );
      }
    } else {
      final updated = state.normalTabs.where((t) => t.id != tabId).toList();

      if (updated.isEmpty) {
        // Always keep at least one tab open
        _initDefaultTab();
        return;
      }

      String newActiveId = state.activeTabId;
      if (state.activeTabId == tabId) {
        newActiveId = updated.last.id;
      }

      state = state.copyWith(normalTabs: updated, activeTabId: newActiveId);
      _saveTabs();
    }
  }

  void closeAllTabs({bool incognitoOnly = false}) {
    if (incognitoOnly || state.isIncognitoMode) {
      state = state.copyWith(
        incognitoTabs: [],
        isIncognitoMode: false,
        activeTabId: state.normalTabs.isNotEmpty
            ? state.normalTabs.last.id
            : '',
      );
    } else {
      _initDefaultTab();
    }
  }

  void selectTab(String tabId) {
    state = state.copyWith(activeTabId: tabId);
    if (!state.isIncognitoMode) {
      _saveTabs();
    }
  }

  void setIncognitoMode(bool isIncognito) {
    if (isIncognito && state.incognitoTabs.isEmpty) {
      // If switching to incognito and no tabs exist, create one
      createNewTab(isIncognito: true);
      return;
    }

    final targetList = isIncognito ? state.incognitoTabs : state.normalTabs;
    final nextActiveId = targetList.isNotEmpty ? targetList.last.id : '';

    state = state.copyWith(
      isIncognitoMode: isIncognito,
      activeTabId: nextActiveId,
    );
  }

  void updateActiveTabInfo({
    required String url,
    required String title,
    String? faviconUrl,
  }) {
    if (state.activeTabId.isEmpty) return;

    if (state.isIncognitoMode) {
      final updated = state.incognitoTabs.map((t) {
        if (t.id == state.activeTabId) {
          return t.copyWith(
            url: url,
            title: title.isNotEmpty
                ? title
                : (url.isNotEmpty ? url : 'New Tab'),
            faviconUrl: faviconUrl ?? t.faviconUrl,
          );
        }
        return t;
      }).toList();
      state = state.copyWith(incognitoTabs: updated);
    } else {
      final updated = state.normalTabs.map((t) {
        if (t.id == state.activeTabId) {
          return t.copyWith(
            url: url,
            title: title.isNotEmpty
                ? title
                : (url.isNotEmpty ? url : 'New Tab'),
            faviconUrl: faviconUrl ?? t.faviconUrl,
          );
        }
        return t;
      }).toList();
      state = state.copyWith(normalTabs: updated);
      _saveTabs();
    }
  }
}

/// Provider exposing tabs management state.
final tabsControllerProvider = StateNotifierProvider<TabsNotifier, TabsState>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TabsNotifier(prefs);
});
