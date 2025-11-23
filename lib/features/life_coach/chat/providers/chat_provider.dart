import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:lifeos/core/ai/ai_provider.dart';
import 'package:lifeos/core/database/database_providers.dart';
import 'package:lifeos/core/error/result.dart';
import '../../ai/providers/daily_plan_provider.dart';
import '../conversational_coach.dart';
import '../models/chat_message.dart';
import '../data/repositories/chat_repository.dart';

part 'chat_provider.g.dart';

@riverpod
ChatRepository chatRepository(Ref ref) {
  return ChatRepository(ref.watch(appDatabaseProvider));
}

@riverpod
ConversationalCoach conversationalCoach(Ref ref) {
  return ConversationalCoach(
    aiService: ref.watch(aiServiceProvider),
    goalsRepo: ref.watch(goalsRepositoryProvider),
    checkInRepo: ref.watch(checkInRepositoryProvider),
    chatRepo: ref.watch(chatRepositoryProvider),
  );
}

@riverpod
class ChatSessionNotifier extends _$ChatSessionNotifier {
  @override
  Future<ChatSession?> build({required String sessionId}) async {
    final repo = ref.watch(chatRepositoryProvider);
    return await repo.getSession(sessionId);
  }

  Future<void> sendMessage(String message) async {
    try {
      final coach = ref.read(conversationalCoachProvider);
      final result = await coach.sendMessage(
        sessionId: sessionId,
        userMessage: message,
      );

      result.map(
        success: (success) {
          // Refresh state to show new message
          ref.invalidateSelf();
        },
        failure: (failure) {
          throw failure.exception; // Propagate error to UI
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class ChatSessionsList extends _$ChatSessionsList {
  @override
  Future<List<ChatSession>> build({required String userId}) async {
    final repo = ref.watch(chatRepositoryProvider);
    return await repo.getUserSessions(userId);
  }

  Future<ChatSession> createNewSession() async {
    final coach = ref.read(conversationalCoachProvider);
    final session = await coach.createSession(userId: userId);
    ref.invalidateSelf();
    return session;
  }

  Future<void> archiveSession(String sessionId) async {
    final repo = ref.read(chatRepositoryProvider);
    await repo.archiveSession(sessionId);
    ref.invalidateSelf();
  }

  Future<void> deleteSession(String sessionId) async {
    final repo = ref.read(chatRepositoryProvider);
    await repo.deleteSession(sessionId);
    ref.invalidateSelf();
  }
}
