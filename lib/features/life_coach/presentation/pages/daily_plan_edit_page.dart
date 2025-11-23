import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ai/models/daily_plan.dart';
import '../../ai/models/plan_task.dart';
import '../../ai/providers/daily_plan_provider.dart';
import '../widgets/task_edit_dialog.dart';

/// Page for manually editing a daily plan with drag & drop reordering
class DailyPlanEditPage extends ConsumerWidget {
  final DailyPlan plan;

  const DailyPlanEditPage({
    super.key,
    required this.plan,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Plan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddTaskDialog(context, ref),
            tooltip: 'Add Task',
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Drag tasks to reorder. Tap to edit. Swipe to delete.',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
              ],
            ),
          ),

          // Source indicator
          if (plan.source != PlanSource.ai)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              color: Colors.orange.shade50,
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'This plan has been manually edited',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),

          // Reorderable task list
          Expanded(
            child: plan.tasks.isEmpty
                ? _buildEmptyState(context, ref)
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: plan.tasks.length,
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(dailyPlanNotifierProvider().notifier)
                          .reorderTasks(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      final task = plan.tasks[index];
                      return _buildTaskCard(context, ref, task, index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    WidgetRef ref,
    PlanTask task,
    int index,
  ) {
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: Text('Delete "${task.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        ref.read(dailyPlanNotifierProvider().notifier).deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${task.title}"')),
        );
      },
      child: Card(
        key: Key('card_${task.id}'),
        margin: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () => _showEditTaskDialog(context, ref, task),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Drag handle
                ReorderableDragStartListener(
                  index: index,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.drag_handle, color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),

                // Task content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildChip(
                            Icons.schedule,
                            task.suggestedTime,
                            Colors.blue,
                          ),
                          _buildChip(
                            Icons.access_time,
                            '${task.estimatedDuration} min',
                            Colors.green,
                          ),
                          _buildChip(
                            _getCategoryIcon(task.category),
                            task.category.name,
                            _getCategoryColor(task.category),
                          ),
                          _buildChip(
                            Icons.flag,
                            task.priority.name,
                            _getPriorityColor(task.priority),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Edit icon
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showEditTaskDialog(context, ref, task),
                  tooltip: 'Edit',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No tasks yet'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddTaskDialog(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Add First Task'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddTaskDialog(BuildContext context, WidgetRef ref) async {
    final task = await showDialog<PlanTask>(
      context: context,
      builder: (context) => const TaskEditDialog(),
    );

    if (task != null) {
      ref.read(dailyPlanNotifierProvider().notifier).addTask(task);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Added "${task.title}"')),
        );
      }
    }
  }

  Future<void> _showEditTaskDialog(
    BuildContext context,
    WidgetRef ref,
    PlanTask task,
  ) async {
    final updatedTask = await showDialog<PlanTask>(
      context: context,
      builder: (context) => TaskEditDialog(task: task),
    );

    if (updatedTask != null) {
      ref.read(dailyPlanNotifierProvider().notifier).editTask(updatedTask);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Updated "${updatedTask.title}"')),
        );
      }
    }
  }

  IconData _getCategoryIcon(TaskCategory category) {
    switch (category) {
      case TaskCategory.fitness:
        return Icons.fitness_center;
      case TaskCategory.productivity:
        return Icons.work;
      case TaskCategory.wellness:
        return Icons.spa;
      case TaskCategory.personal:
        return Icons.person;
      case TaskCategory.social:
        return Icons.people;
    }
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

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }
}
