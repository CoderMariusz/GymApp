import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/charts/widgets/line_chart_widget.dart';
import '../../../../core/charts/widgets/bar_chart_widget.dart';
import '../providers/fitness_charts_provider.dart';

class ProgressChartsPage extends ConsumerStatefulWidget {
  const ProgressChartsPage({super.key});

  @override
  ConsumerState<ProgressChartsPage> createState() => _ProgressChartsPageState();
}

class _ProgressChartsPageState extends ConsumerState<ProgressChartsPage> {
  String selectedExercise = 'Bench Press';

  @override
  Widget build(BuildContext context) {
    final strengthAsync = ref.watch(
      strengthProgressProvider(exercise: selectedExercise, weeks: 12),
    );
    final volumeAsync = ref.watch(weeklyVolumeProvider(weeks: 8));
    final prsAsync = ref.watch(personalRecordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness Progress'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise selector
            DropdownButton<String>(
              value: selectedExercise,
              items: ['Bench Press', 'Squat', 'Deadlift', 'Overhead Press']
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => selectedExercise = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // Strength chart (REUSABLE!)
            strengthAsync.when(
              data: (data) => ReusableLineChart(
                data: data,
                title: '$selectedExercise Strength (12 Weeks)',
                yAxisLabel: 'Max Weight (kg)',
                lineColor: Colors.red,
                showDots: true,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),

            // Volume chart (REUSABLE!)
            volumeAsync.when(
              data: (data) => ReusableBarChart(
                data: data,
                title: 'Weekly Volume (8 Weeks)',
                yAxisLabel: 'Total kg',
                barColor: Colors.purple,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
            const SizedBox(height: 24),

            // PRs chart (REUSABLE!)
            prsAsync.when(
              data: (data) => ReusableLineChart(
                data: data,
                title: 'Personal Records Timeline',
                yAxisLabel: 'Weight (kg)',
                lineColor: Colors.amber,
                showDots: true,
              ),
              loading: () => const CircularProgressIndicator(),
              error: (e, s) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
