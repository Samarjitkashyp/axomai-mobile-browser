import 'package:axomai_browser_mobile/features/ai_assistant/domain/search_suggestion.dart';

/// Service delivering instant offline search recommendations and Assam domain shortcuts.
class SearchSuggestionsService {
  static const List<SearchSuggestion> _catalog = [
    // Assam History & Heritage
    SearchSuggestion(
      query: 'Lachit Borphukan Battle of Saraighat',
      category: SuggestionCategory.assamHistory,
      subtitle: 'Great Ahom general & Brahmaputra naval battle',
    ),
    SearchSuggestion(
      query: 'Ahom Dynasty and Rong Ghar',
      category: SuggestionCategory.assamHistory,
      subtitle: 'Six centuries of Assam historical reign in Sivasagar',
    ),
    SearchSuggestion(
      query: 'Chilarai Koch Dynasty History',
      category: SuggestionCategory.assamHistory,
      subtitle: 'Legendary general of the Koch kingdom',
    ),
    SearchSuggestion(
      query: 'Brahmaputra Heritage Centre Guwahati',
      category: SuggestionCategory.assamHistory,
      subtitle: 'Old DC Bungalow Panbazar riverfront museum',
    ),

    // Culture & Festivals
    SearchSuggestion(
      query: 'Bohag Bihu Rongali Traditions',
      category: SuggestionCategory.culture,
      subtitle: 'Assamese New Year festival, Husori and Bihu dance',
    ),
    SearchSuggestion(
      query: 'Assam Muga and Eri Silk Sualkuchi',
      category: SuggestionCategory.culture,
      subtitle: 'World famous golden silk weaving cluster',
    ),
    SearchSuggestion(
      query: 'Bhogali Magh Bihu Meji Bonfire',
      category: SuggestionCategory.culture,
      subtitle: 'Harvest festival of feasts and community',
    ),
    SearchSuggestion(
      query: 'Sattriya Classical Dance Majuli',
      category: SuggestionCategory.culture,
      subtitle: 'Classical Indian dance established by Srimanta Sankardev',
    ),

    // Government & Services
    SearchSuggestion(
      query: 'Assam Government Portal',
      category: SuggestionCategory.government,
      subtitle: 'Official government citizen services',
      directUrl: 'https://assam.gov.in',
    ),
    SearchSuggestion(
      query: 'Gauhati University Examination Results',
      category: SuggestionCategory.government,
      subtitle: 'Academic results and admission portal',
      directUrl: 'https://gauhati.ac.in',
    ),
    SearchSuggestion(
      query: 'Assam Secretariat Dispur',
      category: SuggestionCategory.government,
      subtitle: 'Administrative headquarters of Assam',
    ),
    SearchSuggestion(
      query: 'SEBA / AHSEC Assam Board',
      category: SuggestionCategory.government,
      subtitle: 'Secondary & higher secondary education',
    ),

    // Travel & Wildlife
    SearchSuggestion(
      query: 'Kaziranga National Park Safari Booking',
      category: SuggestionCategory.travel,
      subtitle: 'UNESCO World Heritage home of One-horned Rhinos',
    ),
    SearchSuggestion(
      query: 'Majuli River Island Satras',
      category: SuggestionCategory.travel,
      subtitle: 'Largest freshwater river island on Brahmaputra',
    ),
    SearchSuggestion(
      query: 'Kamakhya Temple Guwahati Timings',
      category: SuggestionCategory.travel,
      subtitle: 'Historic Nilachal hills pilgrimage shrine',
    ),
    SearchSuggestion(
      query: 'Manas National Park Tiger Reserve',
      category: SuggestionCategory.travel,
      subtitle: 'Biosphere reserve in the Himalayan foothills',
    ),

    // Web & Portals
    SearchSuggestion(
      query: 'Assam Tribune Newspaper',
      category: SuggestionCategory.web,
      subtitle: 'Leading English daily of Northeast India',
      directUrl: 'https://assamtribune.com',
    ),
    SearchSuggestion(
      query: 'Pratidin Time Live',
      category: SuggestionCategory.web,
      subtitle: '24x7 Assamese news portal and TV',
      directUrl: 'https://www.pratidintime.com',
    ),
    SearchSuggestion(
      query: 'Axom AI Browser Project',
      category: SuggestionCategory.web,
      subtitle: 'AI-powered, Assam-first browser',
      directUrl: 'https://aiaxom.in',
    ),
  ];

  /// Filters suggestions matching the typed query prefix.
  List<SearchSuggestion> getSuggestions(String input, {int limit = 6}) {
    final query = input.trim().toLowerCase();
    if (query.isEmpty) return const [];

    final matches = _catalog
        .where((item) {
          final q = item.query.toLowerCase();
          final s = item.subtitle?.toLowerCase() ?? '';
          return q.contains(query) || s.contains(query);
        })
        .take(limit)
        .toList();

    return matches;
  }
}
