import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:gymapp/core/widgets/daily_input_form.dart';
import 'package:gymapp/core/auth/presentation/providers/auth_provider.dart';
import 'package:gymapp/features/life_coach/presentation/providers/check_in_provider.dart';
import 'package:gymapp/features/life_coach/domain/entities/check_in_entity.dart';

/// Evening Reflection Page
/// Story 2.5: Allows users to reflect on their day and plan for tomorrow
class EveningReflectionPage extends ConsumerWidget {
  const EveningReflectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evening Reflection'),
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      ),
      body: authState.maybeWhen(
        authenticated: (user) => DailyInputForm(
          fields: [
            FormFieldConfig(
              label: 'Today\'s Wins',
              hint: 'What went well today?',
              maxLines: 3,
            ),
            FormFieldConfig(
              label: 'Areas to Improve',
              hint: 'What could you do better tomorrow?',
              maxLines: 2,
            ),
            FormFieldConfig(
              label: 'Tomorrow\'s Focus',
              hint: 'What\'s your main priority for tomorrow?',
              maxLines: 2,
            ),
          ],
          showTimePicker: false,
          showMoodSlider: true,
          moodLabel: 'Productivity Rating',
          showTags: false,
          submitText: 'Save Reflection',
          onSubmit: (data) async {
            final reflection = CheckInEntity(
              id: const Uuid().v4(),
              userId: user.id,
              type: CheckInType.evening,
              timestamp: DateTime.now(),
              productivityRating: data['mood'] as int?,
              wins: data['Today\'s Wins'] as String?,
              improvements: data['Areas to Improve'] as String?,
              tomorrowFocus: data['Tomorrow\'s Focus'] as String?,
              createdAt: DateTime.now(),
            );

            final result = await ref
                .read(checkInProvider.notifier)
                .createEveningReflection(reflection);

            result.when(
              success: (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Evening reflection saved!'),
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
          onCancel: () => Navigator.pop(context),
        ),
        orElse: () => const Center(
          child: Text('Please log in to create a reflection'),
        ),
      ),
    );
  }
}
