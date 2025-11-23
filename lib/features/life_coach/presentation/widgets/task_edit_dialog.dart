import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../ai/models/plan_task.dart';
import 'package:uuid/uuid.dart';

/// Dialog for editing or creating a task
class TaskEditDialog extends StatefulWidget {
  final PlanTask? task; // null means creating new task

  const TaskEditDialog({super.key, this.task});

  @override
  State<TaskEditDialog> createState() => _TaskEditDialogState();
}

class _TaskEditDialogState extends State<TaskEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _whyController;
  late TextEditingController _durationController;
  late TimeOfDay _suggestedTime;

  TaskCategory _category = TaskCategory.productivity;
  TaskPriority _priority = TaskPriority.medium;
  EnergyLevel _energyLevel = EnergyLevel.medium;

  @override
  void initState() {
    super.initState();

    final task = widget.task;
    if (task != null) {
      // Editing existing task - no force unwraps needed
      _titleController = TextEditingController(text: task.title);
      _descriptionController = TextEditingController(text: task.description);
      _whyController = TextEditingController(text: task.why);
      _durationController = TextEditingController(
        text: task.estimatedDuration.toString(),
      );
      _category = task.category;
      _priority = task.priority;
      _energyLevel = task.energyLevel;

      // Parse suggested time with error handling
      final parts = task.suggestedTime.split(':');
      if (parts.length == 2) {
        final hour = int.tryParse(parts[0]);
        final minute = int.tryParse(parts[1]);
        if (hour != null && minute != null && hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
          _suggestedTime = TimeOfDay(hour: hour, minute: minute);
        } else {
          _suggestedTime = TimeOfDay.now();
        }
      } else {
        _suggestedTime = TimeOfDay.now();
      }
    } else {
      // Creating new task
      _titleController = TextEditingController();
      _descriptionController = TextEditingController();
      _whyController = TextEditingController();
      _durationController = TextEditingController(text: '30');
      _suggestedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _whyController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _save() {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    final task = PlanTask(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category,
      priority: _priority,
      estimatedDuration: int.tryParse(_durationController.text) ?? 30,
      suggestedTime: '${_suggestedTime.hour.toString().padLeft(2, '0')}:'
          '${_suggestedTime.minute.toString().padLeft(2, '0')}',
      energyLevel: _energyLevel,
      why: _whyController.text.trim().isEmpty
          ? 'Manually added task'
          : _whyController.text.trim(),
      isCompleted: widget.task?.isCompleted ?? false,
      completedAt: widget.task?.completedAt,
    );

    Navigator.of(context).pop(task);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Task Title *',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Description
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Why
              TextField(
                controller: _whyController,
                decoration: const InputDecoration(
                  labelText: 'Why is this important?',
                  border: OutlineInputBorder(),
                  hintText: 'Motivational reason...',
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<TaskCategory>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: TaskCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(_getCategoryIcon(cat), size: 18),
                        const SizedBox(width: 8),
                        Text(cat.name[0].toUpperCase() + cat.name.substring(1)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _category = value);
                  }
                },
              ),
              const SizedBox(height: 16),

              // Priority and Energy Level (Row)
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<TaskPriority>(
                      value: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Priority',
                        border: OutlineInputBorder(),
                      ),
                      items: TaskPriority.values.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(p.name[0].toUpperCase() + p.name.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _priority = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<EnergyLevel>(
                      value: _energyLevel,
                      decoration: const InputDecoration(
                        labelText: 'Energy',
                        border: OutlineInputBorder(),
                      ),
                      items: EnergyLevel.values.map((e) {
                        return DropdownMenuItem(
                          value: e,
                          child: Text(e.name[0].toUpperCase() + e.name.substring(1)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _energyLevel = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Duration and Time (Row)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _durationController,
                      decoration: const InputDecoration(
                        labelText: 'Duration (min)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: _suggestedTime,
                        );
                        if (time != null) {
                          setState(() => _suggestedTime = time);
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Suggested Time',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _suggestedTime.format(context),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Save'),
        ),
      ],
    );
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
}
