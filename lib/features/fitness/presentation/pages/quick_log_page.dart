import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:lifeos/core/widgets/daily_input_form.dart';
import 'package:lifeos/core/auth/presentation/providers/auth_provider.dart';
import 'package:lifeos/features/fitness/presentation/providers/workout_log_provider.dart';
import 'package:lifeos/features/fitness/domain/entities/workout_log_entity.dart';
import 'package:lifeos/features/fitness/domain/entities/exercise_set_entity.dart';

/// Quick Log Page
/// Story 3.8: Simplified workout logging for fast entry
class QuickLogPage extends ConsumerWidget {
  const QuickLogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Log'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: authState.maybeMap(
        authenticated: (authenticated) => DailyInputForm(
          fields: [
            FormFieldConfig(
              label: 'Exercise Name',
              hint: 'e.g., Bench Press',
              validator: (value) =>
                  value?.isEmpty == true ? 'Required' : null,
            ),
            FormFieldConfig(
              label: 'Sets',
              hint: 'Number of sets',
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value?.isEmpty == true ? 'Required' : null,
            ),
            FormFieldConfig(
              label: 'Reps',
              hint: 'Reps per set',
              keyboardType: TextInputType.number,
            ),
            FormFieldConfig(
              label: 'Weight (kg)',
              hint: 'Weight used',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
          ],
          showTimePicker: true,
          submitText: 'Log Exercise',
          onSubmit: (data) async {
            final sets = int.tryParse(data['Sets'] as String? ?? '1') ?? 1;
            final weight =
                double.tryParse(data['Weight (kg)'] as String? ?? '0') ?? 0.0;
            final reps = int.tryParse(data['Reps'] as String? ?? '0') ?? 0;
            final exerciseName = data['Exercise Name'] as String;

            // Create sets
            final exerciseSets = List.generate(
              sets,
              (index) => ExerciseSetEntity(
                id: const Uuid().v4(),
                workoutLogId: '',
                exerciseName: exerciseName,
                setNumber: index + 1,
                weight: weight > 0 ? weight : null,
                reps: reps > 0 ? reps : null,
                createdAt: DateTime.now(),
              ),
            );

            final quickLog = WorkoutLogEntity(
              id: const Uuid().v4(),
              userId: authenticated.user.id,
              timestamp: data['time'] as DateTime? ?? DateTime.now(),
              workoutName: exerciseName,
              duration: 0,
              isQuickLog: true,
              sets: exerciseSets,
              createdAt: DateTime.now(),
            );

            final result = await ref
                .read(workoutLogProvider.notifier)
                .quickLogWorkout(quickLog);

            result.map(
              success: (success) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Workout logged!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              failure: (failure) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${failure.exception.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            );
          },
          onCancel: () => Navigator.pop(context),
        ),
        orElse: () => const Center(
          child: Text('Please log in to log a workout'),
        ),
      ),
    );
  }
}
