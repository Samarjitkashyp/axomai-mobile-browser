/// Model representing a saved bookmark in the SQLite database.
class BookmarkItem {
  final int? id;
  final String title;
  final String url;
  final String folder;
  final String? faviconUrl;
  final DateTime createdAt;

  const BookmarkItem({
    this.id,
    required this.title,
    required this.url,
    this.folder = 'Mobile Bookmarks',
    this.faviconUrl,
    required this.createdAt,
  });

  BookmarkItem copyWith({
    int? id,
    String? title,
    String? url,
    String? folder,
    String? faviconUrl,
    DateTime? createdAt,
  }) {
    return BookmarkItem(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      folder: folder ?? this.folder,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'url': url,
      'folder': folder,
      'favicon_url': faviconUrl,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory BookmarkItem.fromMap(Map<String, dynamic> map) {
    return BookmarkItem(
      id: map['id'] as int?,
      title: (map['title'] as String?) ?? '',
      url: (map['url'] as String?) ?? '',
      folder: (map['folder'] as String?) ?? 'Mobile Bookmarks',
      faviconUrl: map['favicon_url'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map['created_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
