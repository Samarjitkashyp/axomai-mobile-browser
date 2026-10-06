import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/reader/controllers/reader_controller.dart';
import 'package:axomai_browser_mobile/features/reader/domain/reader_settings.dart';

/// Modal bottom sheet for customizing Reader typography and theme.
class ReaderSettingsSheet extends ConsumerWidget {
  const ReaderSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final readerState = ref.watch(readerControllerProvider);
    final readerNotifier = ref.read(readerControllerProvider.notifier);
    final settings = readerState.settings;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              'Reader Appearance',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Theme selector chips
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ReaderTheme.values.map((rTheme) {
                final isSelected = settings.theme == rTheme;
                return GestureDetector(
                  onTap: () => readerNotifier.setTheme(rTheme),
                  child: Container(
                    width: 60,
                    height: 52,
                    decoration: BoxDecoration(
                      color: rTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        width: isSelected ? 2.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Aa',
                        style: TextStyle(
                          color: rTheme.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Font Family Selector
            SegmentedButton<ReaderFontFamily>(
              segments: ReaderFontFamily.values.map((fam) {
                return ButtonSegment<ReaderFontFamily>(
                  value: fam,
                  label: Text(fam.displayName),
                );
              }).toList(),
              selected: {settings.fontFamily},
              onSelectionChanged: (set) =>
                  readerNotifier.setFontFamily(set.first),
            ),
            const SizedBox(height: 20),

            // Font Size Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Font Size',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Row(
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.remove_rounded, size: 20),
                      onPressed: () => readerNotifier.decreaseFontSize(),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${settings.fontSize.toInt()} pt',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.add_rounded, size: 20),
                      onPressed: () => readerNotifier.increaseFontSize(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
