import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/home/controllers/home_feed_controller.dart';
import 'package:axomai_browser_mobile/features/home/domain/quick_link.dart';

/// Chrome & JioSphere style Top Sites / Quick Shortcuts Grid.
class QuickLinksGrid extends ConsumerWidget {
  final void Function(String url) onOpenUrl;

  const QuickLinksGrid({super.key, required this.onOpenUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final homeState = ref.watch(homeFeedProvider);
    final links = homeState.quickLinks;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Sites',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
                InkWell(
                  onTap: () => _showAddShortcutDialog(context, ref),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_circle_outline_rounded,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Add',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: links.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final link = links[index];
              return _QuickLinkTile(
                link: link,
                onTap: () => onOpenUrl(link.url),
                onLongPress: () => _showOptionsSheet(context, ref, link),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddShortcutDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final urlController = TextEditingController(text: 'https://');

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Shortcut'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. News Portal',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://example.com',
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final title = titleController.text.trim();
              final url = urlController.text.trim();
              if (title.isNotEmpty && url.isNotEmpty) {
                ref.read(homeFeedProvider.notifier).addQuickLink(title, url);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showOptionsSheet(BuildContext context, WidgetRef ref, QuickLink link) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_browser_rounded),
              title: Text('Open ${link.title}'),
              onTap: () {
                Navigator.pop(ctx);
                onOpenUrl(link.url);
              },
            ),
            if (link.isCustom)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                ),
                title: const Text(
                  'Remove Shortcut',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  ref.read(homeFeedProvider.notifier).removeQuickLink(link.id);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _QuickLinkTile extends StatelessWidget {
  final QuickLink link;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _QuickLinkTile({
    required this.link,
    required this.onTap,
    required this.onLongPress,
  });

  IconData _getIconForLink(String title, String url) {
    final lowerTitle = title.toLowerCase();
    final lowerUrl = url.toLowerCase();
    if (lowerTitle.contains('google') || lowerUrl.contains('google')) {
      return Icons.search_rounded;
    }
    if (lowerTitle.contains('youtube') || lowerUrl.contains('youtube')) {
      return Icons.play_arrow_rounded;
    }
    if (lowerTitle.contains('assam') || lowerUrl.contains('assam.gov')) {
      return Icons.account_balance_rounded;
    }
    if (lowerTitle.contains('wiki') || lowerUrl.contains('wikipedia')) {
      return Icons.menu_book_rounded;
    }
    if (lowerTitle.contains('news') || lowerUrl.contains('sentinel')) {
      return Icons.newspaper_rounded;
    }
    if (lowerTitle.contains('pratidin')) {
      return Icons.article_rounded;
    }
    return Icons.language_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconData = _getIconForLink(link.title, link.url);

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.8,
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(iconData, color: theme.colorScheme.primary, size: 24),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            link.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
