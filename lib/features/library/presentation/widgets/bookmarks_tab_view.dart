import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';
import 'package:axomai_browser_mobile/features/library/controllers/bookmarks_controller.dart';
import 'package:axomai_browser_mobile/features/tabs/controllers/tabs_controller.dart';

/// Tab view displaying saved bookmarks with folder filters and deletion.
class BookmarksTabView extends ConsumerWidget {
  const BookmarksTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksState = ref.watch(bookmarksControllerProvider);
    final notifier = ref.read(bookmarksControllerProvider.notifier);
    final theme = Theme.of(context);

    final bookmarks = bookmarksState.filteredBookmarks;

    return Column(
      children: <Widget>[
        // Folder Filter Chips
        if (bookmarksState.folders.isNotEmpty)
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: const Text('All'),
                    selected: bookmarksState.selectedFolder == null,
                    onSelected: (_) => notifier.filterByFolder(null),
                  ),
                ),
                ...bookmarksState.folders.map((folder) {
                  final isSelected = bookmarksState.selectedFolder == folder;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(folder),
                      selected: isSelected,
                      onSelected: (_) =>
                          notifier.filterByFolder(isSelected ? null : folder),
                    ),
                  );
                }),
              ],
            ),
          ),
        const Divider(height: 1),
        Expanded(
          child: bookmarks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 64,
                        color: theme.colorScheme.primary.withAlpha(120),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Bookmarks Yet',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Tap the star icon while browsing to bookmark a page.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: bookmarks.length,
                  itemBuilder: (context, index) {
                    final item = bookmarks[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          Icons.bookmark,
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${item.folder} • ${item.url}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        tooltip: 'Delete',
                        onPressed: item.id != null
                            ? () => notifier.removeBookmark(item.id!)
                            : null,
                      ),
                      onTap: () {
                        // Open in active tab
                        ref
                            .read(tabsControllerProvider.notifier)
                            .updateActiveTabInfo(
                              url: item.url,
                              title: item.title,
                            );
                        ref
                            .read(browserControllerProvider.notifier)
                            .loadUrl(item.url);
                        context.pop();
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
