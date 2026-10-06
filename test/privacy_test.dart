import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/features/privacy/controllers/privacy_controller.dart';
import 'package:axomai_browser_mobile/features/privacy/data/content_blocker_service.dart';
import 'package:axomai_browser_mobile/features/privacy/data/privacy_repository.dart';
import 'package:axomai_browser_mobile/features/privacy/domain/privacy_settings.dart';
import 'package:axomai_browser_mobile/features/privacy/domain/site_permission.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ContentBlockerService Unit Tests', () {
    late ContentBlockerService blocker;

    setUp(() {
      blocker = ContentBlockerService();
    });

    test('Blocks known advertising and telemetry domains', () {
      expect(
        blocker.shouldBlockUrl(
          'https://pagead2.googlesyndication.com/pagead/js/ads.js',
        ),
        true,
      );
      expect(
        blocker.shouldBlockUrl('https://google-analytics.com/analytics.js'),
        true,
      );
      expect(
        blocker.shouldBlockUrl(
          'https://connect.facebook.net/en_US/fbevents.js',
        ),
        true,
      );
      expect(
        blocker.shouldBlockUrl('https://static.criteo.net/js/ld/ld.js'),
        true,
      );
      expect(
        blocker.shouldBlockUrl('https://cdn.taboola.com/libtrc/unip/trc.js'),
        true,
      );
    });

    test('Allows regular websites, scripts, and media resources', () {
      expect(
        blocker.shouldBlockUrl('https://en.wikipedia.org/wiki/Assam'),
        false,
      );
      expect(
        blocker.shouldBlockUrl('https://aiaxom.in/assets/main.dart.js'),
        false,
      );
      expect(
        blocker.shouldBlockUrl(
          'https://assamtribune.com/articles/heritage.html',
        ),
        false,
      );
      expect(
        blocker.shouldBlockUrl(
          'https://fonts.googleapis.com/css2?family=Inter',
        ),
        false,
      );
    });

    test('Respects disabled blocker flags', () {
      expect(
        blocker.shouldBlockUrl(
          'https://pagead2.googlesyndication.com/pagead/js/ads.js',
          adBlockEnabled: false,
          trackerBlockEnabled: false,
        ),
        false,
      );
    });

    test('HTTPS-Only upgrade properly upgrades HTTP schemes', () {
      expect(
        blocker.upgradeToHttps('http://assam.gov.in/portal', true),
        'https://assam.gov.in/portal',
      );
      expect(
        blocker.upgradeToHttps('https://secure.assam.gov.in', true),
        isNull,
      );
      expect(blocker.upgradeToHttps('http://assam.gov.in', false), isNull);
    });
  });

  group('Privacy Models & Repository Tests', () {
    test('PrivacySettings JSON serialization matches defaults', () {
      const defaultSettings = PrivacySettings();
      expect(defaultSettings.adBlockEnabled, true);
      expect(defaultSettings.trackerBlockEnabled, true);
      expect(defaultSettings.httpsOnlyMode, false);
      expect(defaultSettings.blockThirdPartyCookies, true);

      final jsonStr = defaultSettings.toJson();
      final decoded = PrivacySettings.fromJson(jsonStr);

      expect(decoded.adBlockEnabled, true);
      expect(decoded.trackerBlockEnabled, true);
      expect(decoded.blockThirdPartyCookies, true);
    });

    test('SitePermission model records origin and permission state', () {
      final perm = SitePermission(
        origin: 'https://axomai.co.in',
        type: PermissionType.camera,
        status: PermissionStatus.allow,
        updatedAt: DateTime(2026, 10, 6),
      );

      final jsonStr = perm.toJson();
      final decoded = SitePermission.fromJson(jsonStr);

      expect(decoded.origin, 'https://axomai.co.in');
      expect(decoded.type, PermissionType.camera);
      expect(decoded.status, PermissionStatus.allow);
    });

    test('PrivacyRepository persists configuration & permissions', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final repo = PrivacyRepository(prefs: prefs);

      const customSettings = PrivacySettings(
        adBlockEnabled: false,
        httpsOnlyMode: true,
      );
      await repo.saveSettings(customSettings);

      final restored = await repo.getSettings();
      expect(restored.adBlockEnabled, false);
      expect(restored.httpsOnlyMode, true);

      // Whitelist
      await repo.setAdblockWhitelist({'example.com', 'news.assam.gov.in'});
      final whitelist = await repo.getAdblockWhitelist();
      expect(whitelist.contains('example.com'), true);
      expect(whitelist.contains('news.assam.gov.in'), true);
    });
  });

  group('PrivacyController Tests', () {
    test(
      'Records blocked counts, resets on navigation, and toggles whitelist',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final repo = PrivacyRepository(prefs: prefs);
        final controller = PrivacyController(repo);
        await controller.init();

        expect(controller.state.pageBlockedCount, 0);

        controller.recordBlockedRequest();
        controller.recordBlockedRequest();
        expect(controller.state.pageBlockedCount, 2);
        expect(controller.state.sessionBlockedCount, 2);

        controller.resetPageBlockedCount();
        expect(controller.state.pageBlockedCount, 0);
        expect(controller.state.sessionBlockedCount, 2);

        // Whitelist site
        expect(
          controller.isOriginWhitelisted('https://trusted-portal.com'),
          false,
        );
        await controller.toggleSiteWhitelist('https://trusted-portal.com/page');
        expect(
          controller.isOriginWhitelisted('https://trusted-portal.com'),
          true,
        );

        // Toggle off whitelist
        await controller.toggleSiteWhitelist('https://trusted-portal.com/page');
        expect(
          controller.isOriginWhitelisted('https://trusted-portal.com'),
          false,
        );
      },
    );
  });
}
