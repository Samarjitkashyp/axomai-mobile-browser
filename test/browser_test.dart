import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/core/theme/theme_controller.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/search_engine_controller.dart';
import 'package:axomai_browser_mobile/features/browser/domain/search_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('Search Engine & URL formatting tests', () {
    test('SearchEngine URL builders create valid query strings', () {
      expect(
        SearchEngine.google.buildSearchUrl('Assam tourism'),
        'https://www.google.com/search?q=Assam%20tourism',
      );
      expect(
        SearchEngine.duckDuckGo.buildSearchUrl('Flutter development'),
        'https://duckduckgo.com/?q=Flutter%20development',
      );
      expect(
        SearchEngine.bing.buildSearchUrl('Axom AI'),
        'https://www.bing.com/search?q=Axom%20AI',
      );
      expect(
        SearchEngine.brave.buildSearchUrl('privacy browser'),
        'https://search.brave.com/search?q=privacy%20browser',
      );
      expect(
        SearchEngine.ecosia.buildSearchUrl('Kaziranga'),
        'https://www.ecosia.org/search?q=Kaziranga',
      );
    });

    test('SearchEngineNotifier switches and persists search engines', () async {
      final notifier = container.read(searchEngineControllerProvider.notifier);

      expect(
        container.read(searchEngineControllerProvider),
        SearchEngine.google,
      );

      await notifier.setSearchEngine(SearchEngine.duckDuckGo);
      expect(
        container.read(searchEngineControllerProvider),
        SearchEngine.duckDuckGo,
      );
      expect(prefs.getString('axomai_default_search_engine'), 'duckduckgo');
    });

    test('formatQueryOrUrl correctly identifies URLs and search queries', () {
      final controller = container.read(browserControllerProvider.notifier);

      // Direct full URLs
      expect(
        controller.formatQueryOrUrl('https://flutter.dev'),
        'https://flutter.dev',
      );
      expect(
        controller.formatQueryOrUrl('http://example.com/test'),
        'http://example.com/test',
      );

      // Domain names auto-prepended with https
      expect(controller.formatQueryOrUrl('google.com'), 'https://google.com');
      expect(
        controller.formatQueryOrUrl('assam.gov.in/portal'),
        'https://assam.gov.in/portal',
      );

      // Search terms converted to search engine URL
      expect(
        controller.formatQueryOrUrl('guwahati weather today'),
        'https://www.google.com/search?q=guwahati%20weather%20today',
      );
    });
  });
}
