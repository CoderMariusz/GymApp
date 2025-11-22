import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/mind_emotion/domain/repositories/meditation_repository.dart';
import 'package:lifeos/features/mind_emotion/domain/usecases/toggle_favorite_usecase.dart';

@GenerateMocks([MeditationRepository])
import 'toggle_favorite_usecase_test.mocks.dart';

void main() {
  late ToggleFavoriteUseCase useCase;
  late MockMeditationRepository mockRepository;

  setUp(() {
    mockRepository = MockMeditationRepository();
    useCase = ToggleFavoriteUseCase(repository: mockRepository);
  });

  const userId = 'user123';
  const meditationId = 'meditation456';

  group('ToggleFavoriteUseCase', () {
    test('should toggle favorite from false to true', () async {
      // Arrange
      when(mockRepository.getFavoriteIds(userId))
          .thenAnswer((_) async => const Result.success([]));
      when(mockRepository.toggleFavorite(userId, meditationId))
          .thenAnswer((_) async => const Result.success(null));

      // Act
      final result = await useCase(userId: userId, meditationId: meditationId);

      // Assert
      expect(result.dataOrNull, equals(true)); // Should be true (favorited)
      verify(mockRepository.getFavoriteIds(userId)).called(1);
      verify(mockRepository.toggleFavorite(userId, meditationId)).called(1);
    });

    test('should toggle favorite from true to false', () async {
      // Arrange
      when(mockRepository.getFavoriteIds(userId))
          .thenAnswer((_) async => const Result.success([meditationId]));
      when(mockRepository.toggleFavorite(userId, meditationId))
          .thenAnswer((_) async => const Result.success(null));

      // Act
      final result = await useCase(userId: userId, meditationId: meditationId);

      // Assert
      expect(result.dataOrNull, equals(false)); // Should be false (unfavorited)
      verify(mockRepository.getFavoriteIds(userId)).called(1);
      verify(mockRepository.toggleFavorite(userId, meditationId)).called(1);
    });

    test('should return failure when getting favorites fails', () async {
      // Arrange
      final exception = Exception('Database error');
      when(mockRepository.getFavoriteIds(userId))
          .thenAnswer((_) async => Result.failure(exception));

      // Act
      final result = await useCase(userId: userId, meditationId: meditationId);

      // Assert
      expect(result, isA<Failure<bool>>());
      verify(mockRepository.getFavoriteIds(userId)).called(1);
      verifyNever(mockRepository.toggleFavorite(any, any));
    });

    test('should return failure when toggling favorite fails', () async {
      // Arrange
      final exception = Exception('Network error');
      when(mockRepository.getFavoriteIds(userId))
          .thenAnswer((_) async => const Result.success([]));
      when(mockRepository.toggleFavorite(userId, meditationId))
          .thenAnswer((_) async => Result.failure(exception));

      // Act
      final result = await useCase(userId: userId, meditationId: meditationId);

      // Assert
      expect(result, isA<Failure<bool>>());
      verify(mockRepository.getFavoriteIds(userId)).called(1);
      verify(mockRepository.toggleFavorite(userId, meditationId)).called(1);
    });
  });
}
