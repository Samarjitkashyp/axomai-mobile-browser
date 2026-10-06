import 'package:flutter/material.dart';

/// Categories for intelligent autocomplete recommendations.
enum SuggestionCategory { assamHistory, culture, government, travel, web }

extension SuggestionCategoryExtension on SuggestionCategory {
  String get displayName {
    switch (this) {
      case SuggestionCategory.assamHistory:
        return 'Assam History';
      case SuggestionCategory.culture:
        return 'Culture & Festivals';
      case SuggestionCategory.government:
        return 'Assam Services';
      case SuggestionCategory.travel:
        return 'Tourism & Wildlife';
      case SuggestionCategory.web:
        return 'Popular Search';
    }
  }

  IconData get icon {
    switch (this) {
      case SuggestionCategory.assamHistory:
        return Icons.history_edu_rounded;
      case SuggestionCategory.culture:
        return Icons.theater_comedy_rounded;
      case SuggestionCategory.government:
        return Icons.account_balance_rounded;
      case SuggestionCategory.travel:
        return Icons.forest_rounded;
      case SuggestionCategory.web:
        return Icons.search_rounded;
    }
  }
}

/// Autocomplete query suggestion item.
class SearchSuggestion {
  final String query;
  final SuggestionCategory category;
  final String? subtitle;
  final String? directUrl;

  const SearchSuggestion({
    required this.query,
    this.category = SuggestionCategory.web,
    this.subtitle,
    this.directUrl,
  });
}
