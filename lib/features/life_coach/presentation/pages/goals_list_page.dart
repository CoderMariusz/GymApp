import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gymapp/core/auth/presentation/providers/auth_provider.dart';
import 'package:gymapp/features/life_coach/presentation/providers/goals_provider.dart';
import 'package:gymapp/features/life_coach/presentation/pages/create_goal_page.dart';

class GoalsListPage extends ConsumerStatefulWidget {
  const GoalsListPage({super.key});

  @override
  ConsumerState<GoalsListPage> createState() => _GoalsListPageState();
}

class _GoalsListPageState extends ConsumerState<GoalsListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authStateProvider);
      authState.maybeWhen(
        authenticated: (user) {
          ref.read(goalsProvider.notifier).loadGoals(user.id, activeOnly: true);
        },
        orElse: () {},
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final goalsState = ref.watch(goalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Goals'),
        backgroundColor: theme.colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateGoalPage()),
            ),
          ),
        ],
      ),
      body: goalsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : goalsState.goals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.flag, size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      Text('No goals yet', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text('Create Your First Goal'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CreateGoalPage()),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: goalsState.goals.length,
                  itemBuilder: (context, index) {
                    final goal = goalsState.goals[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(goal.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (goal.description != null) ...[
                              const SizedBox(height: 4),
                              Text(goal.description ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                            ],
                            const SizedBox(height: 8),
                            if (goal.hasTarget) ...[
                              LinearProgressIndicator(
                                value: goal.progressPercentage / 100,
                                backgroundColor: theme.colorScheme.surfaceVariant,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${goal.progressPercentage.toStringAsFixed(0)}% - ${goal.formattedProgress}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.category, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(goal.category, style: theme.textTheme.bodySmall),
                                if (goal.targetDate != null) ...[
                                  const Spacer(),
                                  Icon(Icons.calendar_today, size: 14,
                                      color: goal.isOverdue ? Colors.red : Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat.MMMd().format(goal.targetDate ?? DateTime.now()),
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: goal.isOverdue ? Colors.red : null,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                            const PopupMenuItem(value: 'delete', child: Text('Delete')),
                          ],
                          onSelected: (value) async {
                            if (value == 'delete') {
                              await ref.read(goalsProvider.notifier).deleteGoal(goal.id);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
