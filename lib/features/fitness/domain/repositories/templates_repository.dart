import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/features/fitness/domain/entities/workout_template_entity.dart';

abstract class TemplatesRepository {
  Future<Result<WorkoutTemplateEntity>> createTemplate(WorkoutTemplateEntity template);
  Future<Result<List<WorkoutTemplateEntity>>> getPreBuiltTemplates();
  Future<Result<List<WorkoutTemplateEntity>>> getUserTemplates(String userId);
  Future<Result<WorkoutTemplateEntity>> getTemplateById(String id);
  Future<Result<void>> deleteTemplate(String id);
  Future<Result<void>> toggleFavorite(String id);
  Future<Result<void>> incrementUsage(String id);
}
