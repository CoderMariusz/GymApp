// Story 3.2: Exercise Library - Exercise Model
// This file defines the Exercise data model using Freezed for immutability

import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

/// Enum for exercise difficulty levels
enum ExerciseDifficulty {
  @JsonValue('beginner')
  beginner,
  @JsonValue('intermediate')
  intermediate,
  @JsonValue('advanced')
  advanced,
}

/// Enum for equipment types
enum EquipmentType {
  @JsonValue('barbell')
  barbell,
  @JsonValue('dumbbell')
  dumbbell,
  @JsonValue('machine')
  machine,
  @JsonValue('bodyweight')
  bodyweight,
  @JsonValue('cable')
  cable,
  @JsonValue('other')
  other,
}

/// Exercise model representing an exercise from the library
///
/// This model maps to the `exercises` table in Supabase
///
/// AC2: Categories: Chest, Back, Legs, Shoulders, Arms, Core, Cardio, Other
/// AC4: Exercise details: Name, category, muscle groups, instructions
@freezed
class Exercise with _$Exercise {
  const Exercise._();

  const factory Exercise({
    /// Unique identifier (UUID from Supabase)
    required String id,

    /// Exercise name (e.g., "Barbell Bench Press")
    required String name,

    /// Detailed description of the exercise
    String? description,

    /// Primary and secondary muscle groups targeted
    /// e.g., ['chest', 'triceps', 'shoulders']
    @Default([]) List<String> muscleGroups,

    /// Equipment required for the exercise
    required EquipmentType equipment,

    /// Difficulty level
    required ExerciseDifficulty difficulty,

    /// Step-by-step instructions
    String? instructions,

    /// URL to video demonstration (if available)
    String? videoUrl,

    /// URL to exercise image/thumbnail
    String? imageUrl,

    /// Whether this is a custom exercise created by a user (AC5)
    @Default(false) bool isCustom,

    /// User ID who created the custom exercise (null for system exercises)
    String? createdBy,

    /// Timestamp when exercise was created
    DateTime? createdAt,

    /// Timestamp when exercise was last updated
    DateTime? updatedAt,
  }) = _Exercise;

  /// Create Exercise from JSON (Supabase response)
  factory Exercise.fromJson(Map<String, dynamic> json) => _$ExerciseFromJson(json);

  /// Get primary category from muscle groups (AC2)
  /// Maps muscle groups to categories: Chest, Back, Legs, Shoulders, Arms, Core, Cardio, Other
  String get primaryCategory {
    if (muscleGroups.isEmpty) return 'Other';

    final primary = muscleGroups.first.toLowerCase();

    // Map to categories
    if (primary.contains('chest')) return 'Chest';
    if (primary.contains('back') || primary.contains('lat')) return 'Back';
    if (primary.contains('quad') || primary.contains('hamstring') ||
        primary.contains('glute') || primary.contains('calf') || primary == 'legs') {
      return 'Legs';
    }
    if (primary.contains('shoulder') || primary.contains('delt')) return 'Shoulders';
    if (primary.contains('bicep') || primary.contains('tricep')) return 'Arms';
    if (primary.contains('core') || primary.contains('abs') || primary.contains('oblique')) {
      return 'Core';
    }
    if (primary == 'cardio') return 'Cardio';

    return 'Other';
  }

  /// Get user-friendly equipment name
  String get equipmentName {
    switch (equipment) {
      case EquipmentType.barbell:
        return 'Barbell';
      case EquipmentType.dumbbell:
        return 'Dumbbell';
      case EquipmentType.machine:
        return 'Machine';
      case EquipmentType.bodyweight:
        return 'Bodyweight';
      case EquipmentType.cable:
        return 'Cable';
      case EquipmentType.other:
        return 'Other';
    }
  }

  /// Get user-friendly difficulty name
  String get difficultyName {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return 'Beginner';
      case ExerciseDifficulty.intermediate:
        return 'Intermediate';
      case ExerciseDifficulty.advanced:
        return 'Advanced';
    }
  }

  /// Get color for difficulty level (for UI)
  String get difficultyColor {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return '#4CAF50'; // Green
      case ExerciseDifficulty.intermediate:
        return '#FF9800'; // Orange
      case ExerciseDifficulty.advanced:
        return '#F44336'; // Red
    }
  }

  /// Check if exercise matches search query (AC3: Search bar with real-time filtering)
  bool matchesSearchQuery(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();

    // Search in name
    if (name.toLowerCase().contains(lowerQuery)) return true;

    // Search in muscle groups
    if (muscleGroups.any((mg) => mg.toLowerCase().contains(lowerQuery))) return true;

    // Search in equipment
    if (equipmentName.toLowerCase().contains(lowerQuery)) return true;

    // Search in description
    if (description?.toLowerCase().contains(lowerQuery) ?? false) return true;

    return false;
  }
}

/// Extension to help with filtering exercises (AC2: Filter by category)
extension ExerciseListExtension on List<Exercise> {
  /// Filter exercises by category
  List<Exercise> filterByCategory(String category) {
    if (category == 'All') return this;
    return where((ex) => ex.primaryCategory == category).toList();
  }

  /// Filter exercises by equipment type (AC2: Filter by equipment)
  List<Exercise> filterByEquipment(EquipmentType? equipment) {
    if (equipment == null) return this;
    return where((ex) => ex.equipment == equipment).toList();
  }

  /// Filter exercises by difficulty
  List<Exercise> filterByDifficulty(ExerciseDifficulty? difficulty) {
    if (difficulty == null) return this;
    return where((ex) => ex.difficulty == difficulty).toList();
  }

  /// Filter exercises by search query (AC3)
  List<Exercise> filterBySearch(String query) {
    if (query.isEmpty) return this;
    return where((ex) => ex.matchesSearchQuery(query)).toList();
  }

  /// Get only custom exercises (AC5: User can add custom exercises)
  List<Exercise> get customExercises {
    return where((ex) => ex.isCustom).toList();
  }

  /// Get only system exercises
  List<Exercise> get systemExercises {
    return where((ex) => !ex.isCustom).toList();
  }
}
