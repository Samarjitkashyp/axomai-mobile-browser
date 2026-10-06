import 'dart:convert';

/// Represents parsed, distraction-free article content extracted from a web page.
class ReaderArticle {
  final String title;
  final String? byline;
  final String? excerpt;
  final String contentHtml;
  final String textContent;
  final String url;
  final DateTime extractedAt;

  const ReaderArticle({
    required this.title,
    this.byline,
    this.excerpt,
    required this.contentHtml,
    required this.textContent,
    required this.url,
    required this.extractedAt,
  });

  /// Approximate reading time in minutes (assumes average 200 WPM).
  int get readingTimeMinutes {
    final words = textContent.trim().split(RegExp(r'\s+')).length;
    final minutes = (words / 200).ceil();
    return minutes > 0 ? minutes : 1;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'byline': byline,
      'excerpt': excerpt,
      'contentHtml': contentHtml,
      'textContent': textContent,
      'url': url,
      'extractedAt': extractedAt.toIso8601String(),
    };
  }

  factory ReaderArticle.fromMap(Map<String, dynamic> map) {
    return ReaderArticle(
      title: map['title'] as String? ?? 'Untitled Article',
      byline: map['byline'] as String?,
      excerpt: map['excerpt'] as String?,
      contentHtml: map['contentHtml'] as String? ?? '',
      textContent: map['textContent'] as String? ?? '',
      url: map['url'] as String? ?? '',
      extractedAt: DateTime.parse(
        map['extractedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ReaderArticle.fromJson(String source) =>
      ReaderArticle.fromMap(json.decode(source) as Map<String, dynamic>);
}
