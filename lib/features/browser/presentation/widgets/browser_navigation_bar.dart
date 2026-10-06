import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';

/// Bottom navigation toolbar for essential browser controls.
class BrowserNavigationBar extends ConsumerWidget {
  const BrowserNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browserState = ref.watch(browserControllerProvider);
    final controller = ref.read(browserControllerProvider.notifier);
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(80),
            width: 0.8,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                tooltip: 'Back',
                onPressed: browserState.canGoBack
                    ? () => controller.goBack()
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 20),
                tooltip: 'Forward',
                onPressed: browserState.canGoForward
                    ? () => controller.goForward()
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.find_in_page_outlined, size: 22),
                tooltip: 'Find in Page',
                onPressed: browserState.url.isNotEmpty
                    ? () => controller.openFindInPage()
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 22),
                tooltip: 'Share',
                onPressed: browserState.url.isNotEmpty
                    ? () => controller.shareCurrentPage()
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, size: 22),
                tooltip: 'Settings',
                onPressed: () => context.push('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
