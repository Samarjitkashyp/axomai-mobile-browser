import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/library/data/database_helper.dart';
import 'package:axomai_browser_mobile/features/library/domain/bookmark_item.dart';

/// DatabaseHelper instance provider.
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper();
});

/// State representation for Bookmarks.
class BookmarksState {
  final List<BookmarkItem> bookmarks;
  final List<String> folders;
  final String? selectedFolder;
  final bool isLoading;

  const BookmarksState({
    this.bookmarks = const [],
    this.folders = const ['Mobile Bookmarks'],
    this.selectedFolder,
    this.isLoading = false,
  });

  List<BookmarkItem> get filteredBookmarks {
    if (selectedFolder == null || selectedFolder!.isEmpty) {
      return bookmarks;
    }
    return bookmarks.where((b) => b.folder == selectedFolder).toList();
  }

  BookmarksState copyWith({
    List<BookmarkItem>? bookmarks,
    List<String>? folders,
    String? selectedFolder,
    bool clearFolderFilter = false,
    bool? isLoading,
  }) {
    return BookmarksState(
      bookmarks: bookmarks ?? this.bookmarks,
      folders: folders ?? this.folders,
      selectedFolder: clearFolderFilter
          ? null
          : (selectedFolder ?? this.selectedFolder),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Controller managing bookmark additions, removals, and folder filters.
class BookmarksNotifier extends StateNotifier<BookmarksState> {
  final DatabaseHelper _dbHelper;

  BookmarksNotifier(this._dbHelper) : super(const BookmarksState()) {
    loadBookmarks();
  }

  Future<void> loadBookmarks() async {
    state = state.copyWith(isLoading: true);
    final bookmarks = await _dbHelper.getAllBookmarks();
    final folders = await _dbHelper.getBookmarkFolders();
    state = state.copyWith(
      bookmarks: bookmarks,
      folders: folders,
      isLoading: false,
    );
  }

  void filterByFolder(String? folder) {
    if (folder == null) {
      state = state.copyWith(clearFolderFilter: true);
    } else {
      state = state.copyWith(selectedFolder: folder);
    }
  }

  Future<void> addBookmark({
    required String title,
    required String url,
    String folder = 'Mobile Bookmarks',
    String? faviconUrl,
  }) async {
    final newBookmark = BookmarkItem(
      title: title.isNotEmpty ? title : (url.isNotEmpty ? url : 'Bookmark'),
      url: url,
      folder: folder.isNotEmpty ? folder : 'Mobile Bookmarks',
      faviconUrl: faviconUrl,
      createdAt: DateTime.now(),
    );

    await _dbHelper.insertBookmark(newBookmark);
    await loadBookmarks();
  }

  Future<void> removeBookmark(int id) async {
    await _dbHelper.deleteBookmark(id);
    await loadBookmarks();
  }

  Future<void> removeBookmarkByUrl(String url) async {
    await _dbHelper.deleteBookmarkByUrl(url);
    await loadBookmarks();
  }

  Future<bool> isUrlBookmarked(String url) async {
    return await _dbHelper.isBookmarked(url);
  }

  Future<void> toggleBookmark({
    required String title,
    required String url,
    String folder = 'Mobile Bookmarks',
    String? faviconUrl,
  }) async {
    final bookmarked = await isUrlBookmarked(url);
    if (bookmarked) {
      await removeBookmarkByUrl(url);
    } else {
      await addBookmark(
        title: title,
        url: url,
        folder: folder,
        faviconUrl: faviconUrl,
      );
    }
  }
}

/// Provider exposing Bookmarks state.
final bookmarksControllerProvider =
    StateNotifierProvider<BookmarksNotifier, BookmarksState>((ref) {
      final dbHelper = ref.watch(databaseHelperProvider);
      return BookmarksNotifier(dbHelper);
    });
