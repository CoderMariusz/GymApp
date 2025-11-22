import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/supabase_storage_datasource.dart';
import '../../data/datasources/user_profile_datasource.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../domain/usecases/upload_avatar_usecase.dart';

/// User profile data source provider
final userProfileDataSourceProvider = Provider<UserProfileDataSource>((ref) {
  final client = ref.watch(supabaseProvider);
  return UserProfileDataSource(client);
});

/// Supabase storage data source provider
final supabaseStorageDataSourceProvider =
    Provider<SupabaseStorageDataSource>((ref) {
  final client = ref.watch(supabaseProvider);
  return SupabaseStorageDataSource(client);
});

/// Profile repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final profileDataSource = ref.watch(userProfileDataSourceProvider);
  final storageDataSource = ref.watch(supabaseStorageDataSourceProvider);
  return ProfileRepositoryImpl(profileDataSource, storageDataSource);
});

/// Update profile use case provider
final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UpdateProfileUseCase(repository);
});

/// Upload avatar use case provider
final uploadAvatarUseCaseProvider = Provider<UploadAvatarUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return UploadAvatarUseCase(repository);
});

/// Change password use case provider
final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  final repository = ref.watch(profileRepositoryProvider);
  return ChangePasswordUseCase(repository);
});
