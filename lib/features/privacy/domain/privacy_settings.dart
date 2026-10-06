import 'dart:convert';

/// Privacy and security settings for the browser.
class PrivacySettings {
  final bool adBlockEnabled;
  final bool trackerBlockEnabled;
  final bool httpsOnlyMode;
  final bool blockThirdPartyCookies;
  final bool blockPopups;
  final bool javaScriptEnabled;

  const PrivacySettings({
    this.adBlockEnabled = true,
    this.trackerBlockEnabled = true,
    this.httpsOnlyMode = false,
    this.blockThirdPartyCookies = true,
    this.blockPopups = true,
    this.javaScriptEnabled = true,
  });

  PrivacySettings copyWith({
    bool? adBlockEnabled,
    bool? trackerBlockEnabled,
    bool? httpsOnlyMode,
    bool? blockThirdPartyCookies,
    bool? blockPopups,
    bool? javaScriptEnabled,
  }) {
    return PrivacySettings(
      adBlockEnabled: adBlockEnabled ?? this.adBlockEnabled,
      trackerBlockEnabled: trackerBlockEnabled ?? this.trackerBlockEnabled,
      httpsOnlyMode: httpsOnlyMode ?? this.httpsOnlyMode,
      blockThirdPartyCookies:
          blockThirdPartyCookies ?? this.blockThirdPartyCookies,
      blockPopups: blockPopups ?? this.blockPopups,
      javaScriptEnabled: javaScriptEnabled ?? this.javaScriptEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adBlockEnabled': adBlockEnabled,
      'trackerBlockEnabled': trackerBlockEnabled,
      'httpsOnlyMode': httpsOnlyMode,
      'blockThirdPartyCookies': blockThirdPartyCookies,
      'blockPopups': blockPopups,
      'javaScriptEnabled': javaScriptEnabled,
    };
  }

  factory PrivacySettings.fromMap(Map<String, dynamic> map) {
    return PrivacySettings(
      adBlockEnabled: map['adBlockEnabled'] as bool? ?? true,
      trackerBlockEnabled: map['trackerBlockEnabled'] as bool? ?? true,
      httpsOnlyMode: map['httpsOnlyMode'] as bool? ?? false,
      blockThirdPartyCookies: map['blockThirdPartyCookies'] as bool? ?? true,
      blockPopups: map['blockPopups'] as bool? ?? true,
      javaScriptEnabled: map['javaScriptEnabled'] as bool? ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory PrivacySettings.fromJson(String source) =>
      PrivacySettings.fromMap(json.decode(source) as Map<String, dynamic>);
}
