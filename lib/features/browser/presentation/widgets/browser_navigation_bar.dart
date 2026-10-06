import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';
import 'package:axomai_browser_mobile/features/browser/presentation/widgets/page_menu_sheet.dart';
import 'package:axomai_browser_mobile/features/tabs/controllers/tabs_controller.dart';

/// Bottom navigation toolbar for essential browser controls, tabs, and library.
class BrowserNavigationBar extends ConsumerWidget {
  const BrowserNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final browserState = ref.watch(browserControllerProvider);
    final tabsState = ref.watch(tabsControllerProvider);
    final controller = ref.read(browserControllerProvider.notifier);
    final theme = Theme.of(context);

    final isIncognito = tabsState.isIncognitoMode;
    final tabCount = isIncognito
        ? tabsState.incognitoTabs.length
        : tabsState.normalTabs.length;

    return Container(
      decoration: BoxDecoration(
        color: isIncognito
            ? const Color(0xFF14141C)
            : theme.colorScheme.surface,
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
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                tooltip: 'Back',
                onPressed: browserState.canGoBack
                    ? () => controller.goBack()
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios, size: 18),
                tooltip: 'Forward',
                onPressed: browserState.canGoForward
                    ? () => controller.goForward()
                    : null,
              ),
              // Tab Switcher Button
              IconButton(
                onPressed: () => context.push('/tabs'),
                tooltip: 'Tabs ($tabCount)',
                icon: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isIncognito
                          ? Colors.purpleAccent
                          : theme.colorScheme.primary,
                      width: 1.8,
                    ),
                  ),
                  child: Text(
                    isIncognito ? '$tabCount' : '$tabCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isIncognito
                          ? Colors.purpleAccent
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.collections_bookmark_outlined, size: 20),
                tooltip: 'Library',
                onPressed: () => context.push('/library'),
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, size: 20),
                tooltip: 'Share',
                onPressed: browserState.url.isNotEmpty
                    ? () => controller.shareCurrentPage()
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, size: 22),
                tooltip: 'More Options',
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                    ),
                    builder: (ctx) => const PageMenuSheet(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
