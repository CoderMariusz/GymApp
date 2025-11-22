// Story 3.2: Exercise Library Screen
// Main screen for browsing, searching, and filtering exercises
//
// Acceptance Criteria Implemented:
// ✅ AC1: Exercise library with 500+ exercises (seeded on first launch)
// ✅ AC2: Categories: Chest, Back, Legs, Shoulders, Arms, Core, Cardio, Other
// ✅ AC3: Search bar with real-time filtering (<200ms)
// ✅ AC4: Exercise details: Name, category, muscle groups, instructions
// ✅ AC5: User can add custom exercises
// ✅ AC7: Favorite exercises (star icon) → Quick access

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../providers/exercise_providers.dart';
import '../widgets/exercise_list_tile.dart';
import '../widgets/exercise_search_bar.dart';
import '../widgets/category_filter_chips.dart';
import 'exercise_detail_screen.dart';
import 'create_custom_exercise_screen.dart';

class ExerciseLibraryScreen extends ConsumerStatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  ConsumerState<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends ConsumerState<ExerciseLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredExercises = ref.watch(filteredExercisesProvider);
    final favoriteExercises = ref.watch(favoriteExercisesProvider);
    final customExercises = ref.watch(customExercisesProvider);
    final showFavoritesOnly = ref.watch(showFavoritesOnlyProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exercise Library'),
        actions: [
          // AC7: Show favorites only toggle
          IconButton(
            icon: Icon(
              showFavoritesOnly ? Icons.star : Icons.star_border,
              color: showFavoritesOnly ? Colors.amber : null,
            ),
            onPressed: () {
              ref.read(showFavoritesOnlyProvider.notifier).state = !showFavoritesOnly;
            },
            tooltip: showFavoritesOnly ? 'Show All' : 'Show Favorites',
          ),
          // AC5: Create custom exercise
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateCustomExerciseScreen(),
                ),
              );
            },
            tooltip: 'Create Custom Exercise',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Exercises'),
            Tab(text: 'Favorites'),
            Tab(text: 'Custom'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // All Exercises Tab (AC1)
          _buildAllExercisesTab(filteredExercises, searchQuery, selectedCategory),

          // Favorites Tab (AC7)
          _buildFavoritesTab(favoriteExercises),

          // Custom Exercises Tab (AC5, AC6)
          _buildCustomExercisesTab(customExercises),
        ],
      ),
    );
  }

  /// Build All Exercises tab with search and filters
  Widget _buildAllExercisesTab(
    AsyncValue<List<Exercise>> filteredExercises,
    String searchQuery,
    String selectedCategory,
  ) {
    return Column(
      children: [
        // AC3: Search bar with real-time filtering (<200ms)
        const ExerciseSearchBar(),

        // AC2: Category filter chips
        const CategoryFilterChips(),

        // Exercise count indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: filteredExercises.when(
            data: (exercises) => Text(
              '${exercises.length} exercise${exercises.length != 1 ? 's' : ''} found',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ),

        // Exercise list
        Expanded(
          child: filteredExercises.when(
            data: (exercises) {
              if (exercises.isEmpty) {
                return _buildEmptyState(
                  icon: Icons.search_off,
                  title: 'No exercises found',
                  message: searchQuery.isNotEmpty
                      ? 'Try a different search term'
                      : 'No exercises in this category',
                );
              }

              return ListView.separated(
                itemCount: exercises.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return ExerciseListTile(
                    exercise: exercise,
                    onTap: () {
                      // AC4: Navigate to exercise details
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ExerciseDetailScreen(
                            exerciseId: exercise.id,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(error.toString()),
          ),
        ),
      ],
    );
  }

  /// Build Favorites tab (AC7: Quick access)
  Widget _buildFavoritesTab(AsyncValue<List<Exercise>> favoriteExercises) {
    return favoriteExercises.when(
      data: (exercises) {
        if (exercises.isEmpty) {
          return _buildEmptyState(
            icon: Icons.star_border,
            title: 'No favorite exercises yet',
            message: 'Tap the star icon on exercises to add them to your favorites',
          );
        }

        return ListView.separated(
          itemCount: exercises.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return ExerciseListTile(
              exercise: exercise,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailScreen(
                      exerciseId: exercise.id,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  /// Build Custom Exercises tab (AC5, AC6)
  Widget _buildCustomExercisesTab(AsyncValue<List<Exercise>> customExercises) {
    return customExercises.when(
      data: (exercises) {
        if (exercises.isEmpty) {
          return _buildEmptyState(
            icon: Icons.fitness_center,
            title: 'No custom exercises yet',
            message: 'Create your own exercises tailored to your workouts',
            action: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateCustomExerciseScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Custom Exercise'),
            ),
          );
        }

        return ListView.separated(
          itemCount: exercises.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            return ExerciseListTile(
              exercise: exercise,
              showCustomBadge: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ExerciseDetailScreen(
                      exerciseId: exercise.id,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action,
            ],
          ],
        ),
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load exercises',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Refresh providers
                ref.invalidate(allExercisesProvider);
                ref.invalidate(favoriteExercisesProvider);
                ref.invalidate(customExercisesProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
