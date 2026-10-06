import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/presentation/ai_assistant_sheet.dart';
import 'package:axomai_browser_mobile/features/home/controllers/home_feed_controller.dart';
import 'package:axomai_browser_mobile/features/home/presentation/widgets/assam_news_section.dart';

/// Google-style centered hero layout with ~1.5 news items peeking from bottom on initial screen.
class NewTabView extends ConsumerWidget {
  final void Function(String queryOrUrl) onNavigate;
  final VoidCallback? onSearchFocus;

  const NewTabView({super.key, required this.onNavigate, this.onSearchFocus});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

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
                  Colors.black.withValues(alpha: 0.52),
                  Colors.black.withValues(alpha: 0.78),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Calculate hero height so logo + search bar are centered Google-style
              // and ~1.5 news cards peek out from the bottom of the screen.
              final viewportHeight = constraints.maxHeight;
              final heroHeight = (viewportHeight * 0.50).clamp(280.0, 430.0);

              return RefreshIndicator(
                onRefresh: () =>
                    ref.read(homeFeedProvider.notifier).refreshFeed(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      // Google-style Centered Hero Section (Logo + Search Capsule)
                      SizedBox(
                        height: heroHeight,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Axom AI Logo Badge
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.45,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.asset(
                                      'assets/images/axomai_logo.png',
                                      width: 68,
                                      height: 68,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (
                                            context,
                                            error,
                                            stackTrace,
                                          ) => Container(
                                            width: 68,
                                            height: 68,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  theme.colorScheme.primary,
                                                  theme.colorScheme.tertiary,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: const Icon(
                                              Icons.explore_rounded,
                                              color: Colors.white,
                                              size: 34,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
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
                                const SizedBox(height: 20),

                                // Floating Search Capsule (Focuses top search bar directly without bottom modal)
                                InkWell(
                                  onTap: () => onSearchFocus?.call(),
                                  borderRadius: BorderRadius.circular(28),
                                  child: Container(
                                    height: 52,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.45,
                                      ),
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.25,
                                        ),
                                        width: 1.2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
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
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.75),
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
                                              shape:
                                                  const RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            28,
                                                          ),
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

                      // Assam News Highlights Feed (First ~1.5 items peek up at bottom of screen)
                      AssamNewsSection(onOpenArticle: onNavigate),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
