import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';
import 'package:axomai_browser_mobile/features/browser/presentation/widgets/page_menu_sheet.dart';
import 'package:axomai_browser_mobile/features/tabs/controllers/tabs_controller.dart';

/// Chrome & JioSphere style Bottom Navigation Toolbar.
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
            ? const Color(0xFF13131A)
            : theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
            width: 1.0,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 52,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              // Back Navigation
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                tooltip: 'Back',
                onPressed: browserState.canGoBack
                    ? () => controller.goBack()
                    : null,
              ),
              // Forward Navigation
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 20),
                tooltip: 'Forward',
                onPressed: browserState.canGoForward
                    ? () => controller.goForward()
                    : null,
              ),
              // Home / New Tab Button
              IconButton(
                icon: const Icon(Icons.home_rounded, size: 24),
                tooltip: 'Home',
                onPressed: () => controller.goHome(),
              ),
              // Chrome-Style Tab Counter Badge
              IconButton(
                onPressed: () => context.push('/tabs'),
                tooltip: 'Tabs ($tabCount)',
                icon: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: isIncognito
                          ? Colors.purpleAccent
                          : theme.colorScheme.primary,
                      width: 2.0,
                    ),
                  ),
                  child: Text(
                    '$tabCount',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isIncognito
                          ? Colors.purpleAccent
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
              // Library / Bookmarks
              IconButton(
                icon: const Icon(Icons.collections_bookmark_outlined, size: 21),
                tooltip: 'Library',
                onPressed: () => context.push('/library'),
              ),
              // 3-Dots More Menu
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, size: 23),
                tooltip: 'More Options',
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(28),
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
