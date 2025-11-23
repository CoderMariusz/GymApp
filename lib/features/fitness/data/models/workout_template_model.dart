import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_template_entity.dart';
import 'package:lifeos/core/database/database.dart';

part 'workout_template_model.freezed.dart';

@freezed
sealed class WorkoutTemplateModel with _$WorkoutTemplateModel {
  const factory WorkoutTemplateModel({
    required String id,
    String? userId,
    required String name,
    String? description,
    required String category,
    required String difficulty,
    required int estimatedDuration,
    required String exercisesJson,
    @Default(false) bool isPreBuilt,
    @Default(false) bool isFavorite,
    @Default(0) int timesUsed,
    DateTime? lastUsed,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isSynced,
  }) = _WorkoutTemplateModel;

  const WorkoutTemplateModel._();

  factory WorkoutTemplateModel.fromDrift(WorkoutTemplate row) {
    return WorkoutTemplateModel(
      id: row.id,
      userId: row.userId,
      name: row.name,
      description: row.description,
      category: row.category,
      difficulty: row.difficulty,
      estimatedDuration: row.estimatedDuration,
      exercisesJson: row.exercises,
      isPreBuilt: row.isPreBuilt,
      isFavorite: row.isFavorite,
      timesUsed: row.timesUsed,
      lastUsed: row.lastUsed,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
    );
  }

  WorkoutTemplatesCompanion toDriftCompanion() {
    return WorkoutTemplatesCompanion.insert(
      id: id,
      userId: userId,
      name: name,
      description: Value(description),
      category: category,
      difficulty: difficulty,
      estimatedDuration: estimatedDuration,
      exercises: exercisesJson,
      isPreBuilt: Value(isPreBuilt),
      isFavorite: Value(isFavorite),
      timesUsed: Value(timesUsed),
      lastUsed: Value(lastUsed),
      createdAt: Value(createdAt),
      updatedAt: updatedAt != null ? Value(updatedAt) : Value(DateTime.now()),
      isSynced: Value(isSynced),
    );
  }

  WorkoutTemplateEntity toEntity() {
    final exercises = jsonDecode(exercisesJson) as List;
    return WorkoutTemplateEntity(
      id: id,
      userId: userId,
      name: name,
      description: description,
      category: category,
      difficulty: difficulty,
      estimatedDuration: estimatedDuration,
      exercises: exercises.cast<Map<String, dynamic>>(),
      isPreBuilt: isPreBuilt,
      isFavorite: isFavorite,
      timesUsed: timesUsed,
      lastUsed: lastUsed,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: isSynced,
    );
  }

  factory WorkoutTemplateModel.fromEntity(WorkoutTemplateEntity entity) {
    return WorkoutTemplateModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      description: entity.description,
      category: entity.category,
      difficulty: entity.difficulty,
      estimatedDuration: entity.estimatedDuration,
      exercisesJson: jsonEncode(entity.exercises),
      isPreBuilt: entity.isPreBuilt,
      isFavorite: entity.isFavorite,
      timesUsed: entity.timesUsed,
      lastUsed: entity.lastUsed,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: entity.isSynced,
    );
  }
}
