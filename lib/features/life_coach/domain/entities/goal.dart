import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal.freezed.dart';

enum GoalCategory { fitness, health, career, personal, social, financial }
enum GoalStatus { active, completed, paused, archived }

@freezed
class Goal with _$Goal {
  const factory Goal({
    required String id,
    required String title,
    required String description,
    required GoalCategory category,
    required GoalStatus status,
    required DateTime targetDate,
    DateTime? completedAt,
    required DateTime createdAt,
  }) = _Goal;
}
