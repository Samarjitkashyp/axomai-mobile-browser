/// Immutable state representing active browser session.
class BrowserState {
  final String url;
  final String title;
  final bool isLoading;
  final double progress;
  final bool canGoBack;
  final bool canGoForward;
  final bool isSecure;
  final bool isFindInPageOpen;
  final String findQuery;
  final int findCurrentIndex;
  final int findTotalMatches;
  final bool isDesktopMode;
  final double pageZoom;

  const BrowserState({
    this.url = '',
    this.title = '',
    this.isLoading = false,
    this.progress = 0.0,
    this.canGoBack = false,
    this.canGoForward = false,
    this.isSecure = true,
    this.isFindInPageOpen = false,
    this.findQuery = '',
    this.findCurrentIndex = 0,
    this.findTotalMatches = 0,
    this.isDesktopMode = false,
    this.pageZoom = 1.0,
  });

  BrowserState copyWith({
    String? url,
    String? title,
    bool? isLoading,
    double? progress,
    bool? canGoBack,
    bool? canGoForward,
    bool? isSecure,
    bool? isFindInPageOpen,
    String? findQuery,
    int? findCurrentIndex,
    int? findTotalMatches,
    bool? isDesktopMode,
    double? pageZoom,
  }) {
    return BrowserState(
      url: url ?? this.url,
      title: title ?? this.title,
      isLoading: isLoading ?? this.isLoading,
      progress: progress ?? this.progress,
      canGoBack: canGoBack ?? this.canGoBack,
      canGoForward: canGoForward ?? this.canGoForward,
      isSecure: isSecure ?? this.isSecure,
      isFindInPageOpen: isFindInPageOpen ?? this.isFindInPageOpen,
      findQuery: findQuery ?? this.findQuery,
      findCurrentIndex: findCurrentIndex ?? this.findCurrentIndex,
      findTotalMatches: findTotalMatches ?? this.findTotalMatches,
      isDesktopMode: isDesktopMode ?? this.isDesktopMode,
      pageZoom: pageZoom ?? this.pageZoom,
    );
  }
}
