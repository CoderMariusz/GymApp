import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/workout_log.dart';
import '../../domain/entities/workout_pattern.dart';
import '../providers/smart_prefill_provider.dart';
import '../widgets/smart_suggestion_card.dart';

/// Page for logging a workout with smart prefill suggestions
class WorkoutLogPage extends ConsumerStatefulWidget {
  final String? preselectedExercise;

  const WorkoutLogPage({
    super.key,
    this.preselectedExercise,
  });

  @override
  ConsumerState<WorkoutLogPage> createState() => _WorkoutLogPageState();
}

class _WorkoutLogPageState extends ConsumerState<WorkoutLogPage> {
  // Common exercises for the dropdown
  final List<String> exercises = [
    'Bench Press',
    'Squat',
    'Deadlift',
    'Overhead Press',
    'Barbell Row',
    'Pull-ups',
    'Dips',
    'Leg Press',
  ];

  String? selectedExercise;
  final List<_SetData> sets = [];
  bool showSuggestion = false;
  bool suggestionDismissed = false;

  @override
  void initState() {
    super.initState();
    selectedExercise = widget.preselectedExercise ?? exercises.first;
    _addEmptySet();
  }

  void _addEmptySet() {
    setState(() {
      sets.add(_SetData());
    });
  }

  void _removeSet(int index) {
    if (sets.length > 1) {
      setState(() {
        sets.removeAt(index);
      });
    }
  }

  void _applySuggestion(WorkoutSuggestion suggestion) {
    setState(() {
      sets.clear();
      for (final suggestedSet in suggestion.sets) {
        sets.add(_SetData(
          weight: suggestedSet.weight.toString(),
          reps: suggestedSet.reps.toString(),
          restSeconds: suggestedSet.restSeconds.toString(),
          rpe: suggestedSet.targetRpe?.toStringAsFixed(1),
        ));
      }
      suggestionDismissed = true;
      showSuggestion = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Suggestion applied! Adjust as needed.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _saveWorkout() async {
    if (selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an exercise')),
      );
      return;
    }

    // Validate that at least one set has data
    final validSets = sets.where((s) =>
        s.weight.isNotEmpty && s.reps.isNotEmpty).toList();

    if (validSets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log at least one set')),
      );
      return;
    }

    // Here you would save to repository
    // For now, just show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅ Logged ${validSets.length} sets of $selectedExercise',
        ),
        backgroundColor: Colors.green,
      ),
    );

    // Optional: Navigate back or clear form
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasPatternAsync = selectedExercise != null
        ? ref.watch(hasPatternDataProvider(exerciseName: selectedExercise!))
        : null;

    final suggestionAsync = selectedExercise != null && showSuggestion
        ? ref.watch(workoutSuggestionProvider(exerciseName: selectedExercise!))
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveWorkout,
            tooltip: 'Save Workout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise selector
            Text(
              'Exercise',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedExercise,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
              items: exercises.map((exercise) {
                return DropdownMenuItem(
                  value: exercise,
                  child: Text(exercise),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedExercise = value;
                  showSuggestion = false;
                  suggestionDismissed = false;
                });
              },
            ),
            const SizedBox(height: 16),

            // Smart suggestion button
            if (hasPatternAsync != null)
              hasPatternAsync.when(
                data: (hasPattern) {
                  if (!hasPattern) {
                    return Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Log this exercise a few times to unlock smart suggestions!',
                                style: TextStyle(color: Colors.blue.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (suggestionDismissed) {
                    return const SizedBox.shrink();
                  }

                  if (!showSuggestion) {
                    return ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          showSuggestion = true;
                        });
                      },
                      icon: const Icon(Icons.psychology),
                      label: const Text('Get Smart Suggestion'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),

            // Smart suggestion card
            if (suggestionAsync != null && !suggestionDismissed)
              suggestionAsync.when(
                data: (suggestion) {
                  if (suggestion == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: SmartSuggestionCard(
                      suggestion: suggestion,
                      onApply: () => _applySuggestion(suggestion),
                      onDismiss: () {
                        setState(() {
                          showSuggestion = false;
                          suggestionDismissed = true;
                        });
                      },
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text('Error loading suggestion: $e'),
                ),
              ),

            const SizedBox(height: 24),

            // Sets section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sets',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: _addEmptySet,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Set'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Set entries
            ...sets.asMap().entries.map((entry) {
              final index = entry.key;
              final setData = entry.value;
              return _SetEntry(
                setNumber: index + 1,
                data: setData,
                onRemove: sets.length > 1 ? () => _removeSet(index) : null,
              );
            }),

            const SizedBox(height: 24),

            // Save button
            ElevatedButton(
              onPressed: _saveWorkout,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Save Workout',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Data holder for a single set
class _SetData {
  String weight;
  String reps;
  String restSeconds;
  String? rpe;

  _SetData({
    this.weight = '',
    this.reps = '',
    this.restSeconds = '120',
    this.rpe,
  });
}

/// Widget for entering a single set's data
class _SetEntry extends StatelessWidget {
  final int setNumber;
  final _SetData data;
  final VoidCallback? onRemove;

  const _SetEntry({
    required this.setNumber,
    required this.data,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Set $setNumber',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: onRemove,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                // Weight
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: TextEditingController(text: data.weight)
                      ..selection = TextSelection.collapsed(
                        offset: data.weight.length,
                      ),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) => data.weight = value,
                  ),
                ),
                const SizedBox(width: 8),

                // Reps
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: TextEditingController(text: data.reps)
                      ..selection = TextSelection.collapsed(
                        offset: data.reps.length,
                      ),
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (value) => data.reps = value,
                  ),
                ),
                const SizedBox(width: 8),

                // RPE
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: TextEditingController(text: data.rpe ?? '')
                      ..selection = TextSelection.collapsed(
                        offset: (data.rpe ?? '').length,
                      ),
                    decoration: const InputDecoration(
                      labelText: 'RPE',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    onChanged: (value) => data.rpe = value.isEmpty ? null : value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Rest seconds
            TextField(
              controller: TextEditingController(text: data.restSeconds)
                ..selection = TextSelection.collapsed(
                  offset: data.restSeconds.length,
                ),
              decoration: const InputDecoration(
                labelText: 'Rest (seconds)',
                border: OutlineInputBorder(),
                isDense: true,
                prefixIcon: Icon(Icons.timer, size: 20),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) => data.restSeconds = value,
            ),
          ],
        ),
      ),
    );
  }
}
