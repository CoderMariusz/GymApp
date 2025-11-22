// Story 3.2: Exercise Library - Riverpod Providers
// State management for exercise library, search, filters, and favorites

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';

// ============================================================================
// REPOSITORY PROVIDER
// ============================================================================

/// Provider for Supabase client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for ExerciseRepository
final exerciseRepositoryProvider = Provider<ExerciseRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ExerciseRepository(supabase: supabase);
});

// ============================================================================
// EXERCISE LIBRARY PROVIDERS
// ============================================================================

/// Provider for all exercises (AC1: Exercise library with 500+ exercises)
///
/// This loads all exercises from the database (system + custom)
/// Cached automatically by Riverpod
final allExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.getAllExercises();
});

/// Provider for user's custom exercises (AC6: Custom exercises saved to user's library)
final customExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.getUserCustomExercises();
});

/// Provider for favorite exercises (AC7: Favorite exercises → Quick access)
final favoriteExercisesProvider = FutureProvider<List<Exercise>>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.getFavoriteExercises();
});

// ============================================================================
// SEARCH AND FILTER STATE PROVIDERS
// ============================================================================

/// Provider for search query state (AC3: Search bar with real-time filtering)
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider for selected category filter (AC2: Categories)
///
/// Options: All, Chest, Back, Legs, Shoulders, Arms, Core, Cardio, Other
final selectedCategoryProvider = StateProvider<String>((ref) => 'All');

/// Provider for selected equipment filter (AC2: Filter by equipment)
final selectedEquipmentProvider = StateProvider<EquipmentType?>((ref) => null);

/// Provider for selected difficulty filter
final selectedDifficultyProvider = StateProvider<ExerciseDifficulty?>((ref) => null);

/// Provider for "show favorites only" toggle
final showFavoritesOnlyProvider = StateProvider<bool>((ref) => false);

// ============================================================================
// FILTERED EXERCISES PROVIDER (AC3: Real-time filtering <200ms)
// ============================================================================

/// Provider for filtered exercises based on search and filters
///
/// This provider combines all filters (search, category, equipment, difficulty, favorites)
/// and returns the filtered list of exercises.
///
/// AC3: Search bar with real-time filtering (<200ms)
/// Uses client-side filtering for optimal performance
final filteredExercisesProvider = Provider<AsyncValue<List<Exercise>>>((ref) {
  // Watch all filter states
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final selectedEquipment = ref.watch(selectedEquipmentProvider);
  final selectedDifficulty = ref.watch(selectedDifficultyProvider);
  final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);

  // Get exercises source (favorites or all)
  final exercisesAsync = showFavoritesOnly
      ? ref.watch(favoriteExercisesProvider)
      : ref.watch(allExercisesProvider);

  // Apply filters to exercises
  return exercisesAsync.when(
    data: (exercises) {
      var filtered = exercises;

      // Apply search filter (AC3)
      if (searchQuery.isNotEmpty) {
        filtered = filtered.filterBySearch(searchQuery);
      }

      // Apply category filter (AC2)
      if (selectedCategory != 'All') {
        filtered = filtered.filterByCategory(selectedCategory);
      }

      // Apply equipment filter
      if (selectedEquipment != null) {
        filtered = filtered.filterByEquipment(selectedEquipment);
      }

      // Apply difficulty filter
      if (selectedDifficulty != null) {
        filtered = filtered.filterByDifficulty(selectedDifficulty);
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// ============================================================================
// EXERCISE DETAIL PROVIDER
// ============================================================================

/// Provider for a single exercise by ID (AC4: Exercise details)
///
/// Use like: ref.watch(exerciseDetailProvider(exerciseId))
final exerciseDetailProvider = FutureProvider.family<Exercise, String>((ref, exerciseId) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.getExerciseById(exerciseId);
});

// ============================================================================
// FAVORITE STATUS PROVIDER
// ============================================================================

/// Provider for checking if an exercise is favorited (AC7)
///
/// Use like: ref.watch(isExerciseFavoritedProvider(exerciseId))
final isExerciseFavoritedProvider = FutureProvider.family<bool, String>((ref, exerciseId) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.isExerciseFavorited(exerciseId);
});

/// Provider for favorites count
final favoritesCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.getFavoritesCount();
});

// ============================================================================
// CATEGORY STATISTICS PROVIDER
// ============================================================================

/// Provider for exercise counts by category (for UI display)
final categoryCountsProvider = Provider<Map<String, int>>((ref) {
  final exercisesAsync = ref.watch(allExercisesProvider);

  return exercisesAsync.when(
    data: (exercises) {
      final counts = <String, int>{};

      // Count exercises in each category
      for (final exercise in exercises) {
        final category = exercise.primaryCategory;
        counts[category] = (counts[category] ?? 0) + 1;
      }

      return counts;
    },
    loading: () => {},
    error: (_, __) => {},
  );
});

// ============================================================================
// NOTIFIER FOR TOGGLING FAVORITES (AC7: star icon)
// ============================================================================

/// State notifier for managing favorite toggle action
class FavoriteToggleNotifier extends StateNotifier<AsyncValue<bool>> {
  FavoriteToggleNotifier(this.repository, this.exerciseId)
      : super(const AsyncValue.loading()) {
    _checkInitialState();
  }

  final ExerciseRepository repository;
  final String exerciseId;

  Future<void> _checkInitialState() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.isExerciseFavorited(exerciseId));
  }

  Future<void> toggle() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.toggleExerciseFavorite(exerciseId));
  }
}

/// Provider for favorite toggle notifier
final favoriteToggleProvider = StateNotifierProvider.family<FavoriteToggleNotifier, AsyncValue<bool>, String>(
  (ref, exerciseId) {
    final repository = ref.watch(exerciseRepositoryProvider);
    return FavoriteToggleNotifier(repository, exerciseId);
  },
);

// ============================================================================
// CUSTOM EXERCISE CREATION PROVIDER
// ============================================================================

/// State notifier for creating custom exercises (AC5: User can add custom exercises)
class CustomExerciseCreationNotifier extends StateNotifier<AsyncValue<Exercise?>> {
  CustomExerciseCreationNotifier(this.repository) : super(const AsyncValue.data(null));

  final ExerciseRepository repository;

  Future<void> createCustomExercise({
    required String name,
    String? description,
    required List<String> muscleGroups,
    required EquipmentType equipment,
    required ExerciseDifficulty difficulty,
    String? instructions,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.createCustomExercise(
          name: name,
          description: description,
          muscleGroups: muscleGroups,
          equipment: equipment,
          difficulty: difficulty,
          instructions: instructions,
        ));
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for custom exercise creation
final customExerciseCreationProvider =
    StateNotifierProvider<CustomExerciseCreationNotifier, AsyncValue<Exercise?>>((ref) {
  final repository = ref.watch(exerciseRepositoryProvider);
  return CustomExerciseCreationNotifier(repository);
});
