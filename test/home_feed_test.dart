import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/features/home/controllers/home_feed_controller.dart';
import 'package:axomai_browser_mobile/features/home/data/news_feed_service.dart';
import 'package:axomai_browser_mobile/features/home/data/weather_service.dart';
import 'package:axomai_browser_mobile/features/home/domain/news_article.dart';
import 'package:axomai_browser_mobile/features/home/domain/quick_link.dart';
import 'package:axomai_browser_mobile/features/home/domain/weather_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('WeatherData Model Tests', () {
    test('Correctly maps WMO weather codes to condition texts and icons', () {
      final sunny = WeatherData(
        temperature: 28.5,
        weatherCode: 0,
        windSpeed: 10.0,
        relativeHumidity: 60,
        city: 'Guwahati',
        lastUpdated: DateTime.now(),
      );
      expect(sunny.conditionText, 'Clear Sky');
      expect(sunny.icon, Icons.wb_sunny_rounded);

      final rain = WeatherData(
        temperature: 22.0,
        weatherCode: 63,
        windSpeed: 18.0,
        relativeHumidity: 85,
        city: 'Dibrugarh',
        lastUpdated: DateTime.now(),
      );
      expect(rain.conditionText, 'Rain');
      expect(rain.icon, Icons.water_drop_rounded);

      final thunder = WeatherData(
        temperature: 24.0,
        weatherCode: 95,
        windSpeed: 25.0,
        relativeHumidity: 90,
        city: 'Silchar',
        lastUpdated: DateTime.now(),
      );
      expect(thunder.conditionText, 'Thunderstorm');
      expect(thunder.icon, Icons.thunderstorm_rounded);
    });

    test('Serializes to and from JSON for offline caching', () {
      final original = WeatherData(
        temperature: 27.2,
        weatherCode: 2,
        windSpeed: 12.5,
        relativeHumidity: 70,
        city: 'Jorhat',
        lastUpdated: DateTime(2026, 10, 6, 12, 0),
      );

      final jsonStr = original.toJson();
      final restored = WeatherData.fromJson(jsonStr);

      expect(restored.temperature, original.temperature);
      expect(restored.weatherCode, original.weatherCode);
      expect(restored.windSpeed, original.windSpeed);
      expect(restored.relativeHumidity, original.relativeHumidity);
      expect(restored.city, original.city);
      expect(restored.conditionText, 'Partly Cloudy');
    });
  });

  group('NewsArticle & RSS Model Tests', () {
    test('Serializes to and from JSON', () {
      const article = NewsArticle(
        title: 'Assam Tea Festival begins in Jorhat',
        link: 'https://assamtribune.com/tea-festival',
        source: 'Assam Tribune',
        description: 'World renowned CTC and orthodox teas showcased.',
        pubDate: 'Mon, 06 Oct 2026',
        category: 'Culture',
      );

      final jsonStr = article.toJson();
      final restored = NewsArticle.fromJson(jsonStr);

      expect(restored.title, article.title);
      expect(restored.link, article.link);
      expect(restored.source, article.source);
      expect(restored.description, article.description);
      expect(restored.category, 'Culture');
    });
  });

  group('QuickLink Model Tests', () {
    test('Provides default Assam & general shortcuts', () {
      final defaults = QuickLink.defaultLinks;
      expect(defaults.isNotEmpty, true);
      expect(defaults.any((l) => l.title == 'Axom AI'), true);
      expect(defaults.any((l) => l.title == 'Assam Tribune'), true);
      expect(defaults.any((l) => l.title == 'Wikipedia'), true);
    });

    test('Serializes custom quick links', () {
      const custom = QuickLink(
        id: 'c1',
        title: 'Guwahati University',
        url: 'https://gauhati.ac.in',
        iconLetter: 'G',
        isCustom: true,
      );

      final jsonStr = custom.toJson();
      final restored = QuickLink.fromJson(jsonStr);

      expect(restored.id, 'c1');
      expect(restored.title, 'Guwahati University');
      expect(restored.url, 'https://gauhati.ac.in');
      expect(restored.isCustom, true);
    });
  });

  group('WeatherService & Open-Meteo REST Tests', () {
    test('Fetches live weather from Open-Meteo and parses payload', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final mockClient = MockClient((request) async {
        final mockResponse = {
          'current_weather': {
            'temperature': 29.4,
            'weathercode': 1,
            'windspeed': 8.2,
          },
          'hourly': {
            'relativehumidity_2m': [68, 70, 72],
          },
        };
        return http.Response(json.encode(mockResponse), 200);
      });

      final service = WeatherService(client: mockClient, prefs: prefs);
      final weather = await service.fetchWeather();

      expect(weather, isNotNull);
      expect(weather!.temperature, 29.4);
      expect(weather.weatherCode, 1);
      expect(weather.windSpeed, 8.2);
      expect(weather.relativeHumidity, 68);
      expect(weather.city, 'Guwahati');

      // Verify cached copy was saved
      final cached = await service.getCachedWeather();
      expect(cached, isNotNull);
      expect(cached!.temperature, 29.4);
    });

    test('Falls back to cached weather on network error', () async {
      final now = DateTime.now();
      final cachedData = WeatherData(
        temperature: 25.0,
        weatherCode: 0,
        windSpeed: 5.0,
        relativeHumidity: 60,
        city: 'Guwahati',
        lastUpdated: now,
      );

      SharedPreferences.setMockInitialValues({
        'axomai_cached_weather': cachedData.toJson(),
      });
      final prefs = await SharedPreferences.getInstance();

      final failingClient = MockClient((request) async {
        return http.Response('Network failure', 500);
      });

      final service = WeatherService(client: failingClient, prefs: prefs);
      final weather = await service.fetchWeather();

      expect(weather, isNotNull);
      expect(weather!.temperature, 25.0);
      expect(weather.city, 'Guwahati');
    });
  });

  group('NewsFeedService & RSS XML Tests', () {
    test('Parses RSS 2.0 XML with items and strips HTML tags', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      const sampleRssXml = '''<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0">
  <channel>
    <title>Assam Tribune News</title>
    <link>https://assamtribune.com</link>
    <item>
      <title>Brahmaputra festival kicks off in Guwahati</title>
      <link>https://assamtribune.com/brahmaputra-fest</link>
      <description><![CDATA[<p>Grand cultural displays along <b>Machkhowa Ghat</b>.</p>]]></description>
      <pubDate>Tue, 06 Oct 2026 08:00:00 GMT</pubDate>
      <category>Events</category>
    </item>
    <item>
      <title>Assam Silk Industry receives GI modernization boost</title>
      <link>https://assamtribune.com/muga-silk-boost</link>
      <description>Sualkuchi weavers receive advanced looms.</description>
      <pubDate>Tue, 06 Oct 2026 09:30:00 GMT</pubDate>
      <category>Trade</category>
    </item>
  </channel>
</rss>''';

      final mockClient = MockClient((request) async {
        return http.Response(sampleRssXml, 200);
      });

      final service = NewsFeedService(client: mockClient, prefs: prefs);
      final articles = await service.fetchNews();

      expect(articles.length, 2);
      expect(articles[0].title, 'Brahmaputra festival kicks off in Guwahati');
      expect(articles[0].link, 'https://assamtribune.com/brahmaputra-fest');
      expect(articles[0].category, 'Events');
      expect(articles[0].description, contains('Grand cultural displays'));
      expect(articles[0].description, isNot(contains('<p>')));

      expect(
        articles[1].title,
        'Assam Silk Industry receives GI modernization boost',
      );
    });

    test('Falls back to cached or curated articles when offline', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final failingClient = MockClient((request) async {
        return http.Response('Server error', 503);
      });

      final service = NewsFeedService(client: failingClient, prefs: prefs);
      final articles = await service.fetchNews();

      expect(articles.isNotEmpty, true);
      expect(articles.any((a) => a.title.contains('Brahmaputra')), true);
    });
  });

  group('HomeFeedNotifier Controller Tests', () {
    test('Manages quick links and city selection', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final mockClient = MockClient((request) async {
        final mockResponse = {
          'current_weather': {
            'temperature': 31.0,
            'weathercode': 0,
            'windspeed': 6.0,
          },
          'hourly': {
            'relativehumidity_2m': [55],
          },
        };
        return http.Response(json.encode(mockResponse), 200);
      });

      final weatherService = WeatherService(client: mockClient, prefs: prefs);
      final newsService = NewsFeedService(client: mockClient, prefs: prefs);

      final notifier = HomeFeedNotifier(weatherService, newsService);
      await notifier.init();

      expect(notifier.state.quickLinks.isNotEmpty, true);

      // Add custom shortcut
      await notifier.addQuickLink('My Portal', 'https://myportal.assam.gov.in');
      expect(
        notifier.state.quickLinks.any((l) => l.title == 'My Portal'),
        true,
      );

      // Remove custom shortcut
      final added = notifier.state.quickLinks.firstWhere(
        (l) => l.title == 'My Portal',
      );
      await notifier.removeQuickLink(added.id);
      expect(
        notifier.state.quickLinks.any((l) => l.title == 'My Portal'),
        false,
      );

      // Switch City
      const tezpur = AssamCity(
        name: 'Tezpur',
        latitude: 26.6528,
        longitude: 92.7926,
      );
      await notifier.changeCity(tezpur);
      expect(notifier.state.selectedCity.name, 'Tezpur');
    });
  });
}
