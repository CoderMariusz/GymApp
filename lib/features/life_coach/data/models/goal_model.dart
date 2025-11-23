import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lifeos/features/life_coach/domain/entities/goal_entity.dart';
import 'package:lifeos/core/database/database.dart';

part 'goal_model.freezed.dart';

@freezed
sealed class GoalModel with _$GoalModel {
  const factory GoalModel({
    required String id,
    required String userId,
    required String title,
    String? description,
    required String category,
    DateTime? targetDate,
    double? targetValue,
    String? unit,
    @Default(0.0) double currentValue,
    @Default(0) int completionPercentage,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    List<String>? tags,
    @Default(1) int priority,
    @Default(false) bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isSynced,
  }) = _GoalModel;

  const GoalModel._();

  factory GoalModel.fromDrift(Goal row) {
    final tagsJson = row.tags;
    return GoalModel(
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      category: row.category,
      targetDate: row.targetDate,
      targetValue: row.targetValue,
      unit: row.unit,
      currentValue: row.currentValue,
      completionPercentage: row.completionPercentage,
      isCompleted: row.isCompleted,
      completedAt: row.completedAt,
      tags: tagsJson != null ? List<String>.from(jsonDecode(tagsJson)) : null,
      priority: row.priority,
      isArchived: row.isArchived,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
    );
  }

  GoalsCompanion toDriftCompanion() {
    return GoalsCompanion.insert(
      id: id,
      userId: userId,
      title: title,
      description: Value(description),
      category: category,
      targetDate: Value(targetDate),
      targetValue: Value(targetValue),
      unit: Value(unit),
      currentValue: Value(currentValue),
      completionPercentage: Value(completionPercentage),
      isCompleted: Value(isCompleted),
      completedAt: Value(completedAt),
      tags: Value(tags != null ? jsonEncode(tags) : null),
      priority: Value(priority),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isSynced: Value(isSynced),
    );
  }

  GoalEntity toEntity() {
    return GoalEntity(
      id: id,
      userId: userId,
      title: title,
      description: description,
      category: category,
      targetDate: targetDate,
      targetValue: targetValue,
      unit: unit,
      currentValue: currentValue,
      completionPercentage: completionPercentage,
      isCompleted: isCompleted,
      completedAt: completedAt,
      tags: tags,
      priority: priority,
      isArchived: isArchived,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isSynced: isSynced,
    );
  }

  factory GoalModel.fromEntity(GoalEntity entity) {
    return GoalModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      description: entity.description,
      category: entity.category,
      targetDate: entity.targetDate,
      targetValue: entity.targetValue,
      unit: entity.unit,
      currentValue: entity.currentValue,
      completionPercentage: entity.completionPercentage,
      isCompleted: entity.isCompleted,
      completedAt: entity.completedAt,
      tags: entity.tags,
      priority: entity.priority,
      isArchived: entity.isArchived,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isSynced: entity.isSynced,
    );
  }
}
