import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/core/localization/locale_controller.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/controllers/ai_assistant_controller.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/domain/ai_message.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';
import 'package:axomai_browser_mobile/features/browser/domain/browser_state.dart';
import 'package:axomai_browser_mobile/features/reader/data/reader_extractor.dart';

/// Axom AI Assistant Bottom Sheet providing on-device page summarization and QA.
class AiAssistantSheet extends ConsumerStatefulWidget {
  const AiAssistantSheet({super.key});

  @override
  ConsumerState<AiAssistantSheet> createState() => _AiAssistantSheetState();
}

class _AiAssistantSheetState extends ConsumerState<AiAssistantSheet> {
  final TextEditingController _queryController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _queryController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final aiState = ref.watch(aiAssistantControllerProvider);
    final aiNotifier = ref.read(aiAssistantControllerProvider.notifier);
    final browserState = ref.watch(browserControllerProvider);
    final browserNotifier = ref.read(browserControllerProvider.notifier);
    final currentLocale = ref.watch(localeControllerProvider);

    final langCode = currentLocale?.languageCode ?? 'en';
    final hasPage = browserState.url.isNotEmpty;

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Drag Handle & Title
            Padding(
              padding: const EdgeInsets.only(
                top: 12,
                left: 20,
                right: 12,
                bottom: 8,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
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
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Axom AI Assistant',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Private On-Device Intelligence',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded),
                    tooltip: 'Reset Conversation',
                    onPressed: () => aiNotifier.clearHistory(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Quick Actions Horizontal Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  _QuickChip(
                    icon: Icons.bolt_rounded,
                    label: 'Summarize Page',
                    enabled: hasPage && !aiState.isTyping,
                    onTap: () async {
                      final article = await ReaderExtractor.extractFromWebView(
                        browserNotifier.webViewController,
                      );
                      await aiNotifier.summarizeCurrentPage(
                        title: browserState.title,
                        textContent: article?.textContent ?? browserState.title,
                      );
                      _scrollToBottom();
                    },
                  ),
                  const SizedBox(width: 8),
                  _QuickChip(
                    icon: Icons.translate_rounded,
                    label: 'অসমীয়া (Assamese)',
                    enabled: !aiState.isTyping,
                    onTap: () async {
                      final article = await ReaderExtractor.extractFromWebView(
                        browserNotifier.webViewController,
                      );
                      await aiNotifier.explainInLanguage(
                        languageCode: 'as',
                        title: browserState.title,
                        textContent: article?.textContent ?? browserState.title,
                      );
                      _scrollToBottom();
                    },
                  ),
                  const SizedBox(width: 8),
                  _QuickChip(
                    icon: Icons.translate_rounded,
                    label: 'हिंदी (Hindi)',
                    enabled: !aiState.isTyping,
                    onTap: () async {
                      final article = await ReaderExtractor.extractFromWebView(
                        browserNotifier.webViewController,
                      );
                      await aiNotifier.explainInLanguage(
                        languageCode: 'hi',
                        title: browserState.title,
                        textContent: article?.textContent ?? browserState.title,
                      );
                      _scrollToBottom();
                    },
                  ),
                  const SizedBox(width: 8),
                  _QuickChip(
                    icon: Icons.translate_rounded,
                    label: 'বাংলা (Bengali)',
                    enabled: !aiState.isTyping,
                    onTap: () async {
                      final article = await ReaderExtractor.extractFromWebView(
                        browserNotifier.webViewController,
                      );
                      await aiNotifier.explainInLanguage(
                        languageCode: 'bn',
                        title: browserState.title,
                        textContent: article?.textContent ?? browserState.title,
                      );
                      _scrollToBottom();
                    },
                  ),
                ],
              ),
            ),

            // Message Thread
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: aiState.messages.length + (aiState.isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == aiState.messages.length && aiState.isTyping) {
                    return _TypingIndicator(theme: theme);
                  }
                  final msg = aiState.messages[index];
                  return _MessageBubble(message: msg, theme: theme);
                },
              ),
            ),

            // Input Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.4,
                    ),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      decoration: InputDecoration(
                        hintText: 'Ask Axom AI anything...',
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onSubmitted: (val) =>
                          _send(aiNotifier, browserState, langCode),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    onPressed: () => _send(aiNotifier, browserState, langCode),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _send(
    AiAssistantController aiNotifier,
    BrowserState browserState,
    String langCode,
  ) {
    final query = _queryController.text.trim();
    if (query.isEmpty) return;

    _queryController.clear();
    aiNotifier.askCustomQuery(
      query: query,
      pageTitle: browserState.title,
      languageCode: langCode,
    );
    _scrollToBottom();
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      avatar: Icon(
        icon,
        size: 16,
        color: enabled ? theme.colorScheme.primary : theme.colorScheme.outline,
      ),
      label: Text(label),
      onPressed: enabled ? onTap : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final AiMessage message;
  final ThemeData theme;

  const _MessageBubble({required this.message, required this.theme});

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        decoration: BoxDecoration(
          color: isUser
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: SelectableText(
          message.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isUser
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  final ThemeData theme;

  const _TypingIndicator({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Axom AI is thinking...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
