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
        final rawDesc =
            item.findElements('description').firstOrNull?.innerText ?? '';
        final description = _cleanHtml(rawDesc);
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

        // Extract image from enclosure or media:content or img tag
        String? imageUrl = item
            .findElements('enclosure')
            .firstOrNull
            ?.getAttribute('url');
        imageUrl ??= item
            .findElements('media:content')
            .firstOrNull
            ?.getAttribute('url');
        if (imageUrl == null || imageUrl.isEmpty) {
          final imgMatch = RegExp(
            r'<img[^>]+src="([^">]+)"',
          ).firstMatch(rawDesc);
          imageUrl = imgMatch?.group(1);
        }

        if (title != null && link != null && title.isNotEmpty) {
          articles.add(
            NewsArticle(
              title: title,
              link: link,
              source: defaultSource,
              description: description,
              pubDate: pubDate,
              category: category,
              imageUrl: imageUrl,
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
      pubDate: '2 hours ago',
      category: 'Culture',
      imageUrl:
          'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=400&q=80',
    ),
    NewsArticle(
      title: 'Kaziranga National Park reports healthy rhino population surge',
      link: 'https://assamtribune.com',
      source: 'Kaziranga Wildlife',
      description:
          'Conservation teams and smart camera surveillance ensure peaceful habitat for Assam one-horned rhinos.',
      pubDate: '4 hours ago',
      category: 'Wildlife',
      imageUrl:
          'https://images.unsplash.com/photo-1575550959106-5a7defe28b56?w=400&q=80',
    ),
    NewsArticle(
      title: 'Guwahati tech corridor expands with new startup initiatives',
      link: 'https://assamtribune.com',
      source: 'Assam Tech',
      description:
          'Northeast digital innovation ecosystem welcomes cutting-edge software and green technology enterprises.',
      pubDate: '6 hours ago',
      category: 'Technology',
      imageUrl:
          'https://images.unsplash.com/photo-1518770660439-4636190af475?w=400&q=80',
    ),
    NewsArticle(
      title:
          'Bhogali Bihu festivities bring grand community feasts across Assam',
      link: 'https://assamtribune.com',
      source: 'Assam Events',
      description:
          'Villages and towns celebrate with Meji bonfires, Pitha making, and vibrant community sports.',
      pubDate: 'Today',
      category: 'Festivals',
      imageUrl:
          'https://images.unsplash.com/photo-1532375810709-75b1da00537c?w=400&q=80',
    ),
    NewsArticle(
      title: 'Assam Tea gardens embrace organic cultivation and global exports',
      link: 'https://assamtribune.com',
      source: 'Assam Tribune',
      description:
          'High quality orthodox tea production reaches record demand in European and Asian beverage markets.',
      pubDate: 'Yesterday',
      category: 'Economy',
      imageUrl:
          'https://images.unsplash.com/photo-1576092768241-dec231879fc3?w=400&q=80',
    ),
    NewsArticle(
      title:
          'Majuli Island river arts project gains UNESCO international acclaim',
      link: 'https://assamtribune.com',
      source: 'Sentinel Assam',
      description:
          'Satras preserve ancient mask-making and neo-Vaishnavite dance forms on the world largest river island.',
      pubDate: 'Yesterday',
      category: 'Heritage',
      imageUrl:
          'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=400&q=80',
    ),
  ];
}
