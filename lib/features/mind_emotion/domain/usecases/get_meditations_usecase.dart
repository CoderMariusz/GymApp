import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/mind_emotion/domain/entities/meditation_entity.dart';
import 'package:lifeos/features/mind_emotion/domain/repositories/meditation_repository.dart';

/// Use case for fetching meditations with optional filtering
class GetMeditationsUseCase {
  final MeditationRepository _repository;

  GetMeditationsUseCase({required MeditationRepository repository})
      : _repository = repository;

  /// Get meditations with optional filters
  ///
  /// Parameters:
  /// - [category]: Filter by meditation category
  /// - [searchQuery]: Filter by title or description containing this text
  /// - [minDuration]: Minimum duration in seconds
  /// - [maxDuration]: Maximum duration in seconds
  /// - [favoritesOnly]: Show only favorited meditations
  /// - [userId]: User ID for favorites filtering
  Future<Result<List<MeditationEntity>>> call({
    MeditationCategory? category,
    String? searchQuery,
    int? minDuration,
    int? maxDuration,
    bool favoritesOnly = false,
    String? userId,
  }) async {
    try {
      // Get all meditations from repository
      final result = await _repository.getMeditations();

      return result.when(
        success: (meditations) async {
          var filteredMeditations = meditations;

          // Apply category filter
          if (category != null) {
            filteredMeditations = filteredMeditations
                .where((m) => m.category == category)
                .toList();
          }

          // Apply search query filter
          if (searchQuery != null && searchQuery.isNotEmpty) {
            final query = searchQuery.toLowerCase();
            filteredMeditations = filteredMeditations.where((m) {
              return m.title.toLowerCase().contains(query) ||
                  m.description.toLowerCase().contains(query);
            }).toList();
          }

          // Apply duration filters
          if (minDuration != null) {
            filteredMeditations = filteredMeditations
                .where((m) => m.durationSeconds >= minDuration)
                .toList();
          }

          if (maxDuration != null) {
            filteredMeditations = filteredMeditations
                .where((m) => m.durationSeconds <= maxDuration)
                .toList();
          }

          // Apply favorites filter
          if (favoritesOnly && userId != null) {
            final favoritesResult = await _repository.getFavoriteIds(userId);
            final favoriteIds = favoritesResult.dataOrNull ?? [];

            filteredMeditations = filteredMeditations
                .where((m) => favoriteIds.contains(m.id))
                .toList();
          }

          return Result.success(filteredMeditations);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(Exception('Failed to get meditations: $e'));
    }
  }
}
