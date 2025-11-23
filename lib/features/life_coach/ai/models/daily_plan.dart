import 'package:freezed_annotation/freezed_annotation.dart';
import 'plan_task.dart';

part 'daily_plan.freezed.dart';
part 'daily_plan.g.dart';

enum PlanSource { ai_generated, manual }

@freezed
class DailyPlan with _$DailyPlan {
  const factory DailyPlan({
    required String id,
    required DateTime date,
    required List<PlanTask> tasks,
    required String dailyTheme,
    String? motivationalQuote,
    required DateTime createdAt,
    required PlanSource source,
    Map<String, dynamic>? metadata,    // AI model used, tokens, etc.
  }) = _DailyPlan;

  factory DailyPlan.fromJson(Map<String, dynamic> json) =>
      _$DailyPlanFromJson(json);
}
