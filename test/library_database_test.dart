import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:axomai_browser_mobile/features/library/data/database_helper.dart';
import 'package:axomai_browser_mobile/features/library/controllers/bookmarks_controller.dart';
import 'package:axomai_browser_mobile/features/library/controllers/history_controller.dart';
import 'package:axomai_browser_mobile/features/library/domain/history_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite FFI for unit test runner
  sqfliteFfiInit();

  late DatabaseHelper dbHelper;

  setUp(() async {
    dbHelper = DatabaseHelper(factory: databaseFactoryFfi);
    final db = await dbHelper.database;
    await db.delete('bookmarks');
    await db.delete('history');
    await db.delete('downloads');
  });

  group('Bookmarks SQLite & Controller Unit Tests', () {
    test(
      'Adds, checks isBookmarked, filters by folder, and removes bookmark',
      () async {
        final notifier = BookmarksNotifier(dbHelper);

        // Add 2 bookmarks in different folders
        await notifier.addBookmark(
          title: 'Google Search',
          url: 'https://www.google.com',
          folder: 'Search Engines',
        );

        await notifier.addBookmark(
          title: 'Assam Govt Portal',
          url: 'https://assam.gov.in',
          folder: 'Government',
        );

        expect(notifier.state.bookmarks.length, 2);
        expect(
          await notifier.isUrlBookmarked('https://www.google.com'),
          isTrue,
        );
        expect(
          await notifier.isUrlBookmarked('https://nonexistent.org'),
          isFalse,
        );

        // Verify folder list
        expect(notifier.state.folders.contains('Search Engines'), isTrue);
        expect(notifier.state.folders.contains('Government'), isTrue);

        // Test folder filtering
        notifier.filterByFolder('Search Engines');
        expect(notifier.state.filteredBookmarks.length, 1);
        expect(notifier.state.filteredBookmarks.first.title, 'Google Search');

        // Clear filter
        notifier.filterByFolder(null);
        expect(notifier.state.filteredBookmarks.length, 2);

        // Remove bookmark by url
        await notifier.removeBookmarkByUrl('https://www.google.com');
        expect(notifier.state.bookmarks.length, 1);
        expect(
          await notifier.isUrlBookmarked('https://www.google.com'),
          isFalse,
        );
      },
    );
  });

  group('History SQLite & Privacy Unit Tests', () {
    test(
      'Logs regular browsing history and correctly performs search',
      () async {
        final notifier = HistoryNotifier(dbHelper);

        await notifier.addVisit(
          url: 'https://flutter.dev/docs',
          title: 'Flutter Documentation',
          isIncognito: false,
        );

        await notifier.addVisit(
          url: 'https://en.wikipedia.org/wiki/Assam',
          title: 'Assam - Wikipedia',
          isIncognito: false,
        );

        expect(notifier.state.items.length, 2);

        // Test search
        await notifier.search('Wikipedia');
        expect(notifier.state.items.length, 1);
        expect(notifier.state.items.first.title, 'Assam - Wikipedia');

        // Test reset search
        await notifier.search('');
        expect(notifier.state.items.length, 2);
      },
    );

    test('Incognito visits are NEVER logged to History database', () async {
      final notifier = HistoryNotifier(dbHelper);

      // Add incognito visit
      await notifier.addVisit(
        url: 'https://incognito-test.org',
        title: 'Incognito Visit',
        isIncognito: true, // Private!
      );

      expect(notifier.state.items.isEmpty, isTrue);

      final dbItems = await dbHelper.getAllHistory();
      expect(dbItems.isEmpty, isTrue);
    });

    test('Date grouping accurately categorizes History timestamps', () {
      final now = DateTime.now();

      final todayItem = HistoryItem(
        title: 'Today Site',
        url: 'https://today.com',
        visitedAt: now,
      );

      final yesterdayItem = HistoryItem(
        title: 'Yesterday Site',
        url: 'https://yesterday.com',
        visitedAt: now.subtract(const Duration(days: 1)),
      );

      final weekItem = HistoryItem(
        title: 'Week Site',
        url: 'https://week.com',
        visitedAt: now.subtract(const Duration(days: 3)),
      );

      final oldItem = HistoryItem(
        title: 'Old Site',
        url: 'https://old.com',
        visitedAt: now.subtract(const Duration(days: 15)),
      );

      expect(todayItem.dateGroup, 'Today');
      expect(yesterdayItem.dateGroup, 'Yesterday');
      expect(weekItem.dateGroup, 'Last 7 Days');
      expect(oldItem.dateGroup, 'Older');
    });

    test('Clear all history removes all entries from database', () async {
      final notifier = HistoryNotifier(dbHelper);

      await notifier.addVisit(
        url: 'https://test1.org',
        title: 'Test 1',
        isIncognito: false,
      );
      await notifier.addVisit(
        url: 'https://test2.org',
        title: 'Test 2',
        isIncognito: false,
      );
      expect(notifier.state.items.length, 2);

      await notifier.clearAllHistory();
      expect(notifier.state.items.isEmpty, isTrue);
      expect(notifier.state.groupedItems.isEmpty, isTrue);
    });
  });
}
