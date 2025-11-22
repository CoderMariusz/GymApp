import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lifeos/features/mind_emotion/domain/entities/meditation_entity.dart';

part 'meditation_model.freezed.dart';
part 'meditation_model.g.dart';

/// Data model for Meditation (JSON serialization)
@freezed
class MeditationModel with _$MeditationModel {
  const factory MeditationModel({
    required String id,
    required String title,
    required String description,
    @JsonKey(name: 'duration_seconds') required int durationSeconds,
    required String category,
    @JsonKey(name: 'audio_url') required String audioUrl,
    @JsonKey(name: 'thumbnail_url') required String thumbnailUrl,
    @JsonKey(name: 'is_premium') required bool isPremium,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _MeditationModel;

  const MeditationModel._();

  factory MeditationModel.fromJson(Map<String, dynamic> json) =>
      _$MeditationModelFromJson(json);

  /// Convert model to domain entity
  MeditationEntity toEntity({
    bool isFavorited = false,
    bool isDownloaded = false,
    int completionCount = 0,
  }) {
    return MeditationEntity(
      id: id,
      title: title,
      description: description,
      durationSeconds: durationSeconds,
      category: MeditationCategory.fromString(category),
      audioUrl: audioUrl,
      thumbnailUrl: thumbnailUrl,
      createdAt: DateTime.parse(createdAt),
      isPremium: isPremium,
      isFavorited: isFavorited,
      isDownloaded: isDownloaded,
      completionCount: completionCount,
    );
  }

  /// Create model from entity
  factory MeditationModel.fromEntity(MeditationEntity entity) {
    return MeditationModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      durationSeconds: entity.durationSeconds,
      category: entity.category.value,
      audioUrl: entity.audioUrl,
      thumbnailUrl: entity.thumbnailUrl,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
