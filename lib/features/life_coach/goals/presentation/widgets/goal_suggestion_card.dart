import 'package:flutter/material.dart';
import '../../models/goal_suggestion.dart';

class GoalSuggestionCard extends StatelessWidget {
  final GoalSuggestion suggestion;
  final VoidCallback onAccept;

  const GoalSuggestionCard({
    super.key,
    required this.suggestion,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(suggestion.category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    suggestion.category.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(suggestion.category),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${suggestion.estimatedDays} days',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              suggestion.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              suggestion.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),

            // Why
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggestion.why,
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Action Plan
            Text(
              'Action Plan:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            Text(
              suggestion.actionPlan,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),

            // Milestones
            if (suggestion.milestones.isNotEmpty) ...[
              Text(
                'Milestones:',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              ...suggestion.milestones.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            const SizedBox(height: 16),

            // Accept button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onAccept,
                icon: const Icon(Icons.add_task),
                label: const Text('Add This Goal'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(category) {
    switch (category.toString()) {
      case 'GoalCategory.fitness':
        return Colors.red;
      case 'GoalCategory.health':
        return Colors.green;
      case 'GoalCategory.career':
        return Colors.blue;
      case 'GoalCategory.personal':
        return Colors.purple;
      case 'GoalCategory.social':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
