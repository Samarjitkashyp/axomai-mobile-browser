import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/presentation/ai_assistant_sheet.dart';
import 'package:axomai_browser_mobile/features/home/controllers/home_feed_controller.dart';
import 'package:axomai_browser_mobile/features/home/presentation/widgets/assam_news_section.dart';

/// Google-style centered hero layout with direct center search typing and ~1.5 Assam news items peeking from bottom.
class NewTabView extends ConsumerStatefulWidget {
  final void Function(String queryOrUrl) onNavigate;
  final VoidCallback? onSearchFocus;

  const NewTabView({super.key, required this.onNavigate, this.onSearchFocus});

  @override
  ConsumerState<NewTabView> createState() => _NewTabViewState();
}

class _NewTabViewState extends ConsumerState<NewTabView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _hasSearchText = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final hasText = _searchController.text.trim().isNotEmpty;
      if (hasText != _hasSearchText) {
        setState(() {
          _hasSearchText = hasText;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _submitSearch([String? text]) {
    final query = (text ?? _searchController.text).trim();
    if (query.isNotEmpty) {
      _searchFocusNode.unfocus();
      widget.onNavigate(query);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                const SizedBox(height: 12),
                                Text(
                                  'AXOMAI Browser',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.8,
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Fast  •  Privacy Focused  •  Extreme Security',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                    letterSpacing: 0.8,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Interactive Direct-Typing Search Capsule
                                Container(
                                  height: 52,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.48),
                                    borderRadius: BorderRadius.circular(28),
                                    border: Border.all(
                                      color: _searchFocusNode.hasFocus
                                          ? const Color(0xFF10B981)
                                          : Colors.white.withValues(
                                              alpha: 0.25,
                                            ),
                                      width: _searchFocusNode.hasFocus
                                          ? 1.6
                                          : 1.2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.25,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.search_rounded,
                                          size: 22,
                                          color: Color(0xFF10B981),
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () => _submitSearch(),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextField(
                                          controller: _searchController,
                                          focusNode: _searchFocusNode,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          cursorColor: const Color(0xFF10B981),
                                          textInputAction:
                                              TextInputAction.search,
                                          keyboardType: TextInputType.url,
                                          autocorrect: false,
                                          onSubmitted: (value) =>
                                              _submitSearch(value),
                                          decoration: InputDecoration(
                                            hintText: 'Search or type URL',
                                            hintStyle: TextStyle(
                                              color: Colors.white.withValues(
                                                alpha: 0.65,
                                              ),
                                              fontSize: 15,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                  vertical: 8,
                                                ),
                                          ),
                                        ),
                                      ),
                                      if (_hasSearchText)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close_rounded,
                                            size: 18,
                                            color: Colors.white70,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          onPressed: () {
                                            _searchController.clear();
                                          },
                                        )
                                      else
                                        IconButton(
                                          icon: const Icon(
                                            Icons.auto_awesome_rounded,
                                            size: 20,
                                          ),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
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
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Assam News Highlights Feed (First ~1.5 items peek up at bottom of screen)
                      AssamNewsSection(onOpenArticle: widget.onNavigate),
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
