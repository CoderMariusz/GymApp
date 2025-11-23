import 'package:uuid/uuid.dart';
import '../../../core/ai/ai_service.dart';
import '../domain/repositories/goals_repository.dart';
import '../domain/repositories/check_in_repository.dart';
import 'models/chat_message.dart';
import 'data/repositories/chat_repository.dart';

class ConversationalCoach {
  final AIService _aiService;
  final GoalsRepository _goalsRepo;
  final CheckInRepository _checkInRepo;
  final ChatRepository _chatRepo;

  ConversationalCoach({
    required AIService aiService,
    required GoalsRepository goalsRepo,
    required CheckInRepository checkInRepo,
    required ChatRepository chatRepo,
  })  : _aiService = aiService,
        _goalsRepo = goalsRepo,
        _checkInRepo = checkInRepo,
        _chatRepo = chatRepo;

  /// Send a message and get AI response
  Future<ChatMessage> sendMessage({
    required String sessionId,
    required String userMessage,
  }) async {
    try {
      // 1. Create user message
      final userMsg = ChatMessage(
        id: const Uuid().v4(),
        role: MessageRole.user,
        content: userMessage,
        timestamp: DateTime.now(),
      );

      // Save user message
      await _chatRepo.addMessage(sessionId, userMsg);

      // 2. Get conversation context
      final session = await _chatRepo.getSession(sessionId);
      final conversationHistory = session?.messages ?? [];

      // 3. Build context-aware prompt
      final systemPrompt = await _buildSystemPrompt();
      final contextualPrompt = _buildContextualPrompt(
        conversationHistory,
        userMessage,
      );

      // 4. Get AI response
      final aiResponse = await _aiService.generateCompletion(
        systemPrompt: systemPrompt,
        userPrompt: contextualPrompt,
      );

      // 5. Create assistant message
      final assistantMsg = ChatMessage(
        id: const Uuid().v4(),
        role: MessageRole.assistant,
        content: aiResponse.content,
        timestamp: DateTime.now(),
        metadata: {
          'tokens_used': aiResponse.tokensUsed,
          'cost': aiResponse.estimatedCost,
          'model': aiResponse.model,
        },
      );

      // Save assistant message
      await _chatRepo.addMessage(sessionId, assistantMsg);

      return assistantMsg;
    } catch (e) {
      throw Exception('Failed to get AI response: ${e.toString()}');
    }
  }

  /// Send a message with streaming response
  Stream<String> sendMessageStream({
    required String sessionId,
    required String userMessage,
  }) async* {
    try {
      // 1. Create and save user message
      final userMsg = ChatMessage(
        id: const Uuid().v4(),
        role: MessageRole.user,
        content: userMessage,
        timestamp: DateTime.now(),
      );
      await _chatRepo.addMessage(sessionId, userMsg);

      // 2. Get context
      final session = await _chatRepo.getSession(sessionId);
      final conversationHistory = session?.messages ?? [];

      // 3. Build prompts
      final systemPrompt = await _buildSystemPrompt();
      final contextualPrompt = _buildContextualPrompt(
        conversationHistory,
        userMessage,
      );

      // 4. Stream AI response
      final stream = _aiService.streamCompletion(
        systemPrompt: systemPrompt,
        userPrompt: contextualPrompt,
      );

      final buffer = StringBuffer();
      await for (final chunk in stream) {
        buffer.write(chunk);
        yield chunk;
      }

      // 5. Save complete assistant message
      final assistantMsg = ChatMessage(
        id: const Uuid().v4(),
        role: MessageRole.assistant,
        content: buffer.toString(),
        timestamp: DateTime.now(),
      );
      await _chatRepo.addMessage(sessionId, assistantMsg);
    } catch (e) {
      throw Exception('Failed to stream AI response: ${e.toString()}');
    }
  }

  /// Create a new chat session
  Future<ChatSession> createSession({required String userId}) async {
    final session = ChatSession(
      id: const Uuid().v4(),
      userId: userId,
      title: 'New Conversation',
      messages: [],
      createdAt: DateTime.now(),
    );

    await _chatRepo.saveSession(session);
    return session;
  }

  Future<String> _buildSystemPrompt() async {
    // Get user context
    final goals = await _goalsRepo.getActiveGoals();
    final checkIn = await _checkInRepo.getCheckInForDate(DateTime.now());

    final goalsContext = goals.isEmpty
        ? ''
        : '\nUser\'s active goals:\n${goals.map((g) => '- ${g.title} (${g.category.name})').join('\n')}';

    final moodContext = checkIn != null
        ? '\nToday\'s check-in:\n- Mood: ${checkIn.mood}/10\n- Energy: ${checkIn.energy}/10\n- Sleep: ${checkIn.sleepQuality}/10'
        : '';

    return '''
You are a supportive, empathetic life coach AI for the LifeOS app.

Your role:
- Help users achieve their goals through thoughtful conversations
- Provide actionable advice and motivation
- Ask clarifying questions to understand their needs
- Be supportive but honest
- Focus on sustainable habits and realistic progress

Guidelines:
1. Be warm and encouraging, but not overly enthusiastic
2. Ask follow-up questions to understand context
3. Provide specific, actionable suggestions
4. Reference user's goals and current state when relevant
5. Keep responses concise (2-4 sentences typical, longer when needed)
6. Use active listening techniques (acknowledge feelings, paraphrase)
7. Never diagnose mental health conditions - suggest professional help if needed

User Context:$goalsContext$moodContext

Remember: You're a coach, not a therapist. Focus on goals, habits, and practical support.
''';
  }

  String _buildContextualPrompt(
    List<ChatMessage> history,
    String newMessage,
  ) {
    if (history.isEmpty) {
      return newMessage;
    }

    // Include last 5 messages for context
    final recentHistory = history.length > 5
        ? history.sublist(history.length - 5)
        : history;

    final contextStr = recentHistory
        .map((msg) => '${msg.role.name}: ${msg.content}')
        .join('\n\n');

    return '''
Conversation history:
$contextStr

User: $newMessage

Respond as the AI coach (be conversational, not formal):
''';
  }
}
