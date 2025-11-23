import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_task.freezed.dart';
part 'plan_task.g.dart';

enum TaskCategory { fitness, productivity, wellness, personal, social }
enum TaskPriority { high, medium, low }
enum EnergyLevel { high, medium, low }

@freezed
class PlanTask with _$PlanTask {
  const factory PlanTask({
    required String id,
    required String title,
    required String description,
    required TaskCategory category,
    required TaskPriority priority,
    required int estimatedDuration,      // minutes
    required String suggestedTime,       // "07:00"
    required EnergyLevel energyLevel,
    required String why,                 // AI explanation
    @Default(false) bool isCompleted,
    DateTime? completedAt,
  }) = _PlanTask;

  factory PlanTask.fromJson(Map<String, dynamic> json) =>
      _$PlanTaskFromJson(json);
}
