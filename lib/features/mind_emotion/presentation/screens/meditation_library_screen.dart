import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/features/mind_emotion/domain/entities/meditation_entity.dart';
import 'package:lifeos/features/mind_emotion/presentation/providers/meditation_providers.dart';
import 'package:lifeos/features/mind_emotion/presentation/widgets/meditation_card.dart';
import 'package:lifeos/features/mind_emotion/presentation/widgets/category_tabs.dart';
import 'package:lifeos/features/mind_emotion/presentation/widgets/search_bar_widget.dart';

/// Main screen for meditation library
class MeditationLibraryScreen extends ConsumerStatefulWidget {
  const MeditationLibraryScreen({super.key});

  @override
  ConsumerState<MeditationLibraryScreen> createState() =>
      _MeditationLibraryScreenState();
}

class _MeditationLibraryScreenState
    extends ConsumerState<MeditationLibraryScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    final meditationsAsync = ref.watch(filteredMeditationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditation Library'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          const SearchBarWidget(),
          const SizedBox(height: 8),

          // Category tabs
          const CategoryTabs(),
          const SizedBox(height: 8),

          // Filter chips
          _buildFilterChips(),

          // Meditations list/grid
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(filteredMeditationsProvider);
              },
              child: meditationsAsync.when(
                data: (meditations) {
                  if (meditations.isEmpty) {
                    return _buildEmptyState();
                  }

                  return _isGridView
                      ? _buildGridView(meditations)
                      : _buildListView(meditations);
                },
                loading: () => _buildLoadingState(),
                error: (error, stack) => _buildErrorState(error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 8,
        children: [
          // Duration filters
          _buildDurationChip('5-10 min', 300, 600),
          _buildDurationChip('10-15 min', 600, 900),
          _buildDurationChip('15-20 min', 900, 1200),

          // Favorites filter
          Consumer(
            builder: (context, ref, child) {
              final favoritesOnly = ref.watch(favoritesOnlyProvider);
              return FilterChip(
                label: const Text('Favorites'),
                selected: favoritesOnly,
                onSelected: (selected) {
                  ref.read(favoritesOnlyProvider.notifier).state = selected;
                },
              );
            },
          ),

          // Clear filters button
          TextButton.icon(
            icon: const Icon(Icons.clear),
            label: const Text('Clear'),
            onPressed: () {
              ref.read(selectedCategoryProvider.notifier).state = null;
              ref.read(searchQueryProvider.notifier).state = '';
              ref.read(minDurationProvider.notifier).state = null;
              ref.read(maxDurationProvider.notifier).state = null;
              ref.read(favoritesOnlyProvider.notifier).state = false;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDurationChip(String label, int minSeconds, int maxSeconds) {
    return Consumer(
      builder: (context, ref, child) {
        final minDuration = ref.watch(minDurationProvider);
        final maxDuration = ref.watch(maxDurationProvider);
        final isSelected =
            minDuration == minSeconds && maxDuration == maxSeconds;

        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              ref.read(minDurationProvider.notifier).state = minSeconds;
              ref.read(maxDurationProvider.notifier).state = maxSeconds;
            } else {
              ref.read(minDurationProvider.notifier).state = null;
              ref.read(maxDurationProvider.notifier).state = null;
            }
          },
        );
      },
    );
  }

  Widget _buildGridView(List<MeditationEntity> meditations) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: meditations.length,
      itemBuilder: (context, index) {
        return MeditationCard(
          meditation: meditations[index],
          isGridView: true,
        );
      },
    );
  }

  Widget _buildListView(List<MeditationEntity> meditations) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: meditations.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: MeditationCard(
            meditation: meditations[index],
            isGridView: false,
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading meditations...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.self_improvement,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No meditations found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading meditations',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(filteredMeditationsProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
