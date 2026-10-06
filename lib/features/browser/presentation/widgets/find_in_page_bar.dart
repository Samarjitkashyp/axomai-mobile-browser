import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';

/// Interactive toolbar for in-page text search and match navigation.
class FindInPageBar extends ConsumerStatefulWidget {
  const FindInPageBar({super.key});

  @override
  ConsumerState<FindInPageBar> createState() => _FindInPageBarState();
}

class _FindInPageBarState extends ConsumerState<FindInPageBar> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final browserState = ref.watch(browserControllerProvider);
    final theme = Theme.of(context);

    final matchText = browserState.findQuery.isEmpty
        ? ''
        : (browserState.findTotalMatches > 0
              ? '${browserState.findCurrentIndex + 1}/${browserState.findTotalMatches}'
              : '0/0');

    return Material(
      elevation: 4,
      color: theme.colorScheme.surfaceContainer,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: <Widget>[
            const Icon(Icons.search, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Find in page...',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (val) {
                  ref
                      .read(browserControllerProvider.notifier)
                      .searchInPage(val);
                },
                onSubmitted: (_) {
                  ref.read(browserControllerProvider.notifier).findNext();
                },
              ),
            ),
            if (matchText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6.0),
                child: Text(
                  matchText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: browserState.findTotalMatches > 0
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_up, size: 22),
              tooltip: 'Previous match',
              onPressed: browserState.findTotalMatches > 0
                  ? () => ref
                        .read(browserControllerProvider.notifier)
                        .findPrevious()
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.keyboard_arrow_down, size: 22),
              tooltip: 'Next match',
              onPressed: browserState.findTotalMatches > 0
                  ? () =>
                        ref.read(browserControllerProvider.notifier).findNext()
                  : null,
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              tooltip: 'Close',
              onPressed: () {
                ref.read(browserControllerProvider.notifier).closeFindInPage();
              },
            ),
          ],
        ),
      ),
    );
  }
}
