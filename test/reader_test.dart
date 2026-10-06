import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';
import 'package:axomai_browser_mobile/features/reader/controllers/reader_controller.dart';
import 'package:axomai_browser_mobile/features/reader/data/reader_repository.dart';
import 'package:axomai_browser_mobile/features/reader/domain/reader_article.dart';
import 'package:axomai_browser_mobile/features/reader/domain/reader_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReaderArticle Model Tests', () {
    test('Calculates reading time accurately based on word count', () {
      final shortArticle = ReaderArticle(
        title: 'Short Update',
        contentHtml: '<p>Brief notice.</p>',
        textContent: 'Brief notice for immediate release in Guwahati today.',
        url: 'https://example.com/short',
        extractedAt: DateTime.now(),
      );
      expect(shortArticle.readingTimeMinutes, 1);

      // 450 words -> 3 minutes (at 200 WPM)
      final words = List.generate(450, (i) => 'word$i').join(' ');
      final longArticle = ReaderArticle(
        title: 'Long Essay on Assam History',
        contentHtml: '<p>$words</p>',
        textContent: words,
        url: 'https://example.com/history',
        extractedAt: DateTime.now(),
      );
      expect(longArticle.readingTimeMinutes, 3);
    });

    test('Serializes to and from JSON', () {
      final article = ReaderArticle(
        title: 'Brahmaputra Heritage',
        byline: 'Axom Editorial Team',
        excerpt: 'An in-depth look at historical trade on Brahmaputra.',
        contentHtml: '<p>Full content body...</p>',
        textContent: 'Full content body...',
        url: 'https://assamtribune.com/heritage',
        extractedAt: DateTime(2026, 10, 6),
      );

      final jsonStr = article.toJson();
      final decoded = ReaderArticle.fromJson(jsonStr);

      expect(decoded.title, article.title);
      expect(decoded.byline, 'Axom Editorial Team');
      expect(decoded.excerpt, article.excerpt);
      expect(decoded.url, article.url);
    });
  });

  group('ReaderSettings & Theme Tests', () {
    test('Provides distinct colors for all Reader Themes', () {
      expect(ReaderTheme.light.backgroundColor, const Color(0xFFFBFBFA));
      expect(ReaderTheme.sepia.backgroundColor, const Color(0xFFF4ECD8));
      expect(ReaderTheme.dark.backgroundColor, const Color(0xFF202124));
      expect(ReaderTheme.black.backgroundColor, const Color(0xFF000000));

      expect(ReaderTheme.sepia.textColor, const Color(0xFF433422));
      expect(ReaderTheme.dark.textColor, const Color(0xFFE8EAED));
    });

    test('Serializes ReaderSettings correctly', () {
      const custom = ReaderSettings(
        theme: ReaderTheme.dark,
        fontFamily: ReaderFontFamily.monospace,
        fontSize: 22.0,
        lineHeight: 1.8,
      );

      final jsonStr = custom.toJson();
      final decoded = ReaderSettings.fromJson(jsonStr);

      expect(decoded.theme, ReaderTheme.dark);
      expect(decoded.fontFamily, ReaderFontFamily.monospace);
      expect(decoded.fontSize, 22.0);
      expect(decoded.lineHeight, 1.8);
    });

    test('ReaderRepository persists settings to SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = ReaderRepository(prefs: prefs);

      const toSave = ReaderSettings(theme: ReaderTheme.black, fontSize: 20.0);
      await repo.saveSettings(toSave);

      final restored = await repo.getSettings();
      expect(restored.theme, ReaderTheme.black);
      expect(restored.fontSize, 20.0);
    });
  });

  group('ReaderController Tests', () {
    test(
      'Opens, adjusts font size with clamping, changes theme, and closes',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = ReaderRepository(prefs: prefs);
        final controller = ReaderController(repo);

        // Open with fallback article
        final opened = await controller.openReader(
          null,
          fallbackTitle: 'Assam Tea Garden Archives',
          fallbackUrl: 'https://tea.assam.gov.in',
        );
        expect(opened, true);
        expect(controller.state.isReaderOpen, true);
        expect(controller.state.article?.title, 'Assam Tea Garden Archives');

        // Adjust Font Size
        final initialSize = controller.state.settings.fontSize;
        await controller.increaseFontSize();
        expect(controller.state.settings.fontSize, initialSize + 2);

        await controller.decreaseFontSize();
        expect(controller.state.settings.fontSize, initialSize);

        // Change Theme & Font Family
        await controller.setTheme(ReaderTheme.sepia);
        expect(controller.state.settings.theme, ReaderTheme.sepia);

        await controller.setFontFamily(ReaderFontFamily.sansSerif);
        expect(
          controller.state.settings.fontFamily,
          ReaderFontFamily.sansSerif,
        );

        // Close Reader
        controller.closeReader();
        expect(controller.state.isReaderOpen, false);
      },
    );
  });

  group('BrowserController Desktop Mode & Page Zoom Tests', () {
    test('Toggles desktop mode and adjusts zoom levels', () async {
      final container = ProviderContainer();
      final controller = container.read(browserControllerProvider.notifier);

      expect(container.read(browserControllerProvider).isDesktopMode, false);
      expect(container.read(browserControllerProvider).pageZoom, 1.0);

      // Desktop Mode toggle
      await controller.toggleDesktopMode();
      expect(container.read(browserControllerProvider).isDesktopMode, true);

      await controller.toggleDesktopMode();
      expect(container.read(browserControllerProvider).isDesktopMode, false);

      // Page Zoom
      await controller.zoomIn();
      expect(container.read(browserControllerProvider).pageZoom, 1.25);

      await controller.zoomOut();
      expect(container.read(browserControllerProvider).pageZoom, 1.0);

      await controller.resetZoom();
      expect(container.read(browserControllerProvider).pageZoom, 1.0);
    });
  });
}
