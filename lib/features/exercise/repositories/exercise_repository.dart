// Story 3.2: Exercise Library - Repository Layer
// Handles all database operations for exercises and favorites

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise.dart';
import '../models/exercise_favorite.dart';
import '../models/exercise_exceptions.dart';

/// Repository for exercise-related database operations
///
/// Implements all acceptance criteria for Story 3.2:
/// - AC1: Exercise library with 500+ exercises
/// - AC3: Search bar with real-time filtering (<200ms)
/// - AC5: User can add custom exercises
/// - AC6: Custom exercises saved to user's library
/// - AC7: Favorite exercises → Quick access
class ExerciseRepository {
  final SupabaseClient _supabase;

  ExerciseRepository({required SupabaseClient supabase}) : _supabase = supabase;

  // ============================================================================
  // EXERCISE LIBRARY OPERATIONS (AC1, AC3)
  // ============================================================================

  /// Get all exercises from the library
  ///
  /// AC1: Exercise library with 500+ exercises (seeded on first launch)
  /// Returns both system and custom exercises
  Future<List<Exercise>> getAllExercises() async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch exercises: $e');
    }
  }

  /// Search exercises by query (AC3: Real-time filtering <200ms)
  ///
  /// Searches in:
  /// - Exercise name (primary)
  /// - Muscle groups
  /// - Description
  ///
  /// Note: For optimal performance (<200ms), consider implementing
  /// client-side filtering for already-loaded exercises
  Future<List<Exercise>> searchExercises(String query) async {
    if (query.isEmpty) {
      return getAllExercises();
    }

    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .or('name.ilike.%$query%,description.ilike.%$query%')
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search exercises: $e');
    }
  }

  /// Filter exercises by category (AC2: Categories)
  ///
  /// Categories: Chest, Back, Legs, Shoulders, Arms, Core, Cardio, Other
  ///
  /// Note: This filters by checking if muscle_groups array contains
  /// any muscles related to the category
  Future<List<Exercise>> filterByCategory(String category) async {
    if (category == 'All') {
      return getAllExercises();
    }

    // Map category to muscle group keywords
    final muscleKeywords = _getCategoryMuscleKeywords(category);

    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .filter('muscle_groups', 'ov', muscleKeywords)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter exercises by category: $e');
    }
  }

  /// Filter exercises by equipment type (AC2)
  Future<List<Exercise>> filterByEquipment(EquipmentType equipment) async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .eq('equipment', equipment.name)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter exercises by equipment: $e');
    }
  }

  /// Filter exercises by difficulty
  Future<List<Exercise>> filterByDifficulty(ExerciseDifficulty difficulty) async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .eq('difficulty', difficulty.name)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to filter exercises by difficulty: $e');
    }
  }

  /// Get exercise by ID (AC4: Exercise details)
  Future<Exercise> getExerciseById(String id) async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .eq('id', id)
          .single();

      return Exercise.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch exercise details: $e');
    }
  }

  // ============================================================================
  // CUSTOM EXERCISE OPERATIONS (AC5, AC6)
  // ============================================================================

  /// Create a custom exercise (AC5: User can add custom exercises)
  ///
  /// AC6: Custom exercises saved to user's library
  ///
  /// Validates inputs before creating:
  /// - Name: required, max 100 characters
  /// - Muscle groups: at least one required
  /// - Description: max 500 characters
  /// - Instructions: max 2000 characters
  Future<Exercise> createCustomExercise({
    required String name,
    String? description,
    required List<String> muscleGroups,
    required EquipmentType equipment,
    required ExerciseDifficulty difficulty,
    String? instructions,
  }) async {
    // ============================================================================
    // INPUT VALIDATION
    // ============================================================================

    // Validate name
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationException('Exercise name cannot be empty');
    }

    if (trimmedName.length > 100) {
      throw const ValidationException('Exercise name must be less than 100 characters');
    }

    // Validate muscle groups
    if (muscleGroups.isEmpty) {
      throw const ValidationException('At least one muscle group must be selected');
    }

    // Validate muscle groups aren't empty strings
    if (muscleGroups.any((mg) => mg.trim().isEmpty)) {
      throw const ValidationException('Muscle group names cannot be empty');
    }

    // Validate description length
    if (description != null && description.length > 500) {
      throw const ValidationException('Description must be less than 500 characters');
    }

    // Validate instructions length
    if (instructions != null && instructions.length > 2000) {
      throw const ValidationException('Instructions must be less than 2000 characters');
    }

    // ============================================================================
    // CREATE EXERCISE
    // ============================================================================

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw const AuthenticationException('User must be authenticated to create custom exercises');
      }

      final response = await _supabase
          .from('exercises')
          .insert({
            'name': trimmedName,
            'description': description?.trim(),
            'muscle_groups': muscleGroups.map((mg) => mg.trim()).toList(),
            'equipment': equipment.name,
            'difficulty': difficulty.name,
            'instructions': instructions?.trim(),
            'is_custom': true,
            'created_by': userId,
          })
          .select()
          .single();

      return Exercise.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      // Handle Supabase-specific errors
      if (e.code == 'PGRST301') {
        throw const AuthenticationException('User not authenticated');
      }
      throw ServerException('Database error: ${e.message}');
    } catch (e) {
      // Re-throw if already our exception type
      if (e is ExerciseException) rethrow;

      // Wrap other exceptions
      throw ExerciseException('Failed to create custom exercise: $e');
    }
  }

  /// Get all custom exercises created by current user (AC6)
  Future<List<Exercise>> getUserCustomExercises() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      final response = await _supabase
          .from('exercises')
          .select()
          .eq('is_custom', true)
          .eq('created_by', userId)
          .order('name', ascending: true);

      return (response as List)
          .map((json) => Exercise.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch custom exercises: $e');
    }
  }

  /// Update a custom exercise (only owner can update)
  Future<Exercise> updateCustomExercise({
    required String exerciseId,
    String? name,
    String? description,
    List<String>? muscleGroups,
    EquipmentType? equipment,
    ExerciseDifficulty? difficulty,
    String? instructions,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User must be authenticated');
      }

      // Build update map with only provided fields
      final Map<String, dynamic> updates = {
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null) updates['name'] = name;
      if (description != null) updates['description'] = description;
      if (muscleGroups != null) updates['muscle_groups'] = muscleGroups;
      if (equipment != null) updates['equipment'] = equipment.name;
      if (difficulty != null) updates['difficulty'] = difficulty.name;
      if (instructions != null) updates['instructions'] = instructions;

      final response = await _supabase
          .from('exercises')
          .update(updates)
          .eq('id', exerciseId)
          .eq('created_by', userId) // Ensure user owns the exercise
          .eq('is_custom', true) // Can only update custom exercises
          .select()
          .single();

      return Exercise.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to update custom exercise: $e');
    }
  }

  /// Delete a custom exercise (only owner can delete)
  Future<void> deleteCustomExercise(String exerciseId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User must be authenticated');
      }

      await _supabase
          .from('exercises')
          .delete()
          .eq('id', exerciseId)
          .eq('created_by', userId)
          .eq('is_custom', true);
    } catch (e) {
      throw Exception('Failed to delete custom exercise: $e');
    }
  }

  // ============================================================================
  // FAVORITE OPERATIONS (AC7)
  // ============================================================================

  /// Get all favorite exercises for current user (AC7: Quick access)
  Future<List<Exercise>> getFavoriteExercises() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return [];
      }

      // Join favorites with exercises table
      final response = await _supabase
          .from('exercise_favorites')
          .select('exercise_id, exercises(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => Exercise.fromJson(item['exercises'] as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch favorite exercises: $e');
    }
  }

  /// Check if exercise is favorited by current user
  Future<bool> isExerciseFavorited(String exerciseId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return false;
      }

      final response = await _supabase
          .from('exercise_favorites')
          .select('id')
          .eq('user_id', userId)
          .eq('exercise_id', exerciseId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Toggle favorite status for an exercise (AC7: star icon)
  ///
  /// Returns true if exercise was favorited, false if unfavorited
  ///
  /// SECURITY: Uses auth.uid() in database function (no user_id parameter)
  Future<bool> toggleExerciseFavorite(String exerciseId) async {
    try {
      // Call the database function (it uses auth.uid() internally)
      final response = await _supabase.rpc(
        'toggle_exercise_favorite',
        params: {
          'p_exercise_id': exerciseId,
        },
      );

      return response as bool;
    } catch (e) {
      throw Exception('Failed to toggle favorite: $e');
    }
  }

  /// Add exercise to favorites
  Future<void> addToFavorites(String exerciseId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User must be authenticated');
      }

      await _supabase.from('exercise_favorites').insert({
        'user_id': userId,
        'exercise_id': exerciseId,
      });
    } catch (e) {
      throw Exception('Failed to add to favorites: $e');
    }
  }

  /// Remove exercise from favorites
  Future<void> removeFromFavorites(String exerciseId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User must be authenticated');
      }

      await _supabase
          .from('exercise_favorites')
          .delete()
          .eq('user_id', userId)
          .eq('exercise_id', exerciseId);
    } catch (e) {
      throw Exception('Failed to remove from favorites: $e');
    }
  }

  /// Get count of user's favorite exercises
  ///
  /// SECURITY: Uses auth.uid() in database function (no user_id parameter)
  Future<int> getFavoritesCount() async {
    try {
      // Call the database function (it uses auth.uid() internally)
      final response = await _supabase.rpc('get_user_favorites_count');

      return response as int;
    } catch (e) {
      return 0;
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Map category to muscle group keywords for filtering
  List<String> _getCategoryMuscleKeywords(String category) {
    switch (category.toLowerCase()) {
      case 'chest':
        return ['chest'];
      case 'back':
        return ['back', 'lats', 'traps'];
      case 'legs':
        return ['quads', 'hamstrings', 'glutes', 'calves', 'legs'];
      case 'shoulders':
        return ['shoulders', 'delts', 'front delts', 'side delts', 'rear delts'];
      case 'arms':
        return ['biceps', 'triceps', 'forearms'];
      case 'core':
        return ['core', 'abs', 'obliques', 'lower abs'];
      case 'cardio':
        return ['cardio'];
      default:
        return [];
    }
  }
}
