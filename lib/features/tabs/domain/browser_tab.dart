/// Immutable model representing an individual browser tab.
class BrowserTab {
  final String id;
  final String url;
  final String title;
  final String? faviconUrl;
  final bool isIncognito;
  final DateTime createdAt;

  const BrowserTab({
    required this.id,
    this.url = '',
    this.title = 'New Tab',
    this.faviconUrl,
    this.isIncognito = false,
    required this.createdAt,
  });

  BrowserTab copyWith({
    String? id,
    String? url,
    String? title,
    String? faviconUrl,
    bool? isIncognito,
    DateTime? createdAt,
  }) {
    return BrowserTab(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      faviconUrl: faviconUrl ?? this.faviconUrl,
      isIncognito: isIncognito ?? this.isIncognito,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'faviconUrl': faviconUrl,
      'isIncognito': isIncognito,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BrowserTab.fromJson(Map<String, dynamic> json) {
    return BrowserTab(
      id: json['id'] as String,
      url: (json['url'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'New Tab',
      faviconUrl: json['faviconUrl'] as String?,
      isIncognito: (json['isIncognito'] as bool?) ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
