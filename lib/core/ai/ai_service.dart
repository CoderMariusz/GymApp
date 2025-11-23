import 'models/ai_request.dart';
import 'models/ai_response.dart';
import 'providers/ai_provider_interface.dart';
import 'providers/openai_provider.dart';
import 'ai_config.dart';

class AIService {
  final AIProviderInterface _provider;

  AIService() : _provider = OpenAIProvider();

  /// Generate a completion (non-streaming)
  Future<AIResponse> generateCompletion({
    required String systemPrompt,
    required String userPrompt,
    Map<String, dynamic>? context,
  }) async {
    final request = AIRequest(
      systemPrompt: systemPrompt,
      userPrompt: _buildContextualPrompt(userPrompt, context),
      stream: false,
    );

    return await _provider.complete(request);
  }

  /// Generate a completion with streaming (word-by-word)
  Stream<String> streamCompletion({
    required String systemPrompt,
    required String userPrompt,
    Map<String, dynamic>? context,
  }) {
    final request = AIRequest(
      systemPrompt: systemPrompt,
      userPrompt: _buildContextualPrompt(userPrompt, context),
      stream: true,
    );

    return _provider.streamCompletion(request);
  }

  /// Validate API configuration
  Future<bool> validateConfiguration() async {
    if (!AIConfig.isConfigured) return false;
    return await _provider.validateApiKey();
  }

  String _buildContextualPrompt(String prompt, Map<String, dynamic>? context) {
    if (context == null || context.isEmpty) return prompt;

    final contextStr = context.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');

    return '$prompt\n\nContext:\n$contextStr';
  }
}
