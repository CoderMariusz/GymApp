import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_template_entity.freezed.dart';
part 'workout_template_entity.g.dart';

@freezed
class WorkoutTemplateEntity with _$WorkoutTemplateEntity {
  const factory WorkoutTemplateEntity({
    required String id,
    String? userId,
    required String name,
    String? description,
    required String category,
    required String difficulty,
    required int estimatedDuration,
    required List<Map<String, dynamic>> exercises,
    @Default(false) bool isPreBuilt,
    @Default(false) bool isFavorite,
    @Default(0) int timesUsed,
    DateTime? lastUsed,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isSynced,
  }) = _WorkoutTemplateEntity;

  const WorkoutTemplateEntity._();

  factory WorkoutTemplateEntity.fromJson(Map<String, dynamic> json) =>
      _$WorkoutTemplateEntityFromJson(json);
}
