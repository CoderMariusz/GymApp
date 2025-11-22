// Story 3.2: Exercise Search Bar Widget
// AC3: Search bar with real-time filtering (<200ms)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/exercise_providers.dart';

class ExerciseSearchBar extends ConsumerStatefulWidget {
  const ExerciseSearchBar({super.key});

  @override
  ConsumerState<ExerciseSearchBar> createState() => _ExerciseSearchBarState();
}

class _ExerciseSearchBarState extends ConsumerState<ExerciseSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
        onChanged: (value) {
          // AC3: Real-time filtering
          // Updates search query provider which triggers filtered list update
          ref.read(searchQueryProvider.notifier).state = value;
        },
      ),
    );
  }
}
