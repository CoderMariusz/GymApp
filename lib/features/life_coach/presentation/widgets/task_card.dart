import 'package:flutter/material.dart';
import '../../ai/models/plan_task.dart';

class TaskCard extends StatelessWidget {
  final PlanTask task;
  final VoidCallback onComplete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: task.isCompleted ? null : (_) => onComplete(),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(task.description),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _Chip(
                  icon: Icons.access_time,
                  label: '${task.estimatedDuration} min',
                ),
                _Chip(
                  icon: Icons.schedule,
                  label: task.suggestedTime,
                ),
                _Chip(
                  icon: Icons.category,
                  label: task.category.name,
                  color: _getCategoryColor(task.category),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.lightbulb_outline, size: 16),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    task.why,
                    style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Color _getCategoryColor(TaskCategory category) {
    switch (category) {
      case TaskCategory.fitness:
        return Colors.red;
      case TaskCategory.productivity:
        return Colors.blue;
      case TaskCategory.wellness:
        return Colors.green;
      case TaskCategory.personal:
        return Colors.purple;
      case TaskCategory.social:
        return Colors.orange;
    }
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _Chip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }
}
