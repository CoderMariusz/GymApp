import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_response.freezed.dart';
part 'ai_response.g.dart';

@freezed
sealed class AIResponse with _$AIResponse {
  const factory AIResponse({
    required String content,
    required int tokensUsed,
    required double estimatedCost,
    required DateTime timestamp,
    String? model,
    Map<String, dynamic>? metadata,
  }) = _AIResponse;

  factory AIResponse.fromJson(Map<String, dynamic> json) =>
      _$AIResponseFromJson(json);
}
