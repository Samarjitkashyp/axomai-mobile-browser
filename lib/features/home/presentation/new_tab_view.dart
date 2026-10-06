import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/presentation/ai_assistant_sheet.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/search_engine_controller.dart';
import 'package:axomai_browser_mobile/features/home/controllers/home_feed_controller.dart';
import 'package:axomai_browser_mobile/features/home/presentation/widgets/assam_news_section.dart';

/// Chrome & JioSphere inspired modern New Tab Page with tea garden background & news feed.
class NewTabView extends ConsumerWidget {
  final void Function(String queryOrUrl) onNavigate;
  final VoidCallback? onSearchFocus;

  const NewTabView({super.key, required this.onNavigate, this.onSearchFocus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchEngine = ref.watch(searchEngineControllerProvider);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      children: [
        // Background Tea Garden Image
        Positioned.fill(
          child: Image.asset(
            'assets/images/home_bg.jpg',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                Container(color: theme.scaffoldBackgroundColor),
          ),
        ),
        // Dark Overlay for Contrast & Visual Polish
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.50),
                  Colors.black.withValues(alpha: 0.75),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              // Top Half: Centered Axomai Logo & Floating Search Capsule
              Expanded(
                flex: 5,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.asset(
                                  'assets/images/axomai_logo.png',
                                  width: 64,
                                  height: 64,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 64,
                                        height: 64,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              theme.colorScheme.primary,
                                              theme.colorScheme.tertiary,
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.explore_rounded,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'AXOMAI',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.5,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Smart Mobile Browser',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                letterSpacing: 0.6,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Floating Search Capsule
                        InkWell(
                          onTap: () {
                            if (onSearchFocus != null) {
                              onSearchFocus!();
                            } else {
                              _showSearchModal(context, searchEngine.name);
                            }
                          },
                          borderRadius: BorderRadius.circular(28),
                          child: Container(
                            height: 52,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  size: 22,
                                  color: Color(0xFF10B981),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Search or type URL',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.75,
                                      ),
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 20,
                                  ),
                                  color: const Color(0xFFF59E0B),
                                  tooltip: 'Axom AI',
                                  onPressed: () {
                                    showModalBottomSheet<void>(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(28),
                                        ),
                                      ),
                                      builder: (ctx) =>
                                          const AiAssistantSheet(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Half: Dedicated Half-Screen News Container
              Expanded(
                flex: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF111C2E).withValues(alpha: 0.94)
                        : Colors.white.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 14,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: RefreshIndicator(
                    onRefresh: () =>
                        ref.read(homeFeedProvider.notifier).refreshFeed(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      child: AssamNewsSection(onOpenArticle: onNavigate),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSearchModal(BuildContext context, String engineName) {
    final searchController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.go,
                  decoration: InputDecoration(
                    hintText: 'Search with $engineName or enter address',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded),
                      onPressed: () {
                        final val = searchController.text.trim();
                        if (val.isNotEmpty) {
                          Navigator.pop(ctx);
                          onNavigate(val);
                        }
                      },
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      Navigator.pop(ctx);
                      onNavigate(val.trim());
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
