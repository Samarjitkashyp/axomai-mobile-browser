import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/data/search_suggestions_service.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/domain/search_suggestion.dart';

final searchSuggestionsServiceProvider = Provider<SearchSuggestionsService>((
  ref,
) {
  return SearchSuggestionsService();
});

final searchSuggestionsProvider =
    Provider.family<List<SearchSuggestion>, String>((ref, query) {
      if (query.trim().isEmpty) return const [];
      final service = ref.watch(searchSuggestionsServiceProvider);
      return service.getSuggestions(query);
    });
