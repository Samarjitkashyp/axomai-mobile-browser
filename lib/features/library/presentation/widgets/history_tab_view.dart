import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';
import 'package:axomai_browser_mobile/features/library/controllers/history_controller.dart';
import 'package:axomai_browser_mobile/features/tabs/controllers/tabs_controller.dart';

/// Tab view displaying browsing history grouped by date with search and delete.
class HistoryTabView extends ConsumerStatefulWidget {
  const HistoryTabView({super.key});

  @override
  ConsumerState<HistoryTabView> createState() => _HistoryTabViewState();
}

class _HistoryTabViewState extends ConsumerState<HistoryTabView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Browsing History?'),
        content: const Text(
          'This will permanently remove all browsing history from this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              ref.read(historyControllerProvider.notifier).clearAllHistory();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyControllerProvider);
    final historyNotifier = ref.read(historyControllerProvider.notifier);
    final theme = Theme.of(context);

    final grouped = historyState.groupedItems;

    return Column(
      children: <Widget>[
        // Search bar & Clear history
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search history...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    isDense: true,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withAlpha(120),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              historyNotifier.search('');
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (val) {
                    historyNotifier.search(val);
                    setState(() {});
                  },
                ),
              ),
              if (historyState.items.isNotEmpty) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: 'Clear History',
                  onPressed: () => _confirmClearHistory(context),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: historyState.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: theme.colorScheme.primary.withAlpha(120),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        historyState.searchQuery.isNotEmpty
                            ? 'No Matching History Found'
                            : 'No History Yet',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                )
              : ListView(
                  children: grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                          child: Text(
                            entry.key,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        ...entry.value.map((item) {
                          return ListTile(
                            leading: CircleAvatar(
                              radius: 16,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.public, size: 18),
                            ),
                            title: Text(
                              item.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              item.url,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              tooltip: 'Delete',
                              onPressed: item.id != null
                                  ? () => historyNotifier.deleteHistoryItem(
                                      item.id!,
                                    )
                                  : null,
                            ),
                            onTap: () {
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
                        }),
                      ],
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}
