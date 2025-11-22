import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifeos/features/settings/data/datasources/supabase_settings_datasource.dart';
import 'package:lifeos/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:lifeos/features/settings/domain/repositories/settings_repository.dart';
import 'package:lifeos/features/settings/domain/usecases/export_data_usecase.dart';
import 'package:lifeos/features/settings/domain/usecases/delete_account_usecase.dart';
import 'package:lifeos/features/settings/domain/usecases/cancel_deletion_usecase.dart';

// Datasource
final settingsDatasourceProvider = Provider<SupabaseSettingsDatasource>((ref) {
  return SupabaseSettingsDatasource(Supabase.instance.client);
});

// Repository
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final datasource = ref.watch(settingsDatasourceProvider);
  return SettingsRepositoryImpl(datasource);
});

// Use Cases
final exportDataUseCaseProvider = Provider<ExportDataUseCase>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return ExportDataUseCase(repository);
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return DeleteAccountUseCase(repository);
});

final cancelDeletionUseCaseProvider = Provider<CancelDeletionUseCase>((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return CancelDeletionUseCase(repository);
});

// State for pending deletion check
final hasPendingDeletionProvider = FutureProvider<bool>((ref) async {
  final useCase = ref.watch(deleteAccountUseCaseProvider);
  return await useCase.hasPendingDeletion();
});

// State for deletion scheduled date
final deletionScheduledDateProvider = FutureProvider<DateTime?>((ref) async {
  final useCase = ref.watch(deleteAccountUseCaseProvider);
  return await useCase.getScheduledDeletionDate();
});
