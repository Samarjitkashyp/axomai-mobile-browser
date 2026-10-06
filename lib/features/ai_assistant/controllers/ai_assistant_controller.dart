import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/data/ai_engine_service.dart';
import 'package:axomai_browser_mobile/features/ai_assistant/domain/ai_message.dart';

class AiAssistantState {
  final List<AiMessage> messages;
  final bool isTyping;
  final List<String>? currentKeyPoints;

  const AiAssistantState({
    this.messages = const [],
    this.isTyping = false,
    this.currentKeyPoints,
  });

  AiAssistantState copyWith({
    List<AiMessage>? messages,
    bool? isTyping,
    List<String>? currentKeyPoints,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      currentKeyPoints: currentKeyPoints ?? this.currentKeyPoints,
    );
  }
}

final aiEngineServiceProvider = Provider<AiEngineService>((ref) {
  return AiEngineService();
});

final aiAssistantControllerProvider =
    StateNotifierProvider<AiAssistantController, AiAssistantState>((ref) {
      final engine = ref.watch(aiEngineServiceProvider);
      return AiAssistantController(engine);
    });

class AiAssistantController extends StateNotifier<AiAssistantState> {
  final AiEngineService _engine;

  AiAssistantController(this._engine) : super(const AiAssistantState()) {
    _initGreeting();
  }

  void _initGreeting() {
    final welcomeMsg = AiMessage(
      id: 'msg_welcome',
      text:
          'Hello! I am your Axom AI Assistant. I can summarize this page, extract key facts, or explain concepts in your preferred language.',
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
      actionType: AiActionType.general,
    );
    state = state.copyWith(messages: [welcomeMsg]);
  }

  Future<void> summarizeCurrentPage({
    required String title,
    required String textContent,
  }) async {
    final userMsg = AiMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_user',
      text: 'Summarize this page: $title',
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      actionType: AiActionType.summarize,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    // Simulate quick intelligent thought processing
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final points = _engine.summarizeText(textContent);
    final summaryText =
        'Here is the key summary for "$title":\n\n• ${points.join('\n• ')}';

    final aiMsg = AiMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
      text: summaryText,
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
      actionType: AiActionType.summarize,
      keyPoints: points,
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isTyping: false,
      currentKeyPoints: points,
    );
  }

  Future<void> explainInLanguage({
    required String languageCode,
    required String title,
    required String textContent,
  }) async {
    final userMsg = AiMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_user',
      text: 'Explain this page in ${_getLanguageName(languageCode)}',
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      actionType: AiActionType.explain,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 400));

    final explanation = _engine.explainConcept(
      title,
      languageCode,
      pageContext: textContent,
    );

    final aiMsg = AiMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
      text: explanation,
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
      actionType: AiActionType.explain,
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isTyping: false,
    );
  }

  Future<void> askCustomQuery({
    required String query,
    String? pageTitle,
    String? pageText,
    String languageCode = 'en',
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) return;

    final userMsg = AiMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_user',
      text: cleanQuery,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      actionType: AiActionType.general,
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isTyping: true,
    );

    await Future<void>.delayed(const Duration(milliseconds: 300));

    final response = _engine.answerQuery(
      cleanQuery,
      pageTitle: pageTitle,
      pageText: pageText,
      languageCode: languageCode,
    );

    final aiMsg = AiMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}_ai',
      text: response,
      sender: MessageSender.assistant,
      timestamp: DateTime.now(),
      actionType: AiActionType.general,
    );

    state = state.copyWith(
      messages: [...state.messages, aiMsg],
      isTyping: false,
    );
  }

  void clearHistory() {
    _initGreeting();
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'as':
        return 'Assamese (অসমীয়া)';
      case 'hi':
        return 'Hindi (हिंदी)';
      case 'bn':
        return 'Bengali (বাংলা)';
      default:
        return 'English';
    }
  }
}
