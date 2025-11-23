import 'package:drift/drift.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lifeos/features/fitness/domain/entities/exercise_set_entity.dart';
import 'package:lifeos/core/database/database.dart';

part 'exercise_set_model.freezed.dart';
part 'exercise_set_model.g.dart';

/// Model for exercise set data
@freezed
class ExerciseSetModel with _$ExerciseSetModel {
  const factory ExerciseSetModel({
    required String id,
    required String workoutLogId,
    required String exerciseName,
    required int setNumber,
    double? weight,
    int? reps,
    int? duration,
    int? restTime,
    String? notes,
    required DateTime createdAt,
  }) = _ExerciseSetModel;

  const ExerciseSetModel._();

  factory ExerciseSetModel.fromJson(Map<String, dynamic> json) =>
      _$ExerciseSetModelFromJson(json);

  /// Create model from Drift database row
  factory ExerciseSetModel.fromDrift(ExerciseSet row) {
    return ExerciseSetModel(
      id: row.id,
      workoutLogId: row.workoutLogId,
      exerciseName: row.exerciseName,
      setNumber: row.setNumber,
      weight: row.weight,
      reps: row.reps,
      duration: row.duration,
      restTime: row.restTime,
      notes: row.notes,
      createdAt: row.createdAt,
    );
  }

  /// Convert to Drift companion for insertion/update
  ExerciseSetsCompanion toDriftCompanion() {
    return ExerciseSetsCompanion.insert(
      id: id,
      workoutLogId: workoutLogId,
      exerciseName: exerciseName,
      setNumber: setNumber,
      weight: Value(weight),
      reps: Value(reps),
      duration: Value(duration),
      restTime: Value(restTime),
      notes: Value(notes),
      createdAt: Value(createdAt),
    );
  }

  /// Convert model to entity
  ExerciseSetEntity toEntity() {
    return ExerciseSetEntity(
      id: id,
      workoutLogId: workoutLogId,
      exerciseName: exerciseName,
      setNumber: setNumber,
      weight: weight,
      reps: reps,
      duration: duration,
      restTime: restTime,
      notes: notes,
      createdAt: createdAt,
    );
  }

  /// Create model from entity
  factory ExerciseSetModel.fromEntity(ExerciseSetEntity entity) {
    return ExerciseSetModel(
      id: entity.id,
      workoutLogId: entity.workoutLogId,
      exerciseName: entity.exerciseName,
      setNumber: entity.setNumber,
      weight: entity.weight,
      reps: entity.reps,
      duration: entity.duration,
      restTime: entity.restTime,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }
}
