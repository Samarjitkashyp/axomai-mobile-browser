import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:axomai_browser_mobile/core/theme/app_theme_type.dart';

/// Dynamic theme builder supporting 5 themes, dark mode, and locale fonts.
abstract final class AppTheme {
  static TextTheme _buildTextTheme(Locale? locale, TextTheme baseTextTheme) {
    final languageCode = locale?.languageCode ?? 'en';
    if (languageCode == 'as' || languageCode == 'bn') {
      return GoogleFonts.notoSansBengaliTextTheme(baseTextTheme);
    }
    if (languageCode == 'hi') {
      return GoogleFonts.notoSansDevanagariTextTheme(baseTextTheme);
    }
    return GoogleFonts.plusJakartaSansTextTheme(baseTextTheme);
  }

  static ThemeData buildTheme({
    required AppThemeType themeType,
    required Brightness brightness,
    Locale? locale,
  }) {
    final isDark = brightness == Brightness.dark;

    // Direct background & surface tokens from axomai-browser.aiaxom.co.in
    final scaffoldBg = isDark
        ? const Color(0xFF0B1220) // Dark obsidian
        : const Color(0xFFF0FDF4); // Light fresh mint
    final surfaceColor = isDark
        ? const Color(0xFF111C2E) // Dark slate surface
        : Colors.white;
    final surfaceHighest = isDark
        ? const Color(0xFF1F2F46) // Line / border dark
        : const Color(0xFFE2F5EA); // Line / pill light
    final surfaceLowest = isDark
        ? const Color(0xFF080D17)
        : const Color(0xFFFFFFFF);

    final colorScheme = ColorScheme.fromSeed(
      seedColor: themeType.primaryColor,
      primary: themeType.primaryColor,
      secondary: themeType.secondaryColor,
      tertiary: themeType.tertiaryColor,
      surface: surfaceColor,
      surfaceContainerHighest: surfaceHighest,
      surfaceContainerLowest: surfaceLowest,
      brightness: brightness,
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      colorScheme: colorScheme,
    );

    return baseTheme.copyWith(
      textTheme: _buildTextTheme(locale, baseTheme.textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: surfaceColor,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        color: surfaceColor,
        elevation: isDark ? 0 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark
              ? BorderSide(color: Colors.white.withAlpha(25), width: 1)
              : BorderSide.none,
        ),
      ),
    );
  }
}
