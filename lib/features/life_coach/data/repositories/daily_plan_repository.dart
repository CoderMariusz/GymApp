import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../core/database/database.dart';
import '../../ai/models/daily_plan.dart';
import '../../ai/models/plan_task.dart';

class DailyPlanRepository {
  final AppDatabase _db;

  DailyPlanRepository(this._db);

  Future<void> savePlan(DailyPlan plan) async {
    await _db.into(_db.dailyPlans).insert(
          DailyPlansCompanion.insert(
            id: plan.id,
            date: plan.date,
            tasksJson: jsonEncode(plan.tasks.map((t) => t.toJson()).toList()),
            dailyTheme: plan.dailyTheme,
            motivationalQuote: Value(plan.motivationalQuote),
            createdAt: plan.createdAt,
            source: plan.source.index,
            metadataJson: Value(plan.metadata != null ? jsonEncode(plan.metadata) : null),
          ),
          mode: InsertMode.replace,
        );
  }

  Future<DailyPlan?> getPlanForDate(DateTime date) async {
    final dateOnly = DateTime(date.year, date.month, date.day);

    final query = _db.select(_db.dailyPlans)
      ..where((p) => p.date.equals(dateOnly))
      ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
      ..limit(1);

    final result = await query.getSingleOrNull();

    return result != null ? _fromDto(result) : null;
  }

  Future<List<DailyPlan>> getRecentPlans({int limit = 7}) async {
    final query = _db.select(_db.dailyPlans)
      ..orderBy([(p) => OrderingTerm.desc(p.date)])
      ..limit(limit);

    final results = await query.get();

    return results.map((dto) => _fromDto(dto)).toList();
  }

  Future<void> deletePlan(String planId) async {
    await (_db.delete(_db.dailyPlans)..where((p) => p.id.equals(planId))).go();
  }

  DailyPlan _fromDto(DailyPlanData data) {
    final metaJson = data.metadataJson;
    return DailyPlan(
      id: data.id,
      date: data.date,
      tasks: (jsonDecode(data.tasksJson) as List)
          .map((json) => PlanTask.fromJson(json))
          .toList(),
      dailyTheme: data.dailyTheme,
      motivationalQuote: data.motivationalQuote,
      createdAt: data.createdAt,
      source: PlanSource.values[data.source],
      metadata: metaJson != null ? jsonDecode(metaJson) : null,
    );
  }
}
