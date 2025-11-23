import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/goal_suggestion_provider.dart';
import '../widgets/goal_suggestion_card.dart';

class GoalSuggestionsPage extends ConsumerWidget {
  const GoalSuggestionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestionsAsync = ref.watch(goalSuggestionsNotifierProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Goal Suggestions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(goalSuggestionsNotifierProvider().notifier).refresh();
            },
            tooltip: 'Get New Suggestions',
          ),
        ],
      ),
      body: suggestionsAsync.when(
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(context, ref, error),
        data: (suggestions) {
          if (suggestions.isEmpty) {
            return _buildEmptyState(context, ref);
          }
          return _buildSuggestionsList(context, ref, suggestions);
        },
      ),
    );
  }

  Widget _buildSuggestionsList(
    BuildContext context,
    WidgetRef ref,
    List suggestions,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: suggestions.length + 1,  // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personalized Goals',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'These goals are suggested based on your profile, preferences, and current goals.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                ),
              ],
            ),
          );
        }

        final suggestion = suggestions[index - 1];
        return GoalSuggestionCard(
          suggestion: suggestion,
          onAccept: () => _acceptGoal(context, ref, suggestion),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Get AI Goal Suggestions',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Let AI analyze your profile and suggest personalized goals',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(goalSuggestionsNotifierProvider().notifier).generateSuggestions();
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate Suggestions'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(strokeWidth: 6),
          ),
          SizedBox(height: 24),
          Text(
            'AI is analyzing your profile...',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8),
          Text(
            'Generating personalized goals',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Failed to generate suggestions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                ref.read(goalSuggestionsNotifierProvider().notifier).generateSuggestions();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _acceptGoal(BuildContext context, WidgetRef ref, dynamic suggestion) {
    // TODO: Implement goal creation
    // For now, just show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Goal "${suggestion.title}" will be added when Stories 2.1/2.3 are implemented'),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
