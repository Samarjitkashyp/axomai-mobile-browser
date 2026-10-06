import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/features/tabs/controllers/tabs_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('TabsController Multi-Tab & Persistence Tests', () {
    test('Opens 10 tabs and correctly tracks active tab and count', () async {
      final notifier = TabsNotifier(prefs);

      // Initially 1 default tab
      expect(notifier.state.normalTabs.length, 1);

      // Open 9 additional tabs (total 10)
      for (int i = 2; i <= 10; i++) {
        notifier.createNewTab(
          initialUrl: 'https://example$i.org',
          title: 'Example $i',
        );
      }

      expect(notifier.state.normalTabs.length, 10);
      expect(notifier.state.activeTab?.url, 'https://example10.org');
      expect(notifier.state.activeTab?.title, 'Example 10');
    });

    test('Tabs persist to SharedPreferences and restore on restart', () async {
      final notifier1 = TabsNotifier(prefs);

      // Add 3 custom tabs
      notifier1.createNewTab(
        initialUrl: 'https://flutter.dev',
        title: 'Flutter Dev',
      );
      notifier1.createNewTab(
        initialUrl: 'https://assam.gov.in',
        title: 'Assam Portal',
      );

      final activeTabId = notifier1.state.activeTabId;
      await Future<void>.delayed(Duration.zero);

      // Simulate App Restart with new notifier instance from same SharedPreferences
      final notifier2 = TabsNotifier(prefs);

      expect(notifier2.state.normalTabs.length, 3);
      expect(notifier2.state.activeTabId, activeTabId);
      expect(
        notifier2.state.normalTabs.any((t) => t.url == 'https://flutter.dev'),
        isTrue,
      );
      expect(
        notifier2.state.normalTabs.any((t) => t.url == 'https://assam.gov.in'),
        isTrue,
      );
    });

    test(
      'Incognito tabs are isolated and NEVER saved to SharedPreferences',
      () async {
        final notifier1 = TabsNotifier(prefs);

        // Add incognito tab
        notifier1.createNewTab(
          isIncognito: true,
          initialUrl: 'https://secret-page.org',
          title: 'Secret Page',
        );

        expect(notifier1.state.incognitoTabs.length, 1);
        expect(notifier1.state.isIncognitoMode, true);
        expect(notifier1.state.activeTab?.isIncognito, true);

        // Verify SharedPreferences does NOT contain the incognito tab
        final savedRawJson = prefs.getString('axomai_saved_tabs') ?? '';
        expect(savedRawJson.contains('secret-page.org'), isFalse);
        expect(savedRawJson.contains('Secret Page'), isFalse);

        // Simulate App Restart
        final notifier2 = TabsNotifier(prefs);
        expect(notifier2.state.incognitoTabs.isEmpty, isTrue);
        expect(notifier2.state.isIncognitoMode, false);
      },
    );

    test('Closing all tabs preserves a clean default tab', () async {
      final notifier = TabsNotifier(prefs);

      notifier.createNewTab(initialUrl: 'https://site1.org');
      notifier.createNewTab(initialUrl: 'https://site2.org');
      expect(notifier.state.normalTabs.length, 3);

      notifier.closeAllTabs();
      expect(notifier.state.normalTabs.length, 1);
      expect(notifier.state.normalTabs.first.url, '');
    });
  });
}
