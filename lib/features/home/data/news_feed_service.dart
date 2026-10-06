import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart';
import 'package:axomai_browser_mobile/features/home/domain/news_article.dart';

/// Service to fetch and parse Assam/Northeast RSS news feeds with offline caching.
class NewsFeedService {
  final http.Client _client;
  final SharedPreferences? prefs;

  static const String _newsCacheKey = 'axomai_cached_news_feed';

  /// Primary RSS feed URLs for Assam and Northeast coverage
  static const List<String> _feedUrls = ['https://assamtribune.com/feed'];

  NewsFeedService({http.Client? client, this.prefs})
    : _client = client ?? http.Client();

  /// Fetch latest Assam headlines, with robust fallback to cache and curated defaults.
  Future<List<NewsArticle>> fetchNews() async {
    for (final feedUrl in _feedUrls) {
      try {
        final response = await _client
            .get(Uri.parse(feedUrl))
            .timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final articles = _parseRssXml(response.body, 'Assam Tribune');
          if (articles.isNotEmpty) {
            await _saveToCache(articles);
            return articles;
          }
        }
      } catch (_) {
        // Try next feed or fallback to cache
      }
    }

    final cached = await getCachedNews();
    if (cached.isNotEmpty) {
      return cached;
    }

    return _fallbackArticles;
  }

  List<NewsArticle> _parseRssXml(String xmlString, String defaultSource) {
    final List<NewsArticle> articles = [];
    try {
      final document = XmlDocument.parse(xmlString);
      final items = document.findAllElements('item');

      for (final item in items) {
        final title = item.findElements('title').firstOrNull?.innerText.trim();
        final link = item.findElements('link').firstOrNull?.innerText.trim();
        final description = _cleanHtml(
          item.findElements('description').firstOrNull?.innerText ?? '',
        );
        final pubDate = item
            .findElements('pubDate')
            .firstOrNull
            ?.innerText
            .trim();
        final category = item
            .findElements('category')
            .firstOrNull
            ?.innerText
            .trim();

        if (title != null && link != null && title.isNotEmpty) {
          articles.add(
            NewsArticle(
              title: title,
              link: link,
              source: defaultSource,
              description: description,
              pubDate: pubDate,
              category: category,
            ),
          );
        }
      }
    } catch (_) {
      // XML parse error
    }
    return articles;
  }

  String _cleanHtml(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _saveToCache(List<NewsArticle> articles) async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    final jsonList = articles.map((a) => a.toMap()).toList();
    await effectivePrefs.setString(_newsCacheKey, json.encode(jsonList));
  }

  Future<List<NewsArticle>> getCachedNews() async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    final cached = effectivePrefs.getString(_newsCacheKey);
    if (cached != null && cached.isNotEmpty) {
      try {
        final list = json.decode(cached) as List;
        return list
            .map((item) => NewsArticle.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  static const List<NewsArticle> _fallbackArticles = [
    NewsArticle(
      title: 'Brahmaputra Heritage Centre showcases Assam rich cultural legacy',
      link: 'https://assamtribune.com',
      source: 'Assam News',
      description:
          'Panbazar riverfront revitalization highlights traditional Assamese crafts and historic maritime traditions.',
      pubDate: 'Today',
      category: 'Culture',
    ),
    NewsArticle(
      title: 'Kaziranga National Park reports healthy rhino population surge',
      link: 'https://assamtribune.com',
      source: 'Kaziranga Wildlife',
      description:
          'Conservation teams and smart camera surveillance ensure peaceful habitat for Assam one-horned rhinos.',
      pubDate: 'Today',
      category: 'Environment',
    ),
    NewsArticle(
      title: 'Guwahati tech corridor expands with new startup initiatives',
      link: 'https://assamtribune.com',
      source: 'Assam Tech',
      description:
          'Northeast digital innovation ecosystem welcomes cutting-edge software and green technology enterprises.',
      pubDate: 'Yesterday',
      category: 'Technology',
    ),
    NewsArticle(
      title:
          'Bhogali Bihu festivities bring grand community feasts across Assam',
      link: 'https://assamtribune.com',
      source: 'Assam Events',
      description:
          'Villages and towns celebrate with Meji bonfires, Pitha making, and vibrant community sports.',
      pubDate: 'Recent',
      category: 'Festivals',
    ),
  ];
}
