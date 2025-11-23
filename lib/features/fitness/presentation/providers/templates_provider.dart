import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/core/database/database_providers.dart';
import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/fitness/data/repositories/templates_repository_impl.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_template_entity.dart';
import 'package:lifeos/features/fitness/domain/repositories/templates_repository.dart';
import 'package:lifeos/features/fitness/domain/usecases/create_template_usecase.dart';
import 'package:lifeos/features/fitness/domain/usecases/get_templates_usecase.dart';

final templatesDatabaseProvider = Provider<AppDatabase>((ref) => ref.watch(appDatabaseProvider));
final templatesRepositoryProvider =
    Provider<TemplatesRepository>((ref) => TemplatesRepositoryImpl(ref.watch(templatesDatabaseProvider)));
final createTemplateUseCaseProvider =
    Provider((ref) => CreateTemplateUseCase(ref.watch(templatesRepositoryProvider)));
final getTemplatesUseCaseProvider =
    Provider((ref) => GetTemplatesUseCase(ref.watch(templatesRepositoryProvider)));

final templatesProvider = FutureProvider<List<WorkoutTemplateEntity>>((ref) async {
  final useCase = ref.watch(getTemplatesUseCaseProvider);
  final result = await useCase.getPreBuilt();
  return result.map(success: (success) => success.data, failure: (_) => []);
});

final userTemplatesProvider = FutureProvider.family<List<WorkoutTemplateEntity>, String>((ref, userId) async {
  final useCase = ref.watch(getTemplatesUseCaseProvider);
  final result = await useCase.getUserTemplates(userId);
  return result.map(success: (success) => success.data, failure: (_) => []);
});
