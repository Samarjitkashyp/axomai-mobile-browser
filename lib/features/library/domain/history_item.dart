/// Model representing a browsing history entry in the SQLite database.
class HistoryItem {
  final int? id;
  final String title;
  final String url;
  final DateTime visitedAt;

  const HistoryItem({
    this.id,
    required this.title,
    required this.url,
    required this.visitedAt,
  });

  HistoryItem copyWith({
    int? id,
    String? title,
    String? url,
    DateTime? visitedAt,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      visitedAt: visitedAt ?? this.visitedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'url': url,
      'visited_at': visitedAt.millisecondsSinceEpoch,
    };
  }

  factory HistoryItem.fromMap(Map<String, dynamic> map) {
    return HistoryItem(
      id: map['id'] as int?,
      title: (map['title'] as String?) ?? '',
      url: (map['url'] as String?) ?? '',
      visitedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['visited_at'] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Categorizes this history item into a human-friendly date group.
  String get dateGroup {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final lastWeek = today.subtract(const Duration(days: 7));

    final itemDate = DateTime(visitedAt.year, visitedAt.month, visitedAt.day);

    if (itemDate.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (itemDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday';
    } else if (itemDate.isAfter(lastWeek)) {
      return 'Last 7 Days';
    } else {
      return 'Older';
    }
  }
}
