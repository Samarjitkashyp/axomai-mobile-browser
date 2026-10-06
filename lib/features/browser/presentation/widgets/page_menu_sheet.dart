import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/presentation/ai_assistant_sheet.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';
import 'package:axomai_browser_mobile/features/library/controllers/bookmarks_controller.dart';
import 'package:axomai_browser_mobile/features/reader/controllers/reader_controller.dart';

/// Overflow actions sheet for current page (Reader Mode, Desktop Site, Zoom, Sharing).
class PageMenuSheet extends ConsumerWidget {
  const PageMenuSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final browserState = ref.watch(browserControllerProvider);
    final browserNotifier = ref.read(browserControllerProvider.notifier);
    final readerNotifier = ref.read(readerControllerProvider.notifier);
    final bookmarksNotifier = ref.read(bookmarksControllerProvider.notifier);

    final isPageLoaded = browserState.url.isNotEmpty;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Top action buttons row (Reload, Bookmark, Share, Settings)
            Row(
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
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/settings');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),

            // Axom AI Assistant Action
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(6),
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
                  size: 18,
                ),
              ),
              title: const Text(
                'Axom AI Assistant',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('Summarize, translate, or explain page'),
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
              leading: Icon(
                Icons.chrome_reader_mode_outlined,
                color: theme.colorScheme.primary,
              ),
              title: const Text(
                'Reader Mode',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Read article without distraction and ads'),
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

            // Desktop Site Switch
            SwitchListTile.adaptive(
              secondary: const Icon(Icons.desktop_windows_outlined),
              title: const Text(
                'Desktop Site',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: const Text('Request computer version of this webpage'),
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
              leading: const Icon(Icons.find_in_page_outlined),
              title: const Text(
                'Find in Page',
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
              leading: const Icon(Icons.zoom_in_outlined),
              title: const Text(
                'Page Zoom',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.remove_rounded, size: 18),
                    onPressed: isPageLoaded
                        ? () => browserNotifier.zoomOut()
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${(browserState.pageZoom * 100).toInt()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    onPressed: isPageLoaded
                        ? () => browserNotifier.zoomIn()
                        : null,
                  ),
                ],
              ),
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
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
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
