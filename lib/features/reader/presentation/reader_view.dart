import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:axomai_browser_mobile/features/reader/controllers/reader_controller.dart';
import 'package:axomai_browser_mobile/features/reader/domain/reader_settings.dart';
import 'package:axomai_browser_mobile/features/reader/presentation/widgets/reader_settings_sheet.dart';

/// Distraction-free article reader view overlay.
class ReaderView extends ConsumerWidget {
  const ReaderView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readerState = ref.watch(readerControllerProvider);
    final readerNotifier = ref.read(readerControllerProvider.notifier);
    final article = readerState.article;
    final settings = readerState.settings;

    if (article == null) return const SizedBox.shrink();

    final bgColor = settings.theme.backgroundColor;
    final textColor = settings.theme.textColor;

    TextStyle getBaseStyle() {
      switch (settings.fontFamily) {
        case ReaderFontFamily.serif:
          return GoogleFonts.merriweather(
            color: textColor,
            fontSize: settings.fontSize,
            height: settings.lineHeight,
          );
        case ReaderFontFamily.sansSerif:
          return GoogleFonts.inter(
            color: textColor,
            fontSize: settings.fontSize,
            height: settings.lineHeight,
          );
        case ReaderFontFamily.monospace:
          return GoogleFonts.jetBrainsMono(
            color: textColor,
            fontSize: settings.fontSize,
            height: settings.lineHeight,
          );
      }
    }

    final baseStyle = getBaseStyle();

    return Container(
      color: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // Top Toolbar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: textColor.withValues(alpha: 0.1),
                    width: 0.8,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: textColor),
                    tooltip: 'Exit Reader Mode',
                    onPressed: () => readerNotifier.closeReader(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: textColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: textColor.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${article.readingTimeMinutes} min read',
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.text_format_rounded, color: textColor),
                    tooltip: 'Appearance Settings',
                    onPressed: () {
                      showModalBottomSheet<void>(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        builder: (ctx) => const ReaderSettingsSheet(),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Article Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Article Title
                    SelectableText(
                      article.title,
                      style: baseStyle.copyWith(
                        fontSize: settings.fontSize * 1.5,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),
                    if (article.byline != null &&
                        article.byline!.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      SelectableText(
                        'By ${article.byline}',
                        style: baseStyle.copyWith(
                          fontSize: settings.fontSize * 0.85,
                          color: textColor.withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Divider(color: textColor.withValues(alpha: 0.15)),
                    const SizedBox(height: 16),

                    // Clean Parsed Content
                    SelectableText(article.textContent, style: baseStyle),
                    const SizedBox(height: 64),
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
