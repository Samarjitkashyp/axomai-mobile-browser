/// High-performance Ad, Tracker, and Telemetry Content Blocker Engine.
class ContentBlockerService {
  /// Known ad and telemetry domains for rapid matching
  static const Set<String> _blockedDomains = {
    'doubleclick.net',
    'googlesyndication.com',
    'googleadservices.com',
    'adservice.google.com',
    'adservice.google.co.in',
    'pagead2.googlesyndication.com',
    'google-analytics.com',
    'analytics.google.com',
    'facebook.net',
    'connect.facebook.net',
    'ads.twitter.com',
    'ads-twitter.com',
    'criteo.com',
    'criteo.net',
    'taboola.com',
    'outbrain.com',
    'hotjar.com',
    'scorecardresearch.com',
    'quantserve.com',
    'adnxs.com',
    'rubiconproject.com',
    'pubmatic.com',
    'openx.net',
    'casalemedia.com',
    'amazon-adsystem.com',
    'adcolony.com',
    'unityads.unity3d.com',
    'applovin.com',
    'appsflyer.com',
    'branch.io',
    'adjust.com',
    'moatads.com',
    'smartadserver.com',
    'popads.net',
    'popcash.net',
    'propellerads.com',
  };

  /// Common URL path patterns for ads, telemetry and tracking scripts
  static final List<RegExp> _blockedPatterns = [
    RegExp(r'/ads?\.(?:js|json)', caseSensitive: false),
    RegExp(r'/pagead/js/', caseSensitive: false),
    RegExp(
      r'/google-analytics\.com/(?:ga|analytics)\.js',
      caseSensitive: false,
    ),
    RegExp(r'/gtag/js\?id=', caseSensitive: false),
    RegExp(r'/fbevents\.js', caseSensitive: false),
    RegExp(r'/pixel\.gif', caseSensitive: false),
    RegExp(r'/track(?:ing)?/pixel', caseSensitive: false),
    RegExp(
      r'/(?:banner|interstitial|popunder)[\-_]?ads?',
      caseSensitive: false,
    ),
  ];

  /// Checks whether a given request URL should be blocked based on active settings.
  bool shouldBlockUrl(
    String urlString, {
    bool adBlockEnabled = true,
    bool trackerBlockEnabled = true,
  }) {
    if (!adBlockEnabled && !trackerBlockEnabled) return false;
    if (urlString.isEmpty) return false;

    try {
      final uri = Uri.parse(urlString);
      final host = uri.host.toLowerCase();
      final path = uri.path.toLowerCase();

      // 1. Direct or suffix domain match
      for (final blocked in _blockedDomains) {
        if (host == blocked || host.endsWith('.$blocked')) {
          return true;
        }
      }

      // 2. Pattern and regex check on full path/query
      final fullUrl = urlString.toLowerCase();
      for (final pattern in _blockedPatterns) {
        if (pattern.hasMatch(path) || pattern.hasMatch(fullUrl)) {
          return true;
        }
      }
    } catch (_) {
      // Ignore parse exceptions and allow
    }

    return false;
  }

  /// Upgrades HTTP URLs to HTTPS if HTTPS-Only mode is enabled.
  String? upgradeToHttps(String urlString, bool httpsOnlyMode) {
    if (!httpsOnlyMode) return null;
    if (urlString.startsWith('http://')) {
      return urlString.replaceFirst('http://', 'https://');
    }
    return null;
  }
}
