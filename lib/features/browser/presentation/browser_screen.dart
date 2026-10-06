import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/core/constants/app_constants.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';
import 'package:axomai_browser_mobile/features/browser/presentation/widgets/address_bar.dart';
import 'package:axomai_browser_mobile/features/browser/presentation/widgets/browser_navigation_bar.dart';
import 'package:axomai_browser_mobile/features/browser/presentation/widgets/find_in_page_bar.dart';
import 'package:axomai_browser_mobile/l10n/app_localizations.dart';

/// Primary browser container managing WebView, AddressBar, and Navigation.
class BrowserScreen extends ConsumerStatefulWidget {
  const BrowserScreen({super.key});

  @override
  ConsumerState<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends ConsumerState<BrowserScreen> {
  FindInteractionController? _findInteractionController;

  final InAppWebViewSettings _settings = InAppWebViewSettings(
    isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    useHybridComposition: true,
    supportZoom: true,
    builtInZoomControls: true,
    displayZoomControls: false,
  );

  @override
  Widget build(BuildContext context) {
    final browserState = ref.watch(browserControllerProvider);
    final controller = ref.read(browserControllerProvider.notifier);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: !browserState.canGoBack,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (browserState.canGoBack) {
          await controller.goBack();
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
                    _buildWebView(controller),
                    if (browserState.url.isEmpty)
                      _buildStartPage(context, theme, l10n, controller),
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

  Widget _buildWebView(BrowserController controller) {
    // Check if platform implementation is initialized (prevents headless test crashes)
    if (InAppWebViewPlatform.instance == null) {
      return Container(
        color: Colors.transparent,
        alignment: Alignment.center,
        child: const Text('WebView Preview'),
      );
    }

    return InAppWebView(
      initialSettings: _settings,
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
      onLoadStart: (webController, url) {
        controller.onUrlChanged(url);
      },
      onLoadStop: (webController, url) {
        controller.onUrlChanged(url);
      },
      onProgressChanged: (webController, progress) {
        controller.onProgressChanged(progress);
      },
      onTitleChanged: (webController, title) {
        controller.onTitleChanged(title);
      },
      onUpdateVisitedHistory: (webController, url, isReload) {
        controller.onUrlChanged(url);
      },
    );
  }

  Widget _buildStartPage(
    BuildContext context,
    ThemeData theme,
    AppLocalizations? l10n,
    BrowserController controller,
  ) {
    return Container(
      color: theme.colorScheme.surface,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.public,
                size: 56,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n?.welcomeTitle ?? 'Axomai Browser',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.welcomeSubtitle ??
                  'Fast, private, Assam-themed intelligent browsing.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildQuickLinksGrid(controller, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickLinksGrid(BrowserController controller, ThemeData theme) {
    final quickLinks = [
      {
        'title': 'Google',
        'url': 'https://www.google.com',
        'icon': Icons.search,
      },
      {
        'title': 'Wikipedia',
        'url': 'https://www.wikipedia.org',
        'icon': Icons.menu_book,
      },
      {
        'title': 'Assam Govt',
        'url': 'https://assam.gov.in',
        'icon': Icons.account_balance,
      },
      {
        'title': 'Axom AI',
        'url': 'https://axomai.co.in',
        'icon': Icons.auto_awesome,
      },
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: quickLinks.map((item) {
        return InkWell(
          onTap: () => controller.loadUrl(item['url'] as String),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 76,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  child: Icon(
                    item['icon'] as IconData,
                    color: theme.colorScheme.onSecondaryContainer,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['title'] as String,
                  style: theme.textTheme.labelSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
