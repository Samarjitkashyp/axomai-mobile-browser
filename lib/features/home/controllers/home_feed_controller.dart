import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/features/home/data/news_feed_service.dart';
import 'package:axomai_browser_mobile/features/home/data/weather_service.dart';
import 'package:axomai_browser_mobile/features/home/domain/news_article.dart';
import 'package:axomai_browser_mobile/features/home/domain/quick_link.dart';
import 'package:axomai_browser_mobile/features/home/domain/weather_data.dart';

class HomeFeedState {
  final WeatherData? weather;
  final List<NewsArticle> articles;
  final List<QuickLink> quickLinks;
  final bool isLoading;
  final AssamCity selectedCity;

  const HomeFeedState({
    this.weather,
    this.articles = const [],
    this.quickLinks = const [],
    this.isLoading = false,
    this.selectedCity = const AssamCity(
      name: 'Guwahati',
      latitude: 26.1445,
      longitude: 91.7362,
    ),
  });

  HomeFeedState copyWith({
    WeatherData? weather,
    List<NewsArticle>? articles,
    List<QuickLink>? quickLinks,
    bool? isLoading,
    AssamCity? selectedCity,
  }) {
    return HomeFeedState(
      weather: weather ?? this.weather,
      articles: articles ?? this.articles,
      quickLinks: quickLinks ?? this.quickLinks,
      isLoading: isLoading ?? this.isLoading,
      selectedCity: selectedCity ?? this.selectedCity,
    );
  }
}

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

final newsFeedServiceProvider = Provider<NewsFeedService>((ref) {
  return NewsFeedService();
});

final homeFeedProvider = StateNotifierProvider<HomeFeedNotifier, HomeFeedState>(
  (ref) {
    final weatherService = ref.watch(weatherServiceProvider);
    final newsService = ref.watch(newsFeedServiceProvider);
    return HomeFeedNotifier(weatherService, newsService);
  },
);

class HomeFeedNotifier extends StateNotifier<HomeFeedState> {
  final WeatherService _weatherService;
  final NewsFeedService _newsService;
  static const String _quickLinksKey = 'axomai_custom_quick_links';

  HomeFeedNotifier(this._weatherService, this._newsService)
    : super(const HomeFeedState()) {
    init();
  }

  Future<void> init() async {
    // 1. Load cached quick links & offline data immediately
    final links = await _loadQuickLinks();
    final city = await _weatherService.getSelectedCity();
    final cachedWeather = await _weatherService.getCachedWeather();
    final cachedNews = await _newsService.getCachedNews();

    state = state.copyWith(
      quickLinks: links,
      selectedCity: city,
      weather: cachedWeather,
      articles: cachedNews.isNotEmpty ? cachedNews : null,
      isLoading: true,
    );

    // 2. Fetch fresh network data
    await refreshFeed();
  }

  Future<void> refreshFeed() async {
    state = state.copyWith(isLoading: true);

    try {
      final weather = await _weatherService.fetchWeather(
        city: state.selectedCity,
      );
      final news = await _newsService.fetchNews();

      state = state.copyWith(
        weather: weather,
        articles: news,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> changeCity(AssamCity city) async {
    await _weatherService.setSelectedCity(city.name);
    state = state.copyWith(selectedCity: city, isLoading: true);
    final weather = await _weatherService.fetchWeather(city: city);
    state = state.copyWith(weather: weather, isLoading: false);
  }

  Future<void> addQuickLink(String title, String url) async {
    final letter = title.isNotEmpty ? title[0].toUpperCase() : 'W';
    final newLink = QuickLink(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      url: url,
      iconLetter: letter,
      isCustom: true,
    );

    final updated = [...state.quickLinks, newLink];
    state = state.copyWith(quickLinks: updated);
    await _saveQuickLinks(updated);
  }

  Future<void> removeQuickLink(String id) async {
    final updated = state.quickLinks.where((link) => link.id != id).toList();
    state = state.copyWith(quickLinks: updated);
    await _saveQuickLinks(updated);
  }

  Future<List<QuickLink>> _loadQuickLinks() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_quickLinksKey);
    if (data != null && data.isNotEmpty) {
      try {
        final list = json.decode(data) as List;
        return list
            .map((item) => QuickLink.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return QuickLink.defaultLinks;
      }
    }
    return QuickLink.defaultLinks;
  }

  Future<void> _saveQuickLinks(List<QuickLink> links) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = links.map((l) => l.toMap()).toList();
    await prefs.setString(_quickLinksKey, json.encode(jsonList));
  }
}
