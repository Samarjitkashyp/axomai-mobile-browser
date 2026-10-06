import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/browser/controllers/browser_controller.dart';
import 'package:axomai_browser_mobile/l10n/app_localizations.dart';

/// Top Address / Omnibox bar supporting search or direct URL navigation.
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

  void _showSecurityDialog(BuildContext context, bool isSecure, String url) {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(
          isSecure ? Icons.lock : Icons.lock_open,
          color: isSecure ? theme.colorScheme.primary : theme.colorScheme.error,
          size: 32,
        ),
        title: Text(
          isSecure ? 'Connection is Secure' : 'Connection is Not Secure',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSecure
                  ? 'Your information (passwords, cookies, messages) is private when sent to this site.'
                  : 'You should not enter any sensitive information on this site because it could be intercepted.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            SelectableText(
              url,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final browserState = ref.watch(browserControllerProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    if (!_isEditing && _textController.text != browserState.url) {
      _textController.text = browserState.url;
    }

    final isHttps = browserState.isSecure && browserState.url.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: theme.colorScheme.surface,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isEditing
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant.withAlpha(80),
            width: 1.2,
          ),
        ),
        child: Row(
          children: <Widget>[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: browserState.url.isNotEmpty
                  ? () => _showSecurityDialog(
                      context,
                      browserState.isSecure,
                      browserState.url,
                    )
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Icon(
                  isHttps
                      ? Icons.lock
                      : (browserState.url.isEmpty
                            ? Icons.search
                            : Icons.lock_open),
                  size: 18,
                  color: isHttps
                      ? theme.colorScheme.primary
                      : (browserState.url.isEmpty
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.error),
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                textInputAction: TextInputAction.go,
                keyboardType: TextInputType.url,
                autocorrect: false,
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                decoration: InputDecoration(
                  hintText: l10n?.selectLanguage != null
                      ? 'Search or enter address'
                      : 'Search or enter URL',
                  hintStyle: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant.withAlpha(150),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                onSubmitted: _submit,
              ),
            ),
            if (_isEditing && _textController.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () {
                  _textController.clear();
                  setState(() {});
                },
              )
            else if (browserState.isLoading)
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                tooltip: 'Stop',
                onPressed: () =>
                    ref.read(browserControllerProvider.notifier).stopLoading(),
              )
            else
              IconButton(
                icon: const Icon(Icons.refresh, size: 20),
                tooltip: 'Reload',
                onPressed: () =>
                    ref.read(browserControllerProvider.notifier).reload(),
              ),
          ],
        ),
      ),
    );
  }
}
