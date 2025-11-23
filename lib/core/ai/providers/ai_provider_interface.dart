import '../models/ai_request.dart';
import '../models/ai_response.dart';

abstract class AIProviderInterface {
  Future<AIResponse> complete(AIRequest request);
  Stream<String> streamCompletion(AIRequest request);
  Future<bool> validateApiKey();
}
