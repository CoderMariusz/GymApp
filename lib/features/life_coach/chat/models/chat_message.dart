import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum MessageRole { user, assistant, system }

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required MessageRole role,
    required String content,
    required DateTime timestamp,
    Map<String, dynamic>? metadata,  // AI model info, tokens, etc.
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
class ChatSession with _$ChatSession {
  const factory ChatSession({
    required String id,
    required String userId,
    required String title,
    required List<ChatMessage> messages,
    required DateTime createdAt,
    DateTime? lastMessageAt,
    @Default(false) bool isArchived,
  }) = _ChatSession;

  factory ChatSession.fromJson(Map<String, dynamic> json) =>
      _$ChatSessionFromJson(json);
}
