import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:lifeos/core/auth/presentation/providers/auth_provider.dart';
import 'package:lifeos/core/widgets/daily_input_form.dart';
import 'package:lifeos/features/life_coach/presentation/providers/goals_provider.dart';
import 'package:lifeos/features/life_coach/domain/entities/goal_entity.dart';

class CreateGoalPage extends ConsumerWidget {
  const CreateGoalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Goal'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: authState.maybeMap(
        authenticated: (authenticated) => DailyInputForm(
          fields: [
            FormFieldConfig(
              label: 'Goal Title',
              hint: 'e.g., Lose 10kg',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            FormFieldConfig(
              label: 'Description',
              hint: 'What do you want to achieve?',
              maxLines: 3,
            ),
            FormFieldConfig(
              label: 'Category',
              hint: 'e.g., Fitness, Career, Health',
              validator: (value) => value?.isEmpty == true ? 'Required' : null,
            ),
            FormFieldConfig(
              label: 'Target Value',
              hint: 'e.g., 70',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            FormFieldConfig(
              label: 'Unit',
              hint: 'e.g., kg, reps, days',
            ),
            FormFieldConfig(
              label: 'Priority (1-5)',
              hint: '1 = Low, 5 = High',
              keyboardType: TextInputType.number,
            ),
          ],
          showTimePicker: false,
          submitText: 'Create Goal',
          onSubmit: (data) async {
            final goal = GoalEntity(
              id: const Uuid().v4(),
              userId: authenticated.user.id,
              title: data['Goal Title'] as String,
              description: data['Description'] as String?,
              category: data['Category'] as String,
              targetValue: double.tryParse(data['Target Value'] as String? ?? '0'),
              unit: data['Unit'] as String?,
              priority: int.tryParse(data['Priority (1-5)'] as String? ?? '1') ?? 1,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

            final result = await ref.read(goalsProvider.notifier).createGoal(goal);

            result.map(
              success: (success) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Goal created!'), backgroundColor: Colors.green),
                  );
                  Navigator.pop(context);
                }
              },
              failure: (failure) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: ${failure.exception}'), backgroundColor: Colors.red),
                  );
                }
              },
            );
          },
          onCancel: () => Navigator.pop(context),
        ),
        orElse: () => const Center(child: Text('Please log in')),
      ),
    );
  }
}
