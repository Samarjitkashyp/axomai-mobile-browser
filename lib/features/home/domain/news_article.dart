import 'dart:convert';

/// Represents a news article fetched from Assam/Northeast RSS feeds.
class NewsArticle {
  final String title;
  final String link;
  final String source;
  final String description;
  final String? pubDate;
  final String? category;
  final String? imageUrl;

  const NewsArticle({
    required this.title,
    required this.link,
    required this.source,
    required this.description,
    this.pubDate,
    this.category,
    this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'link': link,
      'source': source,
      'description': description,
      'pubDate': pubDate,
      'category': category,
      'imageUrl': imageUrl,
    };
  }

  factory NewsArticle.fromMap(Map<String, dynamic> map) {
    return NewsArticle(
      title: map['title'] as String? ?? '',
      link: map['link'] as String? ?? '',
      source: map['source'] as String? ?? 'Assam Feed',
      description: map['description'] as String? ?? '',
      pubDate: map['pubDate'] as String?,
      category: map['category'] as String?,
      imageUrl: map['imageUrl'] as String?,
    );
  }

  String toJson() => json.encode(toMap());

  factory NewsArticle.fromJson(String source) =>
      NewsArticle.fromMap(json.decode(source) as Map<String, dynamic>);
}
