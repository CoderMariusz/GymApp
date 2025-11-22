import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIConfig {
  // OpenAI
  static String get openAIKey => dotenv.env['OPENAI_API_KEY'] ?? '';
  static String get openAIModel => dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';
  static int get maxTokens => int.parse(dotenv.env['OPENAI_MAX_TOKENS'] ?? '2000');
  static double get temperature => double.parse(dotenv.env['OPENAI_TEMPERATURE'] ?? '0.7');

  // Anthropic (fallback)
  static String get anthropicKey => dotenv.env['ANTHROPIC_API_KEY'] ?? '';
  static String get anthropicModel => dotenv.env['ANTHROPIC_MODEL'] ?? 'claude-3-5-haiku-20241022';

  // General
  static int get timeoutSeconds => int.parse(dotenv.env['AI_TIMEOUT_SECONDS'] ?? '30');
  static int get maxRetries => int.parse(dotenv.env['AI_MAX_RETRIES'] ?? '3');

  // Validate configuration
  static bool get isConfigured => openAIKey.isNotEmpty || anthropicKey.isNotEmpty;
}
