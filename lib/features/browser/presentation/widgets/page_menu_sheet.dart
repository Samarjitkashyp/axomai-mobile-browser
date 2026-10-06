import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/presentation/ai_assistant_sheet.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';
import 'package:axomai_browser_mobile/features/library/controllers/bookmarks_controller.dart';
import 'package:axomai_browser_mobile/features/reader/controllers/reader_controller.dart';
import 'package:axomai_browser_mobile/features/tabs/controllers/tabs_controller.dart';

/// Chrome & JioSphere inspired Page Menu Bottom Sheet.
class PageMenuSheet extends ConsumerWidget {
  const PageMenuSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final browserState = ref.watch(browserControllerProvider);
    final browserNotifier = ref.read(browserControllerProvider.notifier);
    final readerNotifier = ref.read(readerControllerProvider.notifier);
    final bookmarksNotifier = ref.read(bookmarksControllerProvider.notifier);
    final tabsNotifier = ref.read(tabsControllerProvider.notifier);

    final isPageLoaded =
        browserState.url.isNotEmpty && browserState.url != 'about:blank';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Pill
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.6,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Top Action Icons Strip (Forward, Reload, Bookmark, Share, Downloads)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MenuIconButton(
                    icon: Icons.refresh_rounded,
                    label: 'Reload',
                    onTap: () {
                      Navigator.pop(context);
                      browserNotifier.reload();
                    },
                  ),
                  _MenuIconButton(
                    icon: Icons.star_border_rounded,
                    label: 'Bookmark',
                    onTap: isPageLoaded
                        ? () {
                            Navigator.pop(context);
                            bookmarksNotifier.toggleBookmark(
                              title: browserState.title,
                              url: browserState.url,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bookmark updated.'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }
                        : null,
                  ),
                  _MenuIconButton(
                    icon: Icons.share_outlined,
                    label: 'Share',
                    onTap: isPageLoaded
                        ? () {
                            Navigator.pop(context);
                            browserNotifier.shareCurrentPage();
                          }
                        : null,
                  ),
                  _MenuIconButton(
                    icon: Icons.download_rounded,
                    label: 'Downloads',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/library');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // New Tab / New Incognito Tab Row
            ListTile(
              dense: true,
              leading: const Icon(Icons.add_box_outlined),
              title: const Text(
                'New tab',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                tabsNotifier.createNewTab(isIncognito: false);
                browserNotifier.goHome();
              },
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text(
                'New Incognito tab',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                tabsNotifier.createNewTab(isIncognito: true);
                browserNotifier.goHome();
              },
            ),

            const Divider(height: 16),

            // History & Bookmarks
            ListTile(
              dense: true,
              leading: const Icon(Icons.history_rounded),
              title: const Text(
                'History',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/library');
              },
            ),
            ListTile(
              dense: true,
              leading: const Icon(Icons.bookmarks_outlined),
              title: const Text(
                'Bookmarks',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/library');
              },
            ),

            const Divider(height: 16),

            // Axom AI Assistant
            ListTile(
              dense: true,
              leading: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.tertiary,
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              title: const Text(
                'Axom AI Assistant',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Summarize, explain or translate page'),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  builder: (ctx) => const AiAssistantSheet(),
                );
              },
            ),

            // Reader Mode Action
            ListTile(
              dense: true,
              leading: Icon(
                Icons.chrome_reader_mode_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text(
                'Reader Mode',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Distraction-free reading'),
              enabled: isPageLoaded,
              onTap: () async {
                Navigator.pop(context);
                final success = await readerNotifier.openReader(
                  browserNotifier.webViewController,
                  fallbackTitle: browserState.title,
                  fallbackUrl: browserState.url,
                );
                if (!success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Unable to extract article from this page.',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),

            // Desktop Site Switch (Chrome style)
            SwitchListTile.adaptive(
              dense: true,
              secondary: const Icon(Icons.desktop_windows_outlined),
              title: const Text(
                'Desktop site',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              value: browserState.isDesktopMode,
              onChanged: isPageLoaded
                  ? (val) {
                      Navigator.pop(context);
                      browserNotifier.toggleDesktopMode();
                    }
                  : null,
            ),

            // Find in Page
            ListTile(
              dense: true,
              leading: const Icon(Icons.find_in_page_outlined),
              title: const Text(
                'Find in page',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              enabled: isPageLoaded,
              onTap: () {
                Navigator.pop(context);
                browserNotifier.openFindInPage();
              },
            ),

            // Page Zoom Controls
            ListTile(
              dense: true,
              leading: const Icon(Icons.zoom_in_outlined),
              title: const Text(
                'Page Zoom',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.filledTonal(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.remove_rounded, size: 16),
                    onPressed: isPageLoaded
                        ? () => browserNotifier.zoomOut()
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '${(browserState.pageZoom * 100).toInt()}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton.filledTonal(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.add_rounded, size: 16),
                    onPressed: isPageLoaded
                        ? () => browserNotifier.zoomIn()
                        : null,
                  ),
                ],
              ),
            ),

            const Divider(height: 16),

            // Settings
            ListTile(
              dense: true,
              leading: const Icon(Icons.settings_outlined),
              title: const Text(
                'Settings',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _MenuIconButton({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: enabled
                    ? theme.colorScheme.primaryContainer
                    : theme.colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: enabled
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: enabled
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
