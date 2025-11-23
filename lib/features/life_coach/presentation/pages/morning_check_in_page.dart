import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:gymapp/core/widgets/daily_input_form.dart';
import 'package:gymapp/core/auth/presentation/providers/auth_provider.dart';
import 'package:gymapp/features/life_coach/presentation/providers/check_in_provider.dart';
import 'package:gymapp/features/life_coach/domain/entities/check_in_entity.dart';

/// Morning Check-In Page
/// Story 2.1: Allows users to set daily intentions and track morning energy
class MorningCheckInPage extends ConsumerWidget {
  const MorningCheckInPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Morning Check-In'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: authState.maybeWhen(
        authenticated: (user) => DailyInputForm(
          fields: [
            FormFieldConfig(
              label: 'Today\'s Intentions',
              hint: 'What are your top 3 goals for today?',
              maxLines: 3,
              validator: (value) => value?.isEmpty == true
                  ? 'Please enter your intentions'
                  : null,
            ),
            FormFieldConfig(
              label: 'Gratitude',
              hint: 'What are you grateful for today?',
              maxLines: 2,
            ),
          ],
          showTimePicker: true,
          showMoodSlider: true,
          moodLabel: 'Energy Level',
          showTags: true,
          availableTags: const [
            'Work',
            'Exercise',
            'Learning',
            'Family',
            'Rest',
            'Social',
          ],
          submitText: 'Save Check-In',
          onSubmit: (data) async {
            final checkIn = CheckInEntity(
              id: const Uuid().v4(),
              userId: user.id,
              type: CheckInType.morning,
              timestamp: DateTime.now(),
              energyLevel: data['mood'] as int?,
              intentions: data['Today\'s Intentions'] as String?,
              gratitude: data['Gratitude'] as String?,
              tags: data['tags'] as List<String>?,
              createdAt: DateTime.now(),
            );

            final result = await ref
                .read(checkInProvider.notifier)
                .createMorningCheckIn(checkIn);

            result.when(
              success: (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Morning check-in saved!'),
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
          child: Text('Please log in to create a check-in'),
        ),
      ),
    );
  }
}
