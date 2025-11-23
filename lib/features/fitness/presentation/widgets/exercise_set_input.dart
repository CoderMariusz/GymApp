import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gymapp/features/fitness/domain/entities/exercise_set_entity.dart';

/// Widget for inputting exercise set data
class ExerciseSetInput extends StatefulWidget {
  final ExerciseSetEntity set;
  final int setNumber;
  final ValueChanged<ExerciseSetEntity> onChanged;
  final VoidCallback? onDelete;

  const ExerciseSetInput({
    super.key,
    required this.set,
    required this.setNumber,
    required this.onChanged,
    this.onDelete,
  });

  @override
  State<ExerciseSetInput> createState() => _ExerciseSetInputState();
}

class _ExerciseSetInputState extends State<ExerciseSetInput> {
  late TextEditingController _exerciseController;
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    _exerciseController = TextEditingController(text: widget.set.exerciseName);
    _weightController = TextEditingController(
      text: widget.set.weight?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.set.reps?.toString() ?? '',
    );

    _exerciseController.addListener(_notifyChanges);
    _weightController.addListener(_notifyChanges);
    _repsController.addListener(_notifyChanges);
  }

  @override
  void dispose() {
    _exerciseController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  void _notifyChanges() {
    widget.onChanged(
      widget.set.copyWith(
        exerciseName: _exerciseController.text,
        weight: double.tryParse(_weightController.text),
        reps: int.tryParse(_repsController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${widget.setNumber}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _exerciseController,
                    decoration: const InputDecoration(
                      labelText: 'Exercise',
                      hintText: 'e.g., Bench Press',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                if (widget.onDelete != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: widget.onDelete,
                    color: theme.colorScheme.error,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      hintText: '0.0',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d*\.?\d{0,2}'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      hintText: '0',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
