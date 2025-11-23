import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../../core/database/database.dart';
import '../../models/chat_message.dart';

class ChatRepository {
  final AppDatabase _db;

  ChatRepository(this._db);

  Future<void> saveSession(ChatSession session) async {
    await _db.into(_db.chatSessions).insert(
          ChatSessionsCompanion.insert(
            id: session.id,
            userId: session.userId,
            title: session.title,
            messagesJson: jsonEncode(session.messages.map((m) => m.toJson()).toList()),
            createdAt: Value(session.createdAt),
            lastMessageAt: Value(session.lastMessageAt),
            isArchived: Value(session.isArchived),
          ),
          mode: InsertMode.replace,
        );
  }

  Future<ChatSession?> getSession(String sessionId) async {
    final query = _db.select(_db.chatSessions)
      ..where((s) => s.id.equals(sessionId));

    final result = await query.getSingleOrNull();
    return result != null ? _fromDto(result) : null;
  }

  Future<List<ChatSession>> getUserSessions(String userId, {bool includeArchived = false}) async {
    final query = _db.select(_db.chatSessions)
      ..where((s) => s.userId.equals(userId))
      ..orderBy([(s) => OrderingTerm.desc(s.lastMessageAt ?? s.createdAt)]);

    if (!includeArchived) {
      query.where((s) => s.isArchived.equals(false));
    }

    final results = await query.get();
    return results.map((dto) => _fromDto(dto)).toList();
  }

  Future<void> addMessage(String sessionId, ChatMessage message) async {
    final session = await getSession(sessionId);
    if (session == null) return;

    final updatedMessages = [...session.messages, message];
    final updatedSession = session.copyWith(
      messages: updatedMessages,
      lastMessageAt: message.timestamp,
    );

    await saveSession(updatedSession);
  }

  Future<void> archiveSession(String sessionId) async {
    await (_db.update(_db.chatSessions)
          ..where((s) => s.id.equals(sessionId)))
        .write(const ChatSessionsCompanion(isArchived: Value(true)));
  }

  Future<void> deleteSession(String sessionId) async {
    await (_db.delete(_db.chatSessions)
          ..where((s) => s.id.equals(sessionId)))
        .go();
  }

  ChatSession _fromDto(ChatSessionData data) {
    return ChatSession(
      id: data.id,
      userId: data.userId,
      title: data.title,
      messages: (jsonDecode(data.messagesJson) as List)
          .map((json) => ChatMessage.fromJson(json))
          .toList(),
      createdAt: data.createdAt,
      lastMessageAt: data.lastMessageAt,
      isArchived: data.isArchived,
    );
  }
}
