/// Supported search engines in Axomai Browser.
enum SearchEngine { google, duckDuckGo, bing, brave, ecosia }

extension SearchEngineExtension on SearchEngine {
  String get id {
    switch (this) {
      case SearchEngine.google:
        return 'google';
      case SearchEngine.duckDuckGo:
        return 'duckduckgo';
      case SearchEngine.bing:
        return 'bing';
      case SearchEngine.brave:
        return 'brave';
      case SearchEngine.ecosia:
        return 'ecosia';
    }
  }

  String get displayName {
    switch (this) {
      case SearchEngine.google:
        return 'Google';
      case SearchEngine.duckDuckGo:
        return 'DuckDuckGo';
      case SearchEngine.bing:
        return 'Microsoft Bing';
      case SearchEngine.brave:
        return 'Brave Search';
      case SearchEngine.ecosia:
        return 'Ecosia';
    }
  }

  String get searchUrlPrefix {
    switch (this) {
      case SearchEngine.google:
        return 'https://www.google.com/search?q=';
      case SearchEngine.duckDuckGo:
        return 'https://duckduckgo.com/?q=';
      case SearchEngine.bing:
        return 'https://www.bing.com/search?q=';
      case SearchEngine.brave:
        return 'https://search.brave.com/search?q=';
      case SearchEngine.ecosia:
        return 'https://www.ecosia.org/search?q=';
    }
  }

  String buildSearchUrl(String query) {
    final encoded = Uri.encodeComponent(query.trim());
    return '$searchUrlPrefix$encoded';
  }
}
