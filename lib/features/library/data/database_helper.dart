import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:axomai_browser_mobile/features/library/domain/bookmark_item.dart';
import 'package:axomai_browser_mobile/features/library/domain/download_item.dart';
import 'package:axomai_browser_mobile/features/library/domain/history_item.dart';

/// SQLite Database manager for Bookmarks, History, and Downloads.
class DatabaseHelper {
  final Database? _injectedDatabase;
  final DatabaseFactory? factory;

  DatabaseHelper({Database? database, this.factory})
    : _injectedDatabase = database;

  static Database? _database;

  Future<Database> get database async {
    final injected = _injectedDatabase;
    if (injected != null) return injected;
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final effectiveFactory = factory ?? databaseFactory;
    final dbPath = await effectiveFactory.getDatabasesPath();
    final path = join(dbPath, 'axomai_library.db');

    return await effectiveFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(version: 1, onCreate: _onCreate),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        url TEXT NOT NULL,
        folder TEXT NOT NULL,
        favicon_url TEXT,
        created_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        url TEXT NOT NULL,
        visited_at INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE downloads (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        file_name TEXT NOT NULL,
        url TEXT NOT NULL,
        file_path TEXT NOT NULL,
        file_size INTEGER NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  // --- Bookmarks DAO ---
  Future<int> insertBookmark(BookmarkItem bookmark) async {
    final db = await database;
    return await db.insert(
      'bookmarks',
      bookmark.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<BookmarkItem>> getAllBookmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookmarks',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => BookmarkItem.fromMap(map)).toList();
  }

  Future<List<String>> getBookmarkFolders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT folder FROM bookmarks ORDER BY folder ASC',
    );
    final folders = maps.map((m) => m['folder'] as String).toList();
    if (!folders.contains('Mobile Bookmarks')) {
      folders.insert(0, 'Mobile Bookmarks');
    }
    return folders;
  }

  Future<bool> isBookmarked(String url) async {
    if (url.trim().isEmpty) return false;
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookmarks',
      where: 'url = ?',
      whereArgs: [url.trim()],
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<int> deleteBookmark(int id) async {
    final db = await database;
    return await db.delete('bookmarks', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteBookmarkByUrl(String url) async {
    final db = await database;
    return await db.delete(
      'bookmarks',
      where: 'url = ?',
      whereArgs: [url.trim()],
    );
  }

  // --- History DAO ---
  Future<int> insertHistory(HistoryItem item) async {
    final db = await database;
    return await db.insert(
      'history',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<HistoryItem>> getAllHistory() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'history',
      orderBy: 'visited_at DESC',
    );
    return maps.map((map) => HistoryItem.fromMap(map)).toList();
  }

  Future<List<HistoryItem>> searchHistory(String query) async {
    final db = await database;
    final q = '%${query.trim()}%';
    final List<Map<String, dynamic>> maps = await db.query(
      'history',
      where: 'title LIKE ? OR url LIKE ?',
      whereArgs: [q, q],
      orderBy: 'visited_at DESC',
    );
    return maps.map((map) => HistoryItem.fromMap(map)).toList();
  }

  Future<int> deleteHistoryItem(int id) async {
    final db = await database;
    return await db.delete('history', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearAllHistory() async {
    final db = await database;
    return await db.delete('history');
  }

  // --- Downloads DAO ---
  Future<int> insertDownload(DownloadItem item) async {
    final db = await database;
    return await db.insert(
      'downloads',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DownloadItem>> getAllDownloads() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'downloads',
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => DownloadItem.fromMap(map)).toList();
  }

  Future<int> deleteDownload(int id) async {
    final db = await database;
    return await db.delete('downloads', where: 'id = ?', whereArgs: [id]);
  }
}
