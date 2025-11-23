import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:gymapp/core/auth/presentation/providers/auth_provider.dart';
import 'package:gymapp/core/widgets/daily_input_form.dart';
import 'package:gymapp/features/fitness/presentation/providers/measurements_provider.dart';
import 'package:gymapp/features/fitness/domain/entities/body_measurement_entity.dart';

class MeasurementsPage extends ConsumerStatefulWidget {
  const MeasurementsPage({super.key});

  @override
  ConsumerState<MeasurementsPage> createState() => _MeasurementsPageState();
}

class _MeasurementsPageState extends ConsumerState<MeasurementsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authStateProvider);
      authState.maybeWhen(
        authenticated: (user) => ref.read(measurementsProvider.notifier).loadHistory(user.id, limit: 20),
        orElse: () {},
      );
    });
  }

  void _showAddDialog(BuildContext context) {
    final authState = ref.read(authStateProvider);
    authState.maybeWhen(
      authenticated: (user) {
        showDialog(
          context: context,
          builder: (context) => Dialog(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DailyInputForm(
                fields: [
                  FormFieldConfig(
                    label: 'Weight (kg)',
                    hint: '70.5',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  FormFieldConfig(
                    label: 'Body Fat (%)',
                    hint: '15.5',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  FormFieldConfig(
                    label: 'Muscle Mass (kg)',
                    hint: '60.0',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  FormFieldConfig(label: 'Notes', hint: 'Optional notes', maxLines: 2),
                ],
                showTimePicker: false,
                submitText: 'Record',
                onSubmit: (data) async {
                  final measurement = BodyMeasurementEntity(
                    id: const Uuid().v4(),
                    userId: user.id,
                    timestamp: DateTime.now(),
                    weight: double.tryParse(data['Weight (kg)'] as String? ?? ''),
                    bodyFat: double.tryParse(data['Body Fat (%)'] as String? ?? ''),
                    muscleMass: double.tryParse(data['Muscle Mass (kg)'] as String? ?? ''),
                    notes: data['Notes'] as String?,
                    createdAt: DateTime.now(),
                  );

                  final result = await ref.read(measurementsProvider.notifier).recordMeasurement(measurement);
                  result.when(
                    success: (_) {
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Measurement recorded!'), backgroundColor: Colors.green),
                        );
                      }
                    },
                    failure: (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $error'), backgroundColor: Colors.red),
                        );
                      }
                    },
                  );
                },
                onCancel: () => Navigator.pop(context),
              ),
            ),
          ),
        );
      },
      orElse: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(measurementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Measurements'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddDialog(context)),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.measurements.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.straighten, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text('No measurements yet'),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Add First Measurement'),
                        onPressed: () => _showAddDialog(context),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.measurements.length,
                  itemBuilder: (context, index) {
                    final m = state.measurements[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(DateFormat.yMMMd().format(m.timestamp)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (m.weight != null) Text('Weight: ${m.weight!.toStringAsFixed(1)} kg'),
                            if (m.bodyFat != null) Text('Body Fat: ${m.bodyFat!.toStringAsFixed(1)}%'),
                            if (m.muscleMass != null) Text('Muscle: ${m.muscleMass!.toStringAsFixed(1)} kg'),
                            if (m.notes != null) Text(m.notes!, style: theme.textTheme.bodySmall),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
