import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:axomai_browser_mobile/features/privacy/domain/privacy_settings.dart';
import 'package:axomai_browser_mobile/features/privacy/domain/site_permission.dart';

/// Repository managing persistence of privacy configuration and per-origin permissions.
class PrivacyRepository {
  final SharedPreferences? prefs;

  static const String _settingsKey = 'axomai_privacy_settings';
  static const String _permissionsKey = 'axomai_site_permissions';
  static const String _whitelistKey = 'axomai_adblock_whitelist';

  PrivacyRepository({this.prefs});

  Future<PrivacySettings> getSettings() async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    final jsonStr = effectivePrefs.getString(_settingsKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        return PrivacySettings.fromJson(jsonStr);
      } catch (_) {
        return const PrivacySettings();
      }
    }
    return const PrivacySettings();
  }

  Future<void> saveSettings(PrivacySettings settings) async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    await effectivePrefs.setString(_settingsKey, settings.toJson());
  }

  Future<List<SitePermission>> getPermissions() async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    final jsonStr = effectivePrefs.getString(_permissionsKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final list = json.decode(jsonStr) as List;
        return list
            .map((item) => SitePermission.fromMap(item as Map<String, dynamic>))
            .toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  Future<void> savePermission(SitePermission permission) async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    final permissions = await getPermissions();
    final updated =
        permissions
            .where(
              (p) =>
                  !(p.origin == permission.origin && p.type == permission.type),
            )
            .toList()
          ..add(permission);

    final jsonList = updated.map((p) => p.toMap()).toList();
    await effectivePrefs.setString(_permissionsKey, json.encode(jsonList));
  }

  Future<Set<String>> getAdblockWhitelist() async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    final list = effectivePrefs.getStringList(_whitelistKey);
    return list?.toSet() ?? <String>{};
  }

  Future<void> setAdblockWhitelist(Set<String> whitelist) async {
    final effectivePrefs = prefs ?? await SharedPreferences.getInstance();
    await effectivePrefs.setStringList(_whitelistKey, whitelist.toList());
  }
}
