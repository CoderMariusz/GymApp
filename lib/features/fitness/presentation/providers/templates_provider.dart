import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymapp/core/database/database.dart';
import 'package:gymapp/core/initialization/app_initializer.dart';
import 'package:gymapp/features/fitness/data/repositories/templates_repository_impl.dart';
import 'package:gymapp/features/fitness/domain/entities/workout_template_entity.dart';
import 'package:gymapp/features/fitness/domain/repositories/templates_repository.dart';
import 'package:gymapp/features/fitness/domain/usecases/create_template_usecase.dart';
import 'package:gymapp/features/fitness/domain/usecases/get_templates_usecase.dart';

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
  return result.when(success: (t) => t, failure: (_) => []);
});

final userTemplatesProvider = FutureProvider.family<List<WorkoutTemplateEntity>, String>((ref, userId) async {
  final useCase = ref.watch(getTemplatesUseCaseProvider);
  final result = await useCase.getUserTemplates(userId);
  return result.when(success: (t) => t, failure: (_) => []);
});
