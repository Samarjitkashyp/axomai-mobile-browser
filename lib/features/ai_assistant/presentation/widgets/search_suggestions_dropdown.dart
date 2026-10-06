import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/controllers/search_suggestions_controller.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/domain/search_suggestion.dart';

/// Autocomplete dropdown overlay for smart Assam and web suggestions.
class SearchSuggestionsDropdown extends ConsumerWidget {
  final String query;
  final void Function(String queryOrUrl) onSelect;

  const SearchSuggestionsDropdown({
    super.key,
    required this.query,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final suggestions = ref.watch(searchSuggestionsProvider(query));

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Material(
      color: theme.colorScheme.surface,
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 280),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 6),
          itemCount: suggestions.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
          ),
          itemBuilder: (context, index) {
            final item = suggestions[index];
            return ListTile(
              dense: true,
              leading: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.category.icon,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),
              title: Text(
                item.query,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              subtitle: item.subtitle != null
                  ? Text(
                      item.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  : null,
              trailing: const Icon(Icons.north_west_rounded, size: 14),
              onTap: () => onSelect(item.directUrl ?? item.query),
            );
          },
        ),
      ),
    );
  }
}
