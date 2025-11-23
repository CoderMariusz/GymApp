import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/core/auth/presentation/providers/auth_provider.dart';
import 'package:lifeos/core/auth/presentation/providers/auth_state.dart';
import 'package:lifeos/features/fitness/presentation/providers/templates_provider.dart';

class TemplatesPage extends ConsumerWidget {
  const TemplatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final preBuilt = ref.watch(templatesProvider);
    final authState = ref.watch(authStateProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Workout Templates'),
          backgroundColor: theme.colorScheme.primaryContainer,
          bottom: const TabBar(tabs: [Tab(text: 'Pre-Built'), Tab(text: 'My Templates')]),
        ),
        body: TabBarView(
          children: [
            preBuilt.when(
              data: (templates) => templates.isEmpty
                  ? const Center(child: Text('No pre-built templates'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: templates.length,
                      itemBuilder: (context, index) {
                        final t = templates[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (t.description != null) Text(t.description!),
                                const SizedBox(height: 4),
                                Text('${t.difficulty} • ${t.estimatedDuration} min • ${t.category}',
                                    style: theme.textTheme.bodySmall),
                              ],
                            ),
                            trailing: Icon(t.isFavorite ? Icons.favorite : Icons.favorite_border),
                          ),
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Center(child: Text('Error loading templates')),
            ),
            authState.maybeWhen(
              authenticated: (user) {
                final userTemplates = ref.watch(userTemplatesProvider(user.id));
                return userTemplates.when(
                  data: (templates) => templates.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fitness_center,
                                  size: 64, color: theme.colorScheme.primary.withOpacity(0.5)),
                              const SizedBox(height: 16),
                              const Text('No custom templates yet'),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: templates.length,
                          itemBuilder: (context, index) {
                            final t = templates[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(t.name),
                                subtitle: Text('${t.exercises.length} exercises'),
                              ),
                            );
                          },
                        ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Center(child: Text('Error')),
                );
              },
              orElse: () => const Center(child: Text('Please log in')),
            ),
          ],
        ),
      ),
    );
  }
}
