import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/features/mind_emotion/data/datasources/meditation_local_datasource.dart';
import 'package:lifeos/features/mind_emotion/data/datasources/meditation_remote_datasource.dart';
import 'package:lifeos/features/mind_emotion/data/repositories/meditation_repository_impl.dart';
import 'package:lifeos/features/mind_emotion/domain/entities/meditation_entity.dart';
import 'package:lifeos/features/mind_emotion/domain/repositories/meditation_repository.dart';
import 'package:lifeos/features/mind_emotion/domain/usecases/download_meditation_usecase.dart';
import 'package:lifeos/features/mind_emotion/domain/usecases/get_meditations_usecase.dart';
import 'package:lifeos/features/mind_emotion/domain/usecases/toggle_favorite_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core dependencies
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final dioProvider = Provider<Dio>((ref) {
  return Dio();
});

// Data sources
final meditationRemoteDataSourceProvider =
    Provider<MeditationRemoteDataSource>((ref) {
  return MeditationRemoteDataSourceImpl(
    supabase: ref.watch(supabaseProvider),
  );
});

final meditationLocalDataSourceProvider =
    Provider<MeditationLocalDataSource>((ref) {
  return MeditationLocalDataSourceImpl(
    database: ref.watch(appDatabaseProvider),
  );
});

// Repository
final meditationRepositoryProvider = Provider<MeditationRepository>((ref) {
  return MeditationRepositoryImpl(
    remoteDataSource: ref.watch(meditationRemoteDataSourceProvider),
    localDataSource: ref.watch(meditationLocalDataSourceProvider),
    dio: ref.watch(dioProvider),
  );
});

// Use cases
final getMeditationsUseCaseProvider = Provider<GetMeditationsUseCase>((ref) {
  return GetMeditationsUseCase(
    repository: ref.watch(meditationRepositoryProvider),
  );
});

final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  return ToggleFavoriteUseCase(
    repository: ref.watch(meditationRepositoryProvider),
  );
});

final downloadMeditationUseCaseProvider =
    Provider<DownloadMeditationUseCase>((ref) {
  return DownloadMeditationUseCase(
    repository: ref.watch(meditationRepositoryProvider),
    getUserTier: () => UserTier.premium, // TODO: Implement actual tier check
  );
});

// State providers
final selectedCategoryProvider =
    StateProvider<MeditationCategory?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

final minDurationProvider = StateProvider<int?>((ref) => null);

final maxDurationProvider = StateProvider<int?>((ref) => null);

final favoritesOnlyProvider = StateProvider<bool>((ref) => false);

// Filtered meditations provider
final filteredMeditationsProvider =
    FutureProvider<List<MeditationEntity>>((ref) async {
  final useCase = ref.watch(getMeditationsUseCaseProvider);
  final category = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final minDuration = ref.watch(minDurationProvider);
  final maxDuration = ref.watch(maxDurationProvider);
  final favoritesOnly = ref.watch(favoritesOnlyProvider);

  final result = await useCase(
    category: category,
    searchQuery: searchQuery,
    minDuration: minDuration,
    maxDuration: maxDuration,
    favoritesOnly: favoritesOnly,
    userId: 'current_user_id', // TODO: Get from auth provider
  );

  return result.when(
    success: (meditations) => meditations,
    failure: (error) => throw error,
  );
});
