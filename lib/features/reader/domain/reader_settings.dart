import 'dart:convert';
import 'package:flutter/material.dart';

/// Preset color themes for Reader Mode.
enum ReaderTheme { light, sepia, dark, black }

extension ReaderThemeExtension on ReaderTheme {
  Color get backgroundColor {
    switch (this) {
      case ReaderTheme.light:
        return const Color(0xFFFBFBFA);
      case ReaderTheme.sepia:
        return const Color(0xFFF4ECD8);
      case ReaderTheme.dark:
        return const Color(0xFF202124);
      case ReaderTheme.black:
        return const Color(0xFF000000);
    }
  }

  Color get textColor {
    switch (this) {
      case ReaderTheme.light:
        return const Color(0xFF1F1F1F);
      case ReaderTheme.sepia:
        return const Color(0xFF433422);
      case ReaderTheme.dark:
        return const Color(0xFFE8EAED);
      case ReaderTheme.black:
        return const Color(0xFFDCDCDC);
    }
  }

  String get displayName {
    switch (this) {
      case ReaderTheme.light:
        return 'Light';
      case ReaderTheme.sepia:
        return 'Sepia';
      case ReaderTheme.dark:
        return 'Dark';
      case ReaderTheme.black:
        return 'OLED Black';
    }
  }
}

/// Font style choices for reading.
enum ReaderFontFamily { sansSerif, serif, monospace }

extension ReaderFontFamilyExtension on ReaderFontFamily {
  String get displayName {
    switch (this) {
      case ReaderFontFamily.sansSerif:
        return 'Sans-Serif';
      case ReaderFontFamily.serif:
        return 'Serif';
      case ReaderFontFamily.monospace:
        return 'Monospace';
    }
  }
}

/// Configuration settings for the reader view.
class ReaderSettings {
  final ReaderTheme theme;
  final ReaderFontFamily fontFamily;
  final double fontSize;
  final double lineHeight;

  const ReaderSettings({
    this.theme = ReaderTheme.sepia,
    this.fontFamily = ReaderFontFamily.serif,
    this.fontSize = 18.0,
    this.lineHeight = 1.6,
  });

  ReaderSettings copyWith({
    ReaderTheme? theme,
    ReaderFontFamily? fontFamily,
    double? fontSize,
    double? lineHeight,
  }) {
    return ReaderSettings(
      theme: theme ?? this.theme,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme': theme.name,
      'fontFamily': fontFamily.name,
      'fontSize': fontSize,
      'lineHeight': lineHeight,
    };
  }

  factory ReaderSettings.fromMap(Map<String, dynamic> map) {
    return ReaderSettings(
      theme: ReaderTheme.values.firstWhere(
        (t) => t.name == map['theme'],
        orElse: () => ReaderTheme.sepia,
      ),
      fontFamily: ReaderFontFamily.values.firstWhere(
        (f) => f.name == map['fontFamily'],
        orElse: () => ReaderFontFamily.serif,
      ),
      fontSize: (map['fontSize'] as num?)?.toDouble() ?? 18.0,
      lineHeight: (map['lineHeight'] as num?)?.toDouble() ?? 1.6,
    );
  }

  String toJson() => json.encode(toMap());

  factory ReaderSettings.fromJson(String source) =>
      ReaderSettings.fromMap(json.decode(source) as Map<String, dynamic>);
}
