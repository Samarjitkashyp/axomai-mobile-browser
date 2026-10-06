import 'dart:convert';

/// Sender role of an AI Assistant message.
enum MessageSender { user, assistant, system }

/// Action type representing user intent.
enum AiActionType { general, summarize, explain, translate, search }

/// Message model for the Axom AI Assistant conversation.
class AiMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final AiActionType actionType;
  final List<String>? keyPoints;

  const AiMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.actionType = AiActionType.general,
    this.keyPoints,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'sender': sender.name,
      'timestamp': timestamp.toIso8601String(),
      'actionType': actionType.name,
      'keyPoints': keyPoints,
    };
  }

  factory AiMessage.fromMap(Map<String, dynamic> map) {
    return AiMessage(
      id: map['id'] as String,
      text: map['text'] as String,
      sender: MessageSender.values.firstWhere(
        (s) => s.name == map['sender'],
        orElse: () => MessageSender.assistant,
      ),
      timestamp: DateTime.parse(
        map['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      ),
      actionType: AiActionType.values.firstWhere(
        (a) => a.name == map['actionType'],
        orElse: () => AiActionType.general,
      ),
      keyPoints: (map['keyPoints'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  String toJson() => json.encode(toMap());

  factory AiMessage.fromJson(String source) =>
      AiMessage.fromMap(json.decode(source) as Map<String, dynamic>);
}
