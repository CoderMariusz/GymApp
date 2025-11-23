import 'package:flutter/material.dart';
import '../../domain/entities/workout_pattern.dart';

/// Card displaying smart workout suggestions with rationale
class SmartSuggestionCard extends StatelessWidget {
  final WorkoutSuggestion suggestion;
  final VoidCallback onApply;
  final VoidCallback? onDismiss;

  const SmartSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onApply,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: suggestion.isProgressiveOverload
          ? Colors.green.shade50
          : Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  suggestion.isProgressiveOverload
                      ? Icons.trending_up
                      : Icons.lightbulb_outline,
                  color: suggestion.isProgressiveOverload
                      ? Colors.green
                      : Colors.blue,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    suggestion.isProgressiveOverload
                        ? '🚀 Progressive Overload Suggested'
                        : '💡 Smart Suggestion',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (onDismiss != null)
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: onDismiss,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Rationale
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                suggestion.rationale,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 12),

            // Suggested sets preview
            Text(
              'Suggested workout:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            ...suggestion.sets.asMap().entries.map((entry) {
              final index = entry.key;
              final set = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Text(
                      'Set ${index + 1}:',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${set.weight.toStringAsFixed(1)}kg × ${set.reps} reps',
                    ),
                    if (set.targetRpe != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'RPE: ${set.targetRpe!.toStringAsFixed(1)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (set.note != null && index == 0) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          '(${set.note})',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDismiss,
                  child: const Text('Ignore'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.check),
                  label: const Text('Apply Suggestion'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: suggestion.isProgressiveOverload
                        ? Colors.green
                        : Colors.blue,
                    foregroundColor: Colors.white,
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
