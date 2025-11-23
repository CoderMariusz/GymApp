import 'package:drift/drift.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_log_entity.dart';
import 'package:lifeos/core/database/database.dart';

part 'workout_log_model.freezed.dart';
part 'workout_log_model.g.dart';

/// Model for workout log data
@freezed
class WorkoutLogModel with _$WorkoutLogModel {
  const factory WorkoutLogModel({
    required String id,
    required String userId,
    required DateTime timestamp,
    required String workoutName,
    @Default(0) int duration,
    String? notes,
    @Default(false) bool isQuickLog,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(false) bool isSynced,
  }) = _WorkoutLogModel;

  const WorkoutLogModel._();

  factory WorkoutLogModel.fromJson(Map<String, dynamic> json) =>
      _$WorkoutLogModelFromJson(json);

  /// Create model from Drift database row
  factory WorkoutLogModel.fromDrift(WorkoutLog row) {
    return WorkoutLogModel(
      id: row.id,
      userId: row.userId,
      timestamp: row.timestamp,
      workoutName: row.workoutName,
      duration: row.duration,
      notes: row.notes,
      isQuickLog: row.isQuickLog,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
    );
  }

  /// Convert to Drift companion for insertion/update
  WorkoutLogsCompanion toDriftCompanion() {
    return WorkoutLogsCompanion.insert(
      id: id,
      userId: userId,
      timestamp: timestamp,
      workoutName: workoutName,
      duration: duration,
      notes: Value(notes),
      isQuickLog: Value(isQuickLog),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt ?? DateTime.now()),
      isSynced: Value(isSynced),
    );
  }

  /// Convert model to entity
  WorkoutLogEntity toEntity({List<dynamic>? sets}) {
    return WorkoutLogEntity(
      id: id,
      userId: userId,
      timestamp: timestamp,
      workoutName: workoutName,
      duration: duration,
      notes: notes,
      isQuickLog: isQuickLog,
      sets: sets != null ? List.from(sets) : [],
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: isSynced,
    );
  }

  /// Create model from entity
  factory WorkoutLogModel.fromEntity(WorkoutLogEntity entity) {
    return WorkoutLogModel(
      id: entity.id,
      userId: entity.userId,
      timestamp: entity.timestamp,
      workoutName: entity.workoutName,
      duration: entity.duration,
      notes: entity.notes,
      isQuickLog: entity.isQuickLog,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: entity.isSynced,
    );
  }
}
