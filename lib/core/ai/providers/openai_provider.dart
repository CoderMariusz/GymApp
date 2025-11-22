import 'dart:convert';
import 'package:dio/dio.dart';
import '../ai_config.dart';
import '../models/ai_request.dart';
import '../models/ai_response.dart';
import '../models/ai_error.dart';
import 'ai_provider_interface.dart';

class OpenAIProvider implements AIProviderInterface {
  final Dio _dio;

  OpenAIProvider() : _dio = Dio(BaseOptions(
    baseUrl: 'https://api.openai.com/v1',
    headers: {
      'Authorization': 'Bearer ${AIConfig.openAIKey}',
      'Content-Type': 'application/json',
    },
    connectTimeout: Duration(seconds: AIConfig.timeoutSeconds),
  ));

  @override
  Future<AIResponse> complete(AIRequest request) async {
    try {
      final response = await _dio.post('/chat/completions', data: {
        'model': AIConfig.openAIModel,
        'messages': [
          {'role': 'system', 'content': request.systemPrompt},
          {'role': 'user', 'content': request.userPrompt},
        ],
        'max_tokens': request.maxTokens,
        'temperature': request.temperature,
        'stream': false,
      });

      final data = response.data;
      final content = data['choices'][0]['message']['content'] as String;
      final tokensUsed = data['usage']['total_tokens'] as int;

      return AIResponse(
        content: content,
        tokensUsed: tokensUsed,
        estimatedCost: _calculateCost(tokensUsed),
        timestamp: DateTime.now(),
        model: AIConfig.openAIModel,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Stream<String> streamCompletion(AIRequest request) async* {
    final response = await _dio.post(
      '/chat/completions',
      data: {
        'model': AIConfig.openAIModel,
        'messages': [
          {'role': 'system', 'content': request.systemPrompt},
          {'role': 'user', 'content': request.userPrompt},
        ],
        'max_tokens': request.maxTokens,
        'temperature': request.temperature,
        'stream': true,
      },
      options: Options(responseType: ResponseType.stream),
    );

    await for (final chunk in response.data.stream) {
      final text = String.fromCharCodes(chunk);
      if (text.contains('data: ')) {
        final lines = text.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ') && !line.contains('[DONE]')) {
            final json = line.substring(6);
            try {
              final data = jsonDecode(json);
              final delta = data['choices'][0]['delta']['content'];
              if (delta != null) {
                yield delta as String;
              }
            } catch (_) {}
          }
        }
      }
    }
  }

  @override
  Future<bool> validateApiKey() async {
    try {
      await _dio.get('/models');
      return true;
    } catch (_) {
      return false;
    }
  }

  double _calculateCost(int tokens) {
    // gpt-4o-mini pricing (as of 2024)
    const inputCostPer1M = 0.15;  // $0.15 per 1M input tokens
    const outputCostPer1M = 0.60; // $0.60 per 1M output tokens

    // Simplified: assume 50/50 split
    return (tokens / 1000000) * ((inputCostPer1M + outputCostPer1M) / 2);
  }

  AIException _handleDioError(DioException e) {
    if (e.response?.statusCode == 429) {
      final retryAfter = int.tryParse(
        e.response?.headers.value('retry-after') ?? '60'
      ) ?? 60;
      return RateLimitException(retryAfterSeconds: retryAfter);
    } else if (e.response?.statusCode == 401) {
      return const AuthenticationException();
    } else if (e.response?.statusCode == 400) {
      return InvalidRequestException(e.response?.data['error']['message']);
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return const TimeoutException();
    } else {
      return NetworkException(e.message ?? 'Unknown network error');
    }
  }
}
