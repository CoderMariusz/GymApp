import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:gymapp/core/auth/presentation/providers/auth_provider.dart';
import 'package:gymapp/features/fitness/presentation/providers/workout_log_provider.dart';
import 'package:gymapp/features/fitness/presentation/widgets/rest_timer_widget.dart';
import 'package:gymapp/features/fitness/presentation/widgets/exercise_set_input.dart';
import 'package:gymapp/features/fitness/domain/entities/workout_log_entity.dart';
import 'package:gymapp/features/fitness/domain/entities/exercise_set_entity.dart';

/// Workout Logging Page
/// Story 3.3: Advanced workout logging with rest timer
class WorkoutLoggingPage extends ConsumerStatefulWidget {
  const WorkoutLoggingPage({super.key});

  @override
  ConsumerState<WorkoutLoggingPage> createState() =>
      _WorkoutLoggingPageState();
}

class _WorkoutLoggingPageState extends ConsumerState<WorkoutLoggingPage> {
  final _workoutNameController = TextEditingController();
  final List<ExerciseSetEntity> _sets = [];
  Duration? _restTime;
  bool _restTimerActive = false;
  DateTime? _workoutStartTime;

  @override
  void initState() {
    super.initState();
    _workoutStartTime = DateTime.now();
  }

  @override
  void dispose() {
    _workoutNameController.dispose();
    super.dispose();
  }

  void _addSet() {
    setState(() {
      _sets.add(ExerciseSetEntity(
        id: const Uuid().v4(),
        workoutLogId: '',
        exerciseName: '',
        setNumber: _sets.length + 1,
        createdAt: DateTime.now(),
      ));
    });
  }

  void _startRestTimer() {
    setState(() {
      _restTime = const Duration(seconds: 90);
      _restTimerActive = true;
    });
  }

  Future<void> _saveWorkout() async {
    final authState = ref.read(authStateProvider);

    await authState.maybeWhen(
      authenticated: (user) async {
        if (_sets.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please add at least one set'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final workoutDuration =
            DateTime.now().difference(_workoutStartTime!).inSeconds;

        final workoutLog = WorkoutLogEntity(
          id: const Uuid().v4(),
          userId: user.id,
          timestamp: DateTime.now(),
          workoutName: _workoutNameController.text.isNotEmpty
              ? _workoutNameController.text
              : 'Workout ${DateTime.now().toString().substring(0, 10)}',
          duration: workoutDuration,
          sets: _sets,
          createdAt: DateTime.now(),
        );

        final result =
            await ref.read(workoutLogProvider.notifier).createWorkoutLog(
                  workoutLog,
                );

        result.when(
          success: (_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Workout logged successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            }
          },
          failure: (error) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${error.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        );
      },
      orElse: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please log in to save workout'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWorkout,
            tooltip: 'Save Workout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Workout name
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _workoutNameController,
              decoration: InputDecoration(
                labelText: 'Workout Name',
                hintText: 'e.g., Upper Body Day',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.fitness_center),
              ),
            ),
          ),

          // Rest Timer
          if (_restTimerActive)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: RestTimerWidget(
                duration: _restTime!,
                onComplete: () => setState(() => _restTimerActive = false),
                onStop: () => setState(() => _restTimerActive = false),
              ),
            ),

          // Exercise Sets List
          Expanded(
            child: _sets.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 64,
                          color: theme.colorScheme.primary.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No sets added yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tap "Add Set" to begin',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _sets.length,
                    itemBuilder: (context, index) {
                      return ExerciseSetInput(
                        set: _sets[index],
                        setNumber: index + 1,
                        onChanged: (updatedSet) {
                          setState(() {
                            _sets[index] = updatedSet;
                          });
                        },
                        onDelete: () {
                          setState(() {
                            _sets.removeAt(index);
                            // Renumber sets
                            for (int i = 0; i < _sets.length; i++) {
                              _sets[i] = _sets[i].copyWith(setNumber: i + 1);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),

          // Bottom action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add Set'),
                      onPressed: _addSet,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      icon: const Icon(Icons.timer),
                      label: const Text('Rest'),
                      onPressed: _restTimerActive ? null : _startRestTimer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
