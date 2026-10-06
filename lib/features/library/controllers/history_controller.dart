import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/library/controllers/bookmarks_controller.dart';
import 'package:axomai_browser_mobile/features/library/data/database_helper.dart';
import 'package:axomai_browser_mobile/features/library/domain/history_item.dart';

/// State representation for Browsing History.
class HistoryState {
  final List<HistoryItem> items;
  final String searchQuery;
  final bool isLoading;

  const HistoryState({
    this.items = const [],
    this.searchQuery = '',
    this.isLoading = false,
  });

  /// Groups items by human-friendly date headers.
  Map<String, List<HistoryItem>> get groupedItems {
    final Map<String, List<HistoryItem>> groups = {
      'Today': [],
      'Yesterday': [],
      'Last 7 Days': [],
      'Older': [],
    };

    for (final item in items) {
      final group = item.dateGroup;
      groups[group]?.add(item);
    }

    // Remove empty groups
    groups.removeWhere((key, value) => value.isEmpty);
    return groups;
  }

  HistoryState copyWith({
    List<HistoryItem>? items,
    String? searchQuery,
    bool? isLoading,
  }) {
    return HistoryState(
      items: items ?? this.items,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Controller managing browsing history logging, search, and cleanup.
class HistoryNotifier extends StateNotifier<HistoryState> {
  final DatabaseHelper _dbHelper;

  HistoryNotifier(this._dbHelper) : super(const HistoryState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);
    final history = await _dbHelper.getAllHistory();
    state = state.copyWith(items: history, isLoading: false);
  }

  Future<void> addVisit({
    required String url,
    required String title,
    bool isIncognito = false,
  }) async {
    // Privacy guarantee: Never record history for Incognito sessions or empty home URLs
    if (isIncognito || url.trim().isEmpty || url.startsWith('about:')) {
      return;
    }

    final item = HistoryItem(
      title: title.isNotEmpty ? title : url,
      url: url,
      visitedAt: DateTime.now(),
    );

    await _dbHelper.insertHistory(item);
    await loadHistory();
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, isLoading: true);
    if (query.trim().isEmpty) {
      final items = await _dbHelper.getAllHistory();
      state = state.copyWith(items: items, isLoading: false);
    } else {
      final items = await _dbHelper.searchHistory(query);
      state = state.copyWith(items: items, isLoading: false);
    }
  }

  Future<void> deleteHistoryItem(int id) async {
    await _dbHelper.deleteHistoryItem(id);
    if (state.searchQuery.isNotEmpty) {
      await search(state.searchQuery);
    } else {
      await loadHistory();
    }
  }

  Future<void> clearAllHistory() async {
    await _dbHelper.clearAllHistory();
    state = state.copyWith(items: [], searchQuery: '');
  }
}

/// Provider exposing History state.
final historyControllerProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
      final dbHelper = ref.watch(databaseHelperProvider);
      return HistoryNotifier(dbHelper);
    });
