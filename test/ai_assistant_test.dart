import 'package:flutter_test/flutter_test.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/controllers/ai_assistant_controller.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/data/ai_engine_service.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/data/search_suggestions_service.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/domain/ai_message.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/domain/search_suggestion.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AiMessage Model Tests', () {
    test('Serializes to and from JSON', () {
      final msg = AiMessage(
        id: 'm1',
        text: 'Assam rich tea gardens produce 50% of India tea output.',
        sender: MessageSender.assistant,
        timestamp: DateTime(2026, 10, 6, 12, 0),
        actionType: AiActionType.summarize,
        keyPoints: const ['Point A', 'Point B'],
      );

      final jsonStr = msg.toJson();
      final decoded = AiMessage.fromJson(jsonStr);

      expect(decoded.id, 'm1');
      expect(decoded.sender, MessageSender.assistant);
      expect(decoded.actionType, AiActionType.summarize);
      expect(decoded.keyPoints?.length, 2);
    });
  });

  group('AiEngineService Unit Tests', () {
    late AiEngineService engine;

    setUp(() {
      engine = AiEngineService();
    });

    test(
      'Summarizes multi-sentence paragraphs into prioritized key takeaways',
      () {
        const article = '''
The Brahmaputra River is one of the major rivers of Asia, flowing through Tibet, India, and Bangladesh.
It originates in the Manasarovar Lake region near Mount Kailash.
In Assam, the river serves as the vital lifeline of civilization, trade, and agriculture across the valley.
The annual floods bring rich alluvial deposits that fertilize the tea gardens and paddy fields.
Majuli island located on the Brahmaputra is the world largest inhabited river island.
''';

        final points = engine.summarizeText(article, maxPoints: 3);
        expect(points.isNotEmpty, true);
        expect(points.length, lessThanOrEqualTo(3));
        expect(points.any((p) => p.contains('Brahmaputra')), true);
      },
    );

    test(
      'Generates localized explanations for Assamese, Hindi, and Bengali',
      () {
        final assamese = engine.explainConcept('Lachit Borphukan', 'as');
        expect(assamese, contains('অসমীয়া বিশ্লেষণ'));

        final hindi = engine.explainConcept('Kaziranga', 'hi');
        expect(hindi, contains('हिंदी विश्लेषण'));

        final bengali = engine.explainConcept('Majuli', 'bn');
        expect(bengali, contains('বাংলা বিশ্লেষণ'));

        final english = engine.explainConcept('Bihu', 'en');
        expect(english, contains('Axom AI Analysis'));
      },
    );

    test('Answers user questions using page context', () {
      final summaryAnswer = engine.answerQuery(
        'Please summarize this article',
        pageTitle: 'Assam Tea Festival',
        pageText:
            'Jorhat hosts the grand tea festival celebrating heritage tea estates and auctions.',
      );
      expect(summaryAnswer, contains('key takeaways'));
    });
  });

  group('SearchSuggestionsService Tests', () {
    late SearchSuggestionsService service;

    setUp(() {
      service = SearchSuggestionsService();
    });

    test('Finds relevant Assam suggestions on prefix or keyword match', () {
      final lachitMatches = service.getSuggestions('Lachit');
      expect(lachitMatches.isNotEmpty, true);
      expect(lachitMatches.first.query, contains('Lachit Borphukan'));
      expect(lachitMatches.first.category, SuggestionCategory.assamHistory);

      final bihuMatches = service.getSuggestions('Bihu');
      expect(bihuMatches.isNotEmpty, true);
      expect(
        bihuMatches.any((m) => m.category == SuggestionCategory.culture),
        true,
      );

      final govtMatches = service.getSuggestions('portal');
      expect(govtMatches.isNotEmpty, true);
    });
  });

  group('AiAssistantController Tests', () {
    test(
      'Initializes with greeting and executes summarization and QA flows',
      () async {
        final engine = AiEngineService();
        final controller = AiAssistantController(engine);

        expect(controller.state.messages.length, 1);
        expect(controller.state.messages.first.sender, MessageSender.assistant);

        // Summarize Page
        await controller.summarizeCurrentPage(
          title: 'Kaziranga Wildlife Heritage',
          textContent:
              'Kaziranga National Park hosts two-thirds of the world great one-horned rhinoceroses. The park has achieved notable success in wildlife conservation.',
        );

        expect(controller.state.messages.length, 3); // Greeting + User + AI
        expect(
          controller.state.messages.last.actionType,
          AiActionType.summarize,
        );
        expect(controller.state.currentKeyPoints?.isNotEmpty, true);

        // Ask Custom Query
        await controller.askCustomQuery(query: 'What is Majuli?');
        expect(controller.state.messages.length, 5);

        // Clear History
        controller.clearHistory();
        expect(controller.state.messages.length, 1);
      },
    );
  });
}
