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
    return GoogleFonts.plusJakartaSansTextTheme(baseTextTheme);
  }

  static ThemeData buildTheme({
    required AppThemeType themeType,
    required Brightness brightness,
    Locale? locale,
  }) {
    final isDark = brightness == Brightness.dark;

    // Obsidian Dark Glass has a specialized dark aesthetic
    if (themeType == AppThemeType.obsidianDarkGlass && isDark) {
      const surfaceColor = Color(0xFF13131A);
      const backgroundColor = Color(0xFF09090D);
      const primary = Color(0xFF9D65FF);

      const colorScheme = ColorScheme.dark(
        primary: primary,
        secondary: Color(0xFF00E5FF),
        surface: surfaceColor,
        error: Color(0xFFFF5252),
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: Color(0xFFEEEEF5),
      );

      final baseTheme = ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: colorScheme,
      );

      return baseTheme.copyWith(
        textTheme: _buildTextTheme(locale, baseTheme.textTheme),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: surfaceColor,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          color: surfaceColor.withAlpha(220),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.white.withAlpha(30), width: 1),
          ),
        ),
      );
    }

    final colorScheme = ColorScheme.fromSeed(
      seedColor: themeType.primaryColor,
      brightness: brightness,
    );

    final baseTheme = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
    );

    return baseTheme.copyWith(
      textTheme: _buildTextTheme(locale, baseTheme.textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
