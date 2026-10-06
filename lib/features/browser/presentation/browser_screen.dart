import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/core/constants/app_constants.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';
import 'package:axomai_browser_mobile/features/browser/presentation/widgets/address_bar.dart';
import 'package:axomai_browser_mobile/features/browser/presentation/widgets/browser_navigation_bar.dart';
import 'package:axomai_browser_mobile/features/browser/presentation/widgets/find_in_page_bar.dart';
import 'package:axomai_browser_mobile/features/home/presentation/new_tab_view.dart';
import 'package:axomai_browser_mobile/features/library/controllers/history_controller.dart';
import 'package:axomai_browser_mobile/features/privacy/controllers/privacy_controller.dart';
import 'package:axomai_browser_mobile/features/privacy/domain/privacy_settings.dart';
import 'package:axomai_browser_mobile/features/tabs/controllers/tabs_controller.dart';
import 'package:axomai_browser_mobile/l10n/app_localizations.dart';

/// Primary browser container managing WebView, AddressBar, and Navigation.
class BrowserScreen extends ConsumerStatefulWidget {
  const BrowserScreen({super.key});

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  FindInteractionController? _findInteractionController;
  String? _lastLoadedTabId;

  InAppWebViewSettings _buildSettings(
    bool isIncognito,
    PrivacySettings privacy,
  ) {
    return InAppWebViewSettings(
      isInspectable: kDebugMode,
      mediaPlaybackRequiresUserGesture: false,
      allowsInlineMediaPlayback: true,
      useHybridComposition: true,
      supportZoom: true,
      builtInZoomControls: true,
      displayZoomControls: false,
      incognito: isIncognito,
      cacheEnabled: !isIncognito,
      javaScriptCanOpenWindowsAutomatically: !privacy.blockPopups,
      thirdPartyCookiesEnabled: !privacy.blockThirdPartyCookies,
      javaScriptEnabled: privacy.javaScriptEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final browserState = ref.watch(browserControllerProvider);
    final tabsState = ref.watch(tabsControllerProvider);
    final privacyState = ref.watch(privacyControllerProvider);
    final browserNotifier = ref.read(browserControllerProvider.notifier);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Sync active tab change
    final activeTab = tabsState.activeTab;
    if (activeTab != null && activeTab.id != _lastLoadedTabId) {
      _lastLoadedTabId = activeTab.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (activeTab.url.isNotEmpty && activeTab.url != browserState.url) {
          browserNotifier.loadUrl(activeTab.url);
        }
      });
    }

    return PopScope(
      canPop: !browserState.canGoBack,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (browserState.canGoBack) {
          await browserNotifier.goBack();
        }
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              const AddressBar(),
              if (browserState.isLoading)
                LinearProgressIndicator(
                  value: browserState.progress > 0
                      ? browserState.progress
                      : null,
                  minHeight: 2.5,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
              if (browserState.isFindInPageOpen) const FindInPageBar(),
              Expanded(
                child: Stack(
                  children: [
                    _buildWebView(
                      browserNotifier,
                      tabsState.isIncognitoMode,
                      privacyState.settings,
                    ),
                    if (browserState.url.isEmpty ||
                        browserState.url == 'about:blank')
                      _buildStartPage(context, theme, l10n, browserNotifier),
                  ],
                ),
              ),
              const BrowserNavigationBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWebView(
    BrowserController controller,
    bool isIncognito,
    PrivacySettings privacy,
  ) {
    if (InAppWebViewPlatform.instance == null) {
      return Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: const Text('WebView Preview'),
      );
    }

    return InAppWebView(
      initialSettings: _buildSettings(isIncognito, privacy),
      initialUrlRequest: URLRequest(url: WebUri(AppConstants.defaultHomePage)),
      findInteractionController: _findInteractionController,
      onWebViewCreated: (webController) {
        controller.setWebViewController(webController);

        _findInteractionController = FindInteractionController(
          onFindResultReceived:
              (
                findController,
                activeMatchOrdinal,
                numberOfMatches,
                isDoneCounting,
              ) {
                controller.onFindResultReceived(
                  activeMatchOrdinal,
                  numberOfMatches,
                );
              },
        );
        controller.setFindInteractionController(_findInteractionController);
      },
      shouldInterceptRequest: (webController, request) async {
        final urlString = request.url.toString();
        final privacyNotifier = ref.read(privacyControllerProvider.notifier);
        final blocker = ref.read(contentBlockerServiceProvider);

        if (!privacyNotifier.isOriginWhitelisted(urlString) &&
            blocker.shouldBlockUrl(
              urlString,
              adBlockEnabled: privacy.adBlockEnabled,
              trackerBlockEnabled: privacy.trackerBlockEnabled,
            )) {
          privacyNotifier.recordBlockedRequest();
          return WebResourceResponse(
            contentType: 'text/plain',
            data: Uint8List(0),
            statusCode: 200,
            reasonPhrase: 'OK',
          );
        }
        return null;
      },
      onPermissionRequest: (webController, request) async {
        return PermissionResponse(
          resources: request.resources,
          action: PermissionResponseAction.GRANT,
        );
      },
      onLoadStart: (webController, url) {
        ref.read(privacyControllerProvider.notifier).resetPageBlockedCount();

        // HTTPS-Only Mode upgrade
        if (privacy.httpsOnlyMode &&
            url != null &&
            url.scheme.toLowerCase() == 'http') {
          final upgraded =
              'https://${url.host}${url.path}${url.hasQuery ? '?${url.query}' : ''}';
          webController.loadUrl(urlRequest: URLRequest(url: WebUri(upgraded)));
          return;
        }

        controller.onUrlChanged(url);
        _syncTabUrlAndTitle(url?.toString(), null);
      },
      onLoadStop: (webController, url) {
        controller.onUrlChanged(url);
        _syncTabUrlAndTitle(url?.toString(), null);
        if (url != null) {
          ref
              .read(historyControllerProvider.notifier)
              .addVisit(
                url: url.toString(),
                title: ref.read(browserControllerProvider).title,
                isIncognito: isIncognito,
              );
        }
      },
      onProgressChanged: (webController, progress) {
        controller.onProgressChanged(progress);
      },
      onTitleChanged: (webController, title) {
        controller.onTitleChanged(title);
        _syncTabUrlAndTitle(null, title);
      },
      onUpdateVisitedHistory: (webController, url, isReload) {
        controller.onUrlChanged(url);
        _syncTabUrlAndTitle(url?.toString(), null);
      },
    );
  }

  void _syncTabUrlAndTitle(String? url, String? title) {
    final tabsNotifier = ref.read(tabsControllerProvider.notifier);
    final activeTab = ref.read(tabsControllerProvider).activeTab;
    if (activeTab != null) {
      tabsNotifier.updateActiveTabInfo(
        url: url ?? activeTab.url,
        title: title ?? activeTab.title,
      );
    }
  }

  Widget _buildStartPage(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
    BrowserController controller,
  ) {
    return Container(
      color: theme.colorScheme.surface,
      child: NewTabView(onNavigate: (url) => controller.loadUrl(url)),
    );
  }
}
