import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/presentation/ai_assistant_sheet.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/presentation/widgets/search_suggestions_dropdown.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';
import 'package:axomai_browser_mobile/features/browser/presentation/widgets/page_menu_sheet.dart';
import 'package:axomai_browser_mobile/features/library/controllers/bookmarks_controller.dart';
import 'package:axomai_browser_mobile/l10n/app_localizations.dart';

/// Top Address / Omnibox bar with Chrome & JioSphere style domain formatting.
class AddressBar extends ConsumerStatefulWidget {
  const AddressBar({super.key});

  @override
  ConsumerState<AddressBar> createState() => _AddressBarState();
}

class _AddressBarState extends ConsumerState<AddressBar> {
  late final TextEditingController _textController;
  final FocusNode _focusNode = FocusNode();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      _isEditing = _focusNode.hasFocus;
      if (_focusNode.hasFocus) {
        _textController.text = ref.read(browserControllerProvider).url;
        _textController.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _textController.text.length,
        );
      }
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _submit(String value) {
    if (value.trim().isEmpty) return;
    _focusNode.unfocus();
    ref.read(browserControllerProvider.notifier).loadUrl(value);
  }

  String _formatDisplayDomain(String rawUrl) {
    if (rawUrl.isEmpty || rawUrl == 'about:blank') return '';
    try {
      final uri = Uri.parse(rawUrl);
      if (uri.host.isNotEmpty) {
        return uri.host.replaceFirst('www.', '');
      }
    } catch (_) {}
    return rawUrl;
  }

  @override
  Widget build(BuildContext context) {
    final browserState = ref.watch(browserControllerProvider);
    final bookmarksState = ref.watch(bookmarksControllerProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final displayDomain = _formatDisplayDomain(browserState.url);
    final isBookmarked = bookmarksState.bookmarks.any(
      (b) => b.url.trim() == browserState.url.trim(),
    );

    if (!_isEditing && _textController.text != browserState.url) {
      _textController.text = displayDomain;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          color: theme.colorScheme.surface,
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _isEditing
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.65,
                    ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: _isEditing
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
                width: 1.2,
              ),
            ),
            child: Row(
              children: <Widget>[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    _focusNode.unfocus();
                    ref.read(browserControllerProvider.notifier).goHome();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Icon(
                      Icons.home_rounded,
                      size: 19,
                      color: browserState.url.isEmpty
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.go,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    onChanged: (text) => setState(() {}),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      fontWeight: _isEditing
                          ? FontWeight.normal
                          : FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: l10n?.selectLanguage != null
                          ? 'Search or type URL'
                          : 'Search or enter address',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.6,
                        ),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    onSubmitted: _submit,
                  ),
                ),
                // Axom AI Assistant Sparkle Button
                if (browserState.url.isNotEmpty && !_isEditing)
                  IconButton(
                    icon: const Icon(Icons.auto_awesome_rounded, size: 19),
                    tooltip: 'Axom AI Assistant',
                    color: theme.colorScheme.primary,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () {
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
                if (browserState.url.isNotEmpty && !_isEditing)
                  IconButton(
                    icon: Icon(
                      isBookmarked
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 20,
                      color: isBookmarked ? Colors.amber : null,
                    ),
                    tooltip: isBookmarked ? 'Bookmarked' : 'Add Bookmark',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () {
                      ref
                          .read(bookmarksControllerProvider.notifier)
                          .toggleBookmark(
                            title: browserState.title,
                            url: browserState.url,
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 1),
                          content: Text(
                            isBookmarked
                                ? 'Bookmark removed'
                                : 'Page bookmarked to Mobile Bookmarks',
                          ),
                        ),
                      );
                    },
                  ),
                if (_isEditing && _textController.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.cancel_rounded, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    onPressed: () {
                      _textController.clear();
                      setState(() {});
                    },
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded, size: 21),
                    tooltip: 'More Options',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
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
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
        if (_isEditing && _textController.text.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SearchSuggestionsDropdown(
              query: _textController.text,
              onSelect: _submit,
            ),
          ),
      ],
    );
  }
}
