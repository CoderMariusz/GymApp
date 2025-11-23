import 'package:drift/drift.dart';
import 'package:gymapp/core/database/database.dart';
import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/core/error/failures.dart';
import 'package:gymapp/features/fitness/data/models/workout_template_model.dart';
import 'package:gymapp/features/fitness/domain/entities/workout_template_entity.dart';
import 'package:gymapp/features/fitness/domain/repositories/templates_repository.dart';

class TemplatesRepositoryImpl implements TemplatesRepository {
  final AppDatabase _database;

  TemplatesRepositoryImpl(this._database);

  @override
  Future<Result<WorkoutTemplateEntity>> createTemplate(WorkoutTemplateEntity template) async {
    try {
      final model = WorkoutTemplateModel.fromEntity(template);
      await _database.into(_database.workoutTemplates).insert(model.toDriftCompanion());
      return Result.success(template);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to create template: $e'));
    }
  }

  @override
  Future<Result<List<WorkoutTemplateEntity>>> getPreBuiltTemplates() async {
    try {
      final rows = await (_database.select(_database.workoutTemplates)
            ..where((tbl) => tbl.isPreBuilt.equals(true)))
          .get();
      final entities = rows.map((r) => WorkoutTemplateModel.fromDrift(r).toEntity()).toList();
      return Result.success(entities);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get pre-built templates: $e'));
    }
  }

  @override
  Future<Result<List<WorkoutTemplateEntity>>> getUserTemplates(String userId) async {
    try {
      final rows = await (_database.select(_database.workoutTemplates)
            ..where((tbl) => tbl.userId.equals(userId) & tbl.isPreBuilt.equals(false)))
          .get();
      final entities = rows.map((r) => WorkoutTemplateModel.fromDrift(r).toEntity()).toList();
      return Result.success(entities);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get user templates: $e'));
    }
  }

  @override
  Future<Result<WorkoutTemplateEntity>> getTemplateById(String id) async {
    try {
      final row = await (_database.select(_database.workoutTemplates)
            ..where((tbl) => tbl.id.equals(id)))
          .getSingleOrNull();
      if (row == null) return Result.failure(DatabaseFailure('Template not found'));
      return Result.success(WorkoutTemplateModel.fromDrift(row).toEntity());
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to get template: $e'));
    }
  }

  @override
  Future<Result<void>> deleteTemplate(String id) async {
    try {
      await (_database.delete(_database.workoutTemplates)..where((tbl) => tbl.id.equals(id))).go();
      return const Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to delete template: $e'));
    }
  }

  @override
  Future<Result<void>> toggleFavorite(String id) async {
    try {
      final template = await getTemplateById(id);
      return template.when(
        success: (t) async {
          await (_database.update(_database.workoutTemplates)..where((tbl) => tbl.id.equals(id)))
              .write(WorkoutTemplatesCompanion(isFavorite: Value(!t.isFavorite)));
          return const Result.success(null);
        },
        failure: (f) => Result.failure(f),
      );
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to toggle favorite: $e'));
    }
  }

  @override
  Future<Result<void>> incrementUsage(String id) async {
    try {
      final template = await getTemplateById(id);
      return template.when(
        success: (t) async {
          await (_database.update(_database.workoutTemplates)..where((tbl) => tbl.id.equals(id)))
              .write(WorkoutTemplatesCompanion(
            timesUsed: Value(t.timesUsed + 1),
            lastUsed: Value(DateTime.now()),
          ));
          return const Result.success(null);
        },
        failure: (f) => Result.failure(f),
      );
    } catch (e) {
      return Result.failure(DatabaseFailure('Failed to increment usage: $e'));
    }
  }
}
