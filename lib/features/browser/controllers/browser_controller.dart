import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/search_engine_controller.dart';
import 'package:axomai_browser_mobile/features/browser/domain/browser_state.dart';
import 'package:axomai_browser_mobile/features/browser/domain/search_engine.dart';

/// Controller managing browser state, navigation, and page interactions.
class BrowserController extends StateNotifier<BrowserState> {
  final Ref _ref;
  InAppWebViewController? webViewController;
  FindInteractionController? findInteractionController;

  BrowserController(this._ref) : super(const BrowserState());

  void setWebViewController(InAppWebViewController controller) {
    webViewController = controller;
  }

  void setFindInteractionController(FindInteractionController? controller) {
    findInteractionController = controller;
  }

  /// Parses user query into a valid URL or search engine query URL.
  String formatQueryOrUrl(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return '';

    final hasScheme =
        trimmed.startsWith('http://') ||
        trimmed.startsWith('https://') ||
        trimmed.startsWith('about:') ||
        trimmed.startsWith('file://');

    if (hasScheme) {
      return trimmed;
    }

    // Check if input looks like a valid domain / host (e.g. "example.com", "sub.domain.org/path")
    final domainRegex = RegExp(
      r'^(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}(?:\/.*)?$',
    );

    if (domainRegex.hasMatch(trimmed) && !trimmed.contains(' ')) {
      return 'https://$trimmed';
    }

    // Otherwise treat as search query using current search engine
    final searchEngine = _ref.read(searchEngineControllerProvider);
    return searchEngine.buildSearchUrl(trimmed);
  }

  Future<void> loadUrl(String input) async {
    final targetUrl = formatQueryOrUrl(input);
    if (targetUrl.isEmpty) return;

    final uri = WebUri(targetUrl);
    await webViewController?.loadUrl(urlRequest: URLRequest(url: uri));
  }

  Future<void> goHome() async {
    state = state.copyWith(url: '', title: 'New Tab');
    await webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri('about:blank')),
    );
  }

  Future<void> reload() async {
    await webViewController?.reload();
  }

  Future<void> stopLoading() async {
    await webViewController?.stopLoading();
  }

  Future<void> goBack() async {
    if (await webViewController?.canGoBack() ?? false) {
      await webViewController?.goBack();
    }
  }

  Future<void> goForward() async {
    if (await webViewController?.canGoForward() ?? false) {
      await webViewController?.goForward();
    }
  }

  Future<void> toggleDesktopMode() async {
    final newMode = !state.isDesktopMode;
    state = state.copyWith(isDesktopMode: newMode);
    final ua = newMode
        ? 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        : '';
    await webViewController?.setSettings(
      settings: InAppWebViewSettings(
        userAgent: ua.isNotEmpty ? ua : null,
        useWideViewPort: newMode,
        loadWithOverviewMode: newMode,
      ),
    );
    await reload();
  }

  Future<void> zoomIn() async {
    final newZoom = (state.pageZoom + 0.25).clamp(0.5, 2.5);
    state = state.copyWith(pageZoom: newZoom);
    await webViewController?.zoomBy(zoomFactor: 1.25);
  }

  Future<void> zoomOut() async {
    final newZoom = (state.pageZoom - 0.25).clamp(0.5, 2.5);
    state = state.copyWith(pageZoom: newZoom);
    await webViewController?.zoomBy(zoomFactor: 0.8);
  }

  Future<void> resetZoom() async {
    state = state.copyWith(pageZoom: 1.0);
    await webViewController?.zoomBy(
      zoomFactor: 1.0 / (state.pageZoom > 0 ? state.pageZoom : 1.0),
    );
  }

  void onProgressChanged(int progress) {
    state = state.copyWith(
      progress: progress / 100.0,
      isLoading: progress < 100,
    );
  }

  void onTitleChanged(String? title) {
    state = state.copyWith(title: title ?? '');
  }

  void onUrlChanged(WebUri? uri) {
    final urlString = uri?.toString() ?? '';
    final isHttps = urlString.startsWith('https://');

    state = state.copyWith(url: urlString, isSecure: isHttps);
    _updateNavigationHistory();
  }

  Future<void> _updateNavigationHistory() async {
    final canBack = await webViewController?.canGoBack() ?? false;
    final canFwd = await webViewController?.canGoForward() ?? false;

    state = state.copyWith(canGoBack: canBack, canGoForward: canFwd);
  }

  // --- Find in Page ---
  void openFindInPage() {
    state = state.copyWith(
      isFindInPageOpen: true,
      findQuery: '',
      findCurrentIndex: 0,
      findTotalMatches: 0,
    );
    findInteractionController?.presentFindNavigator();
  }

  void closeFindInPage() {
    state = state.copyWith(
      isFindInPageOpen: false,
      findQuery: '',
      findCurrentIndex: 0,
      findTotalMatches: 0,
    );
    findInteractionController?.clearMatches();
    findInteractionController?.dismissFindNavigator();
  }

  Future<void> searchInPage(String query) async {
    state = state.copyWith(findQuery: query);
    if (query.trim().isEmpty) {
      await findInteractionController?.clearMatches();
      state = state.copyWith(findCurrentIndex: 0, findTotalMatches: 0);
      return;
    }
    await findInteractionController?.findAll(find: query);
  }

  Future<void> findNext() async {
    await findInteractionController?.findNext(forward: true);
  }

  Future<void> findPrevious() async {
    await findInteractionController?.findNext(forward: false);
  }

  void onFindResultReceived(int activeMatchOrdinal, int numberOfMatches) {
    state = state.copyWith(
      findCurrentIndex: activeMatchOrdinal,
      findTotalMatches: numberOfMatches,
    );
  }

  // --- Share ---
  Future<void> shareCurrentPage() async {
    final currentUrl = state.url.trim();
    if (currentUrl.isNotEmpty) {
      await Share.share(
        currentUrl,
        subject: state.title.isNotEmpty ? state.title : 'Axomai Browser Link',
      );
    }
  }
}

/// Riverpod provider for active browser controller.
final browserControllerProvider =
    StateNotifierProvider<BrowserController, BrowserState>((ref) {
      return BrowserController(ref);
    });
