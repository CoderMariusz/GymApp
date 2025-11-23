import 'package:gymapp/core/error/result.dart';
import 'package:gymapp/features/fitness/domain/entities/workout_template_entity.dart';
import 'package:gymapp/features/fitness/domain/repositories/templates_repository.dart';

class GetTemplatesUseCase {
  final TemplatesRepository _repository;
  GetTemplatesUseCase(this._repository);

  Future<Result<List<WorkoutTemplateEntity>>> getPreBuilt() => _repository.getPreBuiltTemplates();
  Future<Result<List<WorkoutTemplateEntity>>> getUserTemplates(String userId) =>
      _repository.getUserTemplates(userId);
}
