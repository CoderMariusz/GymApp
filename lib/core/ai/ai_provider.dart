import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'ai_service.dart';

part 'ai_provider.g.dart';

@riverpod
AIService aiService(AiServiceRef ref) {
  return AIService();
}
