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
        return const Color(0xFF007A5A); // Lush Assam tea leaf green
      case AppThemeType.kazirangaMist:
        return const Color(0xFF355E3B); // Forest sage & misty green
      case AppThemeType.brahmaputraAzure:
        return const Color(0xFF0D6EFD); // Mighty Brahmaputra river azure
      case AppThemeType.gamosaCrimson:
        return const Color(0xFFD32F2F); // Traditional Gamosa woven crimson red
      case AppThemeType.obsidianDarkGlass:
        return const Color(0xFF8A58FC); // Deep electric neon purple on obsidian
    }
  }

  Color get secondaryColor {
    switch (this) {
      case AppThemeType.teaGarden:
        return const Color(0xFF2E7D32);
      case AppThemeType.kazirangaMist:
        return const Color(0xFF558B2F);
      case AppThemeType.brahmaputraAzure:
        return const Color(0xFF0288D1);
      case AppThemeType.gamosaCrimson:
        return const Color(0xFFB71C1C);
      case AppThemeType.obsidianDarkGlass:
        return const Color(0xFF00E5FF);
    }
  }
}
