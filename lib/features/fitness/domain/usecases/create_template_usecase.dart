import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_template_entity.dart';
import 'package:lifeos/features/fitness/domain/repositories/templates_repository.dart';

class CreateTemplateUseCase {
  final TemplatesRepository _repository;
  CreateTemplateUseCase(this._repository);
  Future<Result<WorkoutTemplateEntity>> call(WorkoutTemplateEntity template) =>
      _repository.createTemplate(template);
}
