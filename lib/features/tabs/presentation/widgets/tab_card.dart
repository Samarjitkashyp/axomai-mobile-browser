import 'package:flutter/material.dart';
import 'package:axomai_browser_mobile/features/tabs/domain/browser_tab.dart';

/// Card widget visualizing an individual tab in the Tab Switcher grid.
class TabCard extends StatelessWidget {
  final BrowserTab tab;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onClose;

  const TabCard({
    super.key,
    required this.tab,
    required this.isSelected,
    required this.onTap,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isIncognito = tab.isIncognito;

    final cardBg = isIncognito
        ? const Color(0xFF1F1F28)
        : theme.colorScheme.surfaceContainer;

    final border = isSelected
        ? Border.all(
            color: isIncognito
                ? const Color(0xFF9D65FF)
                : theme.colorScheme.primary,
            width: 2.5,
          )
        : Border.all(
            color: theme.colorScheme.outlineVariant.withAlpha(80),
            width: 1,
          );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: border,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color:
                        (isIncognito
                                ? const Color(0xFF9D65FF)
                                : theme.colorScheme.primary)
                            .withAlpha(50),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Tab Card Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isIncognito
                    ? const Color(0xFF14141B)
                    : theme.colorScheme.surfaceContainerHighest.withAlpha(150),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Row(
                children: <Widget>[
                  Icon(
                    isIncognito
                        ? Icons.visibility_off_outlined
                        : (tab.url.startsWith('https://')
                              ? Icons.lock_outline
                              : Icons.public),
                    size: 14,
                    color: isIncognito
                        ? Colors.purpleAccent
                        : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      tab.title.isNotEmpty ? tab.title : 'New Tab',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isIncognito ? Colors.white : null,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: isIncognito
                            ? Colors.white70
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tab Card Body Preview
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      isIncognito ? Icons.vpn_lock : Icons.language,
                      size: 36,
                      color: isIncognito
                          ? Colors.purpleAccent.withAlpha(150)
                          : theme.colorScheme.primary.withAlpha(120),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tab.url.isNotEmpty ? tab.url : 'New Tab',
                      style: TextStyle(
                        fontSize: 10,
                        color: isIncognito
                            ? Colors.white60
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
