// Story 3.2: Exercise Library - Riverpod Providers
// State management for exercise library, search, filters, and favorites

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise.dart';
import '../repositories/exercise_repository.dart';

part 'exercise_providers.g.dart';

// ============================================================================
// REPOSITORY PROVIDER
// ============================================================================

/// Provider for Supabase client
@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}

/// Provider for ExerciseRepository
@riverpod
ExerciseRepository exerciseRepository(ExerciseRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ExerciseRepository(supabase: supabase);
}

// ============================================================================
// EXERCISE LIBRARY PROVIDERS
// ============================================================================

/// Provider for all exercises (AC1: Exercise library with 500+ exercises)
///
/// This loads all exercises from the database (system + custom)
/// Cached automatically by Riverpod
@riverpod
Future<List<Exercise>> allExercises(AllExercisesRef ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.getAllExercises();
}

/// Provider for user's custom exercises (AC6: Custom exercises saved to user's library)
@riverpod
Future<List<Exercise>> customExercises(CustomExercisesRef ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.getUserCustomExercises();
}

/// Provider for favorite exercises (AC7: Favorite exercises → Quick access)
@riverpod
Future<List<Exercise>> favoriteExercises(FavoriteExercisesRef ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.getFavoriteExercises();
}

// ============================================================================
// SEARCH AND FILTER STATE PROVIDERS
// ============================================================================

/// Provider for search query state (AC3: Search bar with real-time filtering)
@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String query) => state = query;
}

/// Provider for selected category filter (AC2: Categories)
///
/// Options: All, Chest, Back, Legs, Shoulders, Arms, Core, Cardio, Other
@riverpod
class SelectedCategory extends _$SelectedCategory {
  @override
  String build() => 'All';

  void update(String category) => state = category;
}

/// Provider for selected equipment filter (AC2: Filter by equipment)
@riverpod
class SelectedEquipment extends _$SelectedEquipment {
  @override
  EquipmentType? build() => null;

  void update(EquipmentType? equipment) => state = equipment;
}

/// Provider for selected difficulty filter
@riverpod
class SelectedDifficulty extends _$SelectedDifficulty {
  @override
  ExerciseDifficulty? build() => null;

  void update(ExerciseDifficulty? difficulty) => state = difficulty;
}

/// Provider for "show favorites only" toggle
@riverpod
class ShowFavoritesOnly extends _$ShowFavoritesOnly {
  @override
  bool build() => false;

  void toggle() => state = !state;
  void update(bool value) => state = value;
}

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
@riverpod
Future<List<Exercise>> filteredExercises(FilteredExercisesRef ref) async {
  // Watch all filter states
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final selectedEquipment = ref.watch(selectedEquipmentProvider);
  final selectedDifficulty = ref.watch(selectedDifficultyProvider);
  final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);

  // Get exercises source (favorites or all)
  final exercises = showFavoritesOnly
      ? await ref.watch(favoriteExercisesProvider.future)
      : await ref.watch(allExercisesProvider.future);

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

  return filtered;
}

// ============================================================================
// EXERCISE DETAIL PROVIDER
// ============================================================================

/// Provider for a single exercise by ID (AC4: Exercise details)
///
/// Use like: ref.watch(exerciseDetailProvider(exerciseId))
@riverpod
Future<Exercise> exerciseDetail(ExerciseDetailRef ref, String exerciseId) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.getExerciseById(exerciseId);
}

// ============================================================================
// FAVORITE STATUS PROVIDER
// ============================================================================

/// Provider for checking if an exercise is favorited (AC7)
///
/// Use like: ref.watch(isExerciseFavoritedProvider(exerciseId))
@riverpod
Future<bool> isExerciseFavorited(IsExerciseFavoritedRef ref, String exerciseId) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.isExerciseFavorited(exerciseId);
}

/// Provider for favorites count
@riverpod
Future<int> favoritesCount(FavoritesCountRef ref) async {
  final repository = ref.watch(exerciseRepositoryProvider);
  return await repository.getFavoritesCount();
}

// ============================================================================
// CATEGORY STATISTICS PROVIDER
// ============================================================================

/// Provider for exercise counts by category (for UI display)
@riverpod
Future<Map<String, int>> categoryCounts(CategoryCountsRef ref) async {
  final exercises = await ref.watch(allExercisesProvider.future);

  final counts = <String, int>{};

  // Count exercises in each category
  for (final exercise in exercises) {
    final category = exercise.primaryCategory;
    counts[category] = (counts[category] ?? 0) + 1;
  }

  return counts;
}

// ============================================================================
// NOTIFIER FOR TOGGLING FAVORITES (AC7: star icon)
// ============================================================================

/// State notifier for managing favorite toggle action
@riverpod
class FavoriteToggle extends _$FavoriteToggle {
  late String exerciseId;

  @override
  Future<bool> build(String id) async {
    exerciseId = id;
    final repository = ref.watch(exerciseRepositoryProvider);
    return await repository.isExerciseFavorited(exerciseId);
  }

  Future<void> toggle() async {
    final repository = ref.read(exerciseRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => repository.toggleExerciseFavorite(exerciseId));
  }
}

// ============================================================================
// CUSTOM EXERCISE CREATION PROVIDER
// ============================================================================

/// State notifier for creating custom exercises (AC5: User can add custom exercises)
@riverpod
class CustomExerciseCreation extends _$CustomExerciseCreation {
  @override
  AsyncValue<Exercise?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> createCustomExercise({
    required String name,
    String? description,
    required List<String> muscleGroups,
    required EquipmentType equipment,
    required ExerciseDifficulty difficulty,
    String? instructions,
  }) async {
    final repository = ref.read(exerciseRepositoryProvider);
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
