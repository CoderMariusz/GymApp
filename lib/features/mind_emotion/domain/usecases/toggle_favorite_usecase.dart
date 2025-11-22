import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/mind_emotion/domain/repositories/meditation_repository.dart';

/// Use case for toggling meditation favorite status
class ToggleFavoriteUseCase {
  final MeditationRepository _repository;

  ToggleFavoriteUseCase({required MeditationRepository repository})
      : _repository = repository;

  /// Toggle favorite status for a meditation
  ///
  /// Returns Result<bool> where bool is the new favorite state (true/false)
  /// Saves to Drift first, then syncs to Supabase when online
  /// Handles offline gracefully
  Future<Result<bool>> call({
    required String userId,
    required String meditationId,
  }) async {
    try {
      // Get current favorites
      final favoritesResult = await _repository.getFavoriteIds(userId);

      return favoritesResult.when(
        success: (favoriteIds) async {
          final isFavorited = favoriteIds.contains(meditationId);

          // Toggle the favorite status
          final toggleResult =
              await _repository.toggleFavorite(userId, meditationId);

          return toggleResult.when(
            success: (_) {
              // Return new favorite state (opposite of current)
              return Result.success(!isFavorited);
            },
            failure: (error) => Result.failure(error),
          );
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(
        Exception('Failed to toggle favorite: $e'),
      );
    }
  }
}
