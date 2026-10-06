import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:axomai_browser_mobile/features/tabs/controllers/tabs_controller.dart';
import 'package:axomai_browser_mobile/features/tabs/presentation/widgets/tab_card.dart';

/// Fullscreen grid interface for browsing, creating, and closing tabs.
class TabSwitcherScreen extends ConsumerWidget {
  const TabSwitcherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsState = ref.watch(tabsControllerProvider);
    final tabsNotifier = ref.read(tabsControllerProvider.notifier);
    final theme = Theme.of(context);

    final isIncognito = tabsState.isIncognitoMode;
    final currentTabs = tabsState.currentTabs;

    return Scaffold(
      backgroundColor: isIncognito
          ? const Color(0xFF0F0F14)
          : theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: isIncognito
            ? const Color(0xFF14141C)
            : theme.colorScheme.surface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: SegmentedButton<bool>(
          segments: [
            ButtonSegment<bool>(
              value: false,
              icon: const Icon(Icons.tab, size: 16),
              label: Text('Tabs (${tabsState.normalTabs.length})'),
            ),
            ButtonSegment<bool>(
              value: true,
              icon: const Icon(Icons.visibility_off, size: 16),
              label: Text('Private (${tabsState.incognitoTabs.length})'),
            ),
          ],
          selected: {isIncognito},
          onSelectionChanged: (selection) {
            tabsNotifier.setIncognitoMode(selection.first);
          },
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'close_all') {
                tabsNotifier.closeAllTabs(incognitoOnly: isIncognito);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'close_all',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_sweep_outlined,
                      size: 20,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isIncognito ? 'Close Private Tabs' : 'Close All Tabs',
                      style: TextStyle(color: theme.colorScheme.error),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: currentTabs.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isIncognito ? Icons.visibility_off : Icons.tab,
                    size: 64,
                    color: isIncognito
                        ? Colors.purpleAccent.withAlpha(120)
                        : theme.colorScheme.primary.withAlpha(120),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isIncognito ? 'No Private Tabs Open' : 'No Tabs Open',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isIncognito ? Colors.white70 : null,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isIncognito
                        ? 'Browsing history and cookies will not be saved.'
                        : 'Tap + below to open a new tab.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isIncognito
                          ? Colors.white54
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: currentTabs.length,
              itemBuilder: (context, index) {
                final tab = currentTabs[index];
                final isSelected = tab.id == tabsState.activeTabId;

                return TabCard(
                  tab: tab,
                  isSelected: isSelected,
                  onTap: () {
                    tabsNotifier.selectTab(tab.id);
                    context.pop();
                  },
                  onClose: () {
                    tabsNotifier.closeTab(tab.id);
                  },
                );
              },
            ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () {
                  tabsNotifier.createNewTab(isIncognito: isIncognito);
                  context.pop();
                },
                icon: const Icon(Icons.add),
                label: const Text('New Tab'),
              ),
              FilledButton(
                onPressed: () => context.pop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
