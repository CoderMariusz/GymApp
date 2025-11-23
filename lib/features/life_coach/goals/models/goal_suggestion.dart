import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/goal.dart';

part 'goal_suggestion.freezed.dart';
part 'goal_suggestion.g.dart';

@freezed
class GoalSuggestion with _$GoalSuggestion {
  const factory GoalSuggestion({
    required String title,
    required String description,
    required GoalCategory category,
    required String why,                // AI explanation
    required String actionPlan,         // How to achieve it
    required int estimatedDays,         // Suggested timeline
    @Default([]) List<String> milestones,  // Mini-goals
  }) = _GoalSuggestion;

  factory GoalSuggestion.fromJson(Map<String, dynamic> json) =>
      _$GoalSuggestionFromJson(json);
}
