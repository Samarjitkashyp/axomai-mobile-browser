import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/privacy/data/content_blocker_service.dart';
import 'package:axomai_browser_mobile/features/privacy/data/privacy_repository.dart';
import 'package:axomai_browser_mobile/features/privacy/domain/privacy_settings.dart';
import 'package:axomai_browser_mobile/features/privacy/domain/site_permission.dart';

class PrivacyState {
  final PrivacySettings settings;
  final int pageBlockedCount;
  final int sessionBlockedCount;
  final Set<String> whitelistedOrigins;
  final List<SitePermission> permissions;

  const PrivacyState({
    this.settings = const PrivacySettings(),
    this.pageBlockedCount = 0,
    this.sessionBlockedCount = 0,
    this.whitelistedOrigins = const {},
    this.permissions = const [],
  });

  PrivacyState copyWith({
    PrivacySettings? settings,
    int? pageBlockedCount,
    int? sessionBlockedCount,
    Set<String>? whitelistedOrigins,
    List<SitePermission>? permissions,
  }) {
    return PrivacyState(
      settings: settings ?? this.settings,
      pageBlockedCount: pageBlockedCount ?? this.pageBlockedCount,
      sessionBlockedCount: sessionBlockedCount ?? this.sessionBlockedCount,
      whitelistedOrigins: whitelistedOrigins ?? this.whitelistedOrigins,
      permissions: permissions ?? this.permissions,
    );
  }
}

final contentBlockerServiceProvider = Provider<ContentBlockerService>((ref) {
  return ContentBlockerService();
});

final privacyRepositoryProvider = Provider<PrivacyRepository>((ref) {
  return PrivacyRepository();
});

final privacyControllerProvider =
    StateNotifierProvider<PrivacyController, PrivacyState>((ref) {
      final repo = ref.watch(privacyRepositoryProvider);
      return PrivacyController(repo);
    });

class PrivacyController extends StateNotifier<PrivacyState> {
  final PrivacyRepository _repository;

  PrivacyController(this._repository) : super(const PrivacyState()) {
    init();
  }

  Future<void> init() async {
    final settings = await _repository.getSettings();
    final whitelist = await _repository.getAdblockWhitelist();
    final permissions = await _repository.getPermissions();

    state = state.copyWith(
      settings: settings,
      whitelistedOrigins: whitelist,
      permissions: permissions,
    );
  }

  void recordBlockedRequest() {
    state = state.copyWith(
      pageBlockedCount: state.pageBlockedCount + 1,
      sessionBlockedCount: state.sessionBlockedCount + 1,
    );
  }

  void resetPageBlockedCount() {
    state = state.copyWith(pageBlockedCount: 0);
  }

  bool isOriginWhitelisted(String urlString) {
    try {
      final uri = Uri.parse(urlString);
      return state.whitelistedOrigins.contains(uri.host);
    } catch (_) {
      return false;
    }
  }

  Future<void> toggleSiteWhitelist(String urlString) async {
    try {
      final host = Uri.parse(urlString).host;
      if (host.isEmpty) return;

      final updated = Set<String>.from(state.whitelistedOrigins);
      if (updated.contains(host)) {
        updated.remove(host);
      } else {
        updated.add(host);
      }

      state = state.copyWith(whitelistedOrigins: updated);
      await _repository.setAdblockWhitelist(updated);
    } catch (_) {}
  }

  Future<void> updateSettings(PrivacySettings newSettings) async {
    state = state.copyWith(settings: newSettings);
    await _repository.saveSettings(newSettings);
  }

  Future<void> toggleAdBlock(bool enabled) async {
    await updateSettings(state.settings.copyWith(adBlockEnabled: enabled));
  }

  Future<void> toggleTrackerBlock(bool enabled) async {
    await updateSettings(state.settings.copyWith(trackerBlockEnabled: enabled));
  }

  Future<void> toggleHttpsOnly(bool enabled) async {
    await updateSettings(state.settings.copyWith(httpsOnlyMode: enabled));
  }

  Future<void> toggleThirdPartyCookies(bool enabled) async {
    await updateSettings(
      state.settings.copyWith(blockThirdPartyCookies: enabled),
    );
  }

  Future<void> togglePopups(bool enabled) async {
    await updateSettings(state.settings.copyWith(blockPopups: enabled));
  }

  Future<void> toggleJavaScript(bool enabled) async {
    await updateSettings(state.settings.copyWith(javaScriptEnabled: enabled));
  }

  Future<void> setPermission(
    String origin,
    PermissionType type,
    PermissionStatus status,
  ) async {
    final perm = SitePermission(
      origin: origin,
      type: type,
      status: status,
      updatedAt: DateTime.now(),
    );

    await _repository.savePermission(perm);
    final permissions = await _repository.getPermissions();
    state = state.copyWith(permissions: permissions);
  }

  Future<void> clearBrowsingData({
    bool clearCache = true,
    bool clearCookies = true,
    bool clearStorage = true,
  }) async {
    if (clearCache) {
      await InAppWebViewController.clearAllCache();
    }
    if (clearCookies) {
      final cookieManager = CookieManager.instance();
      await cookieManager.deleteAllCookies();
    }
    if (clearStorage) {
      final webStorageManager = WebStorageManager.instance();
      await webStorageManager.deleteAllData();
    }
  }
}
