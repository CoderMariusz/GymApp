import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_request.freezed.dart';
part 'ai_request.g.dart';

@freezed
class AIRequest with _$AIRequest {
  const factory AIRequest({
    required String systemPrompt,
    required String userPrompt,
    Map<String, dynamic>? context,
    @Default(false) bool stream,
    @Default(2000) int maxTokens,
    @Default(0.7) double temperature,
  }) = _AIRequest;

  factory AIRequest.fromJson(Map<String, dynamic> json) =>
      _$AIRequestFromJson(json);
}
