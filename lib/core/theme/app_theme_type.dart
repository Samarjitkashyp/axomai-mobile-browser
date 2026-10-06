import 'package:flutter/material.dart';

/// The 5 unique Assam-inspired theme presets for Axomai Browser.
enum AppThemeType {
  teaGarden,
  kazirangaMist,
  brahmaputraAzure,
  gamosaCrimson,
  obsidianDarkGlass,
}

/// Extension helper providing theme metadata, color palettes, and labels.
extension AppThemeTypeExtension on AppThemeType {
  String get nameId {
    switch (this) {
      case AppThemeType.teaGarden:
        return 'teaGarden';
      case AppThemeType.kazirangaMist:
        return 'kazirangaMist';
      case AppThemeType.brahmaputraAzure:
        return 'brahmaputraAzure';
      case AppThemeType.gamosaCrimson:
        return 'gamosaCrimson';
      case AppThemeType.obsidianDarkGlass:
        return 'obsidianDarkGlass';
    }
  }

  String get displayName {
    switch (this) {
      case AppThemeType.teaGarden:
        return 'Tea Garden';
      case AppThemeType.kazirangaMist:
        return 'Kaziranga Mist';
      case AppThemeType.brahmaputraAzure:
        return 'Brahmaputra Azure';
      case AppThemeType.gamosaCrimson:
        return 'Gamosa Crimson';
      case AppThemeType.obsidianDarkGlass:
        return 'Obsidian Dark Glass';
    }
  }

  Color get primaryColor {
    switch (this) {
      case AppThemeType.teaGarden:
        return const Color(0xFF059669); // Emerald 600 - Lush Assam tea garden
      case AppThemeType.kazirangaMist:
        return const Color(0xFF15803D); // Forest green - Kaziranga mist
      case AppThemeType.brahmaputraAzure:
        return const Color(0xFF0284C7); // Sky azure - Brahmaputra river
      case AppThemeType.gamosaCrimson:
        return const Color(0xFFDC2626); // Crimson red - Traditional Gamosa
      case AppThemeType.obsidianDarkGlass:
        return const Color(0xFF10B981); // Emerald accent on dark glass
    }
  }

  Color get secondaryColor {
    switch (this) {
      case AppThemeType.teaGarden:
        return const Color(0xFF10B981); // Emerald 500
      case AppThemeType.kazirangaMist:
        return const Color(0xFF16A34A); // Green 600
      case AppThemeType.brahmaputraAzure:
        return const Color(0xFF06B6D4); // Cyan 500
      case AppThemeType.gamosaCrimson:
        return const Color(0xFFEF4444); // Red 500
      case AppThemeType.obsidianDarkGlass:
        return const Color(0xFF059669); // Emerald 600
    }
  }

  Color get tertiaryColor {
    switch (this) {
      case AppThemeType.teaGarden:
        return const Color(0xFFF59E0B); // Amber 500
      case AppThemeType.kazirangaMist:
        return const Color(0xFFD97706); // Amber 600
      case AppThemeType.brahmaputraAzure:
        return const Color(0xFF38BDF8); // Sky 400
      case AppThemeType.gamosaCrimson:
        return const Color(0xFFFB923C); // Orange 400
      case AppThemeType.obsidianDarkGlass:
        return const Color(0xFFF59E0B); // Amber 500
    }
  }
}
