import 'dart:convert';

/// Represents a favorite/quick access link on the New Tab page.
class QuickLink {
  final String id;
  final String title;
  final String url;
  final String? iconLetter;
  final bool isCustom;

  const QuickLink({
    required this.id,
    required this.title,
    required this.url,
    this.iconLetter,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'iconLetter': iconLetter,
      'isCustom': isCustom,
    };
  }

  factory QuickLink.fromMap(Map<String, dynamic> map) {
    return QuickLink(
      id: map['id'] as String,
      title: map['title'] as String,
      url: map['url'] as String,
      iconLetter: map['iconLetter'] as String?,
      isCustom: map['isCustom'] as bool? ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory QuickLink.fromJson(String source) =>
      QuickLink.fromMap(json.decode(source) as Map<String, dynamic>);

  static List<QuickLink> get defaultLinks => const [
    QuickLink(
      id: 'axomai',
      title: 'Axom AI',
      url: 'https://aiaxom.in',
      iconLetter: 'A',
    ),
    QuickLink(
      id: 'assam_tribune',
      title: 'Assam Tribune',
      url: 'https://assamtribune.com',
      iconLetter: 'T',
    ),
    QuickLink(
      id: 'pratidin_time',
      title: 'Pratidin Time',
      url: 'https://www.pratidintime.com',
      iconLetter: 'P',
    ),
    QuickLink(
      id: 'wikipedia',
      title: 'Wikipedia',
      url: 'https://en.wikipedia.org',
      iconLetter: 'W',
    ),
    QuickLink(
      id: 'youtube',
      title: 'YouTube',
      url: 'https://youtube.com',
      iconLetter: 'Y',
    ),
    QuickLink(
      id: 'duckduckgo',
      title: 'DuckDuckGo',
      url: 'https://duckduckgo.com',
      iconLetter: 'D',
    ),
    QuickLink(
      id: 'reddit',
      title: 'Reddit',
      url: 'https://reddit.com',
      iconLetter: 'R',
    ),
    QuickLink(
      id: 'github',
      title: 'GitHub',
      url: 'https://github.com',
      iconLetter: 'G',
    ),
  ];
}
