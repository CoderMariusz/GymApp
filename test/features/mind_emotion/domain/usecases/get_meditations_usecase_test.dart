import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:lifeos/core/error/result.dart';
import 'package:lifeos/features/mind_emotion/domain/entities/meditation_entity.dart';
import 'package:lifeos/features/mind_emotion/domain/repositories/meditation_repository.dart';
import 'package:lifeos/features/mind_emotion/domain/usecases/get_meditations_usecase.dart';

@GenerateMocks([MeditationRepository])
import 'get_meditations_usecase_test.mocks.dart';

void main() {
  late GetMeditationsUseCase useCase;
  late MockMeditationRepository mockRepository;

  setUp(() {
    mockRepository = MockMeditationRepository();
    useCase = GetMeditationsUseCase(repository: mockRepository);
  });

  group('GetMeditationsUseCase', () {
    final testMeditations = [
      MeditationEntity(
        id: '1',
        title: 'Stress Relief Meditation',
        description: 'Reduce stress',
        durationSeconds: 600, // 10 min
        category: MeditationCategory.stressRelief,
        audioUrl: 'https://example.com/audio1.mp3',
        thumbnailUrl: 'https://example.com/thumb1.jpg',
        createdAt: DateTime(2025, 1, 1),
        isPremium: false,
      ),
      MeditationEntity(
        id: '2',
        title: 'Sleep Meditation',
        description: 'Better sleep',
        durationSeconds: 900, // 15 min
        category: MeditationCategory.sleep,
        audioUrl: 'https://example.com/audio2.mp3',
        thumbnailUrl: 'https://example.com/thumb2.jpg',
        createdAt: DateTime(2025, 1, 2),
        isPremium: true,
      ),
      MeditationEntity(
        id: '3',
        title: 'Focus Meditation',
        description: 'Improve focus',
        durationSeconds: 300, // 5 min
        category: MeditationCategory.focus,
        audioUrl: 'https://example.com/audio3.mp3',
        thumbnailUrl: 'https://example.com/thumb3.jpg',
        createdAt: DateTime(2025, 1, 3),
        isPremium: false,
      ),
    ];

    test('should return all meditations when no filters applied', () async {
      // Arrange
      when(mockRepository.getMeditations())
          .thenAnswer((_) async => Result.success(testMeditations));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Success<List<MeditationEntity>>>());
      expect(result.dataOrNull?.length, equals(3));
      verify(mockRepository.getMeditations()).called(1);
    });

    test('should filter by category', () async {
      // Arrange
      when(mockRepository.getMeditations())
          .thenAnswer((_) async => Result.success(testMeditations));

      // Act
      final result = await useCase(category: MeditationCategory.stressRelief);

      // Assert
      expect(result.dataOrNull?.length, equals(1));
      expect(result.dataOrNull?.first.category,
          equals(MeditationCategory.stressRelief));
    });

    test('should filter by search query in title', () async {
      // Arrange
      when(mockRepository.getMeditations())
          .thenAnswer((_) async => Result.success(testMeditations));

      // Act
      final result = await useCase(searchQuery: 'stress');

      // Assert
      expect(result.dataOrNull?.length, equals(1));
      expect(result.dataOrNull?.first.title.toLowerCase(),
          contains('stress'));
    });

    test('should filter by search query in description', () async {
      // Arrange
      when(mockRepository.getMeditations())
          .thenAnswer((_) async => Result.success(testMeditations));

      // Act
      final result = await useCase(searchQuery: 'focus');

      // Assert
      expect(result.dataOrNull?.length, equals(1));
      expect(result.dataOrNull?.first.description.toLowerCase(),
          contains('focus'));
    });

    test('should filter by minimum duration', () async {
      // Arrange
      when(mockRepository.getMeditations())
          .thenAnswer((_) async => Result.success(testMeditations));

      // Act
      final result = await useCase(minDuration: 600); // >= 10 min

      // Assert
      expect(result.dataOrNull?.length, equals(2));
      expect(
          result.dataOrNull?.every((m) => m.durationSeconds >= 600), isTrue);
    });

    test('should filter by maximum duration', () async {
      // Arrange
      when(mockRepository.getMeditations())
          .thenAnswer((_) async => Result.success(testMeditations));

      // Act
      final result = await useCase(maxDuration: 600); // <= 10 min

      // Assert
      expect(result.dataOrNull?.length, equals(2));
      expect(
          result.dataOrNull?.every((m) => m.durationSeconds <= 600), isTrue);
    });

    test('should filter by duration range', () async {
      // Arrange
      when(mockRepository.getMeditations())
          .thenAnswer((_) async => Result.success(testMeditations));

      // Act
      final result =
          await useCase(minDuration: 300, maxDuration: 600); // 5-10 min

      // Assert
      expect(result.dataOrNull?.length, equals(2));
    });

    test('should apply multiple filters', () async {
      // Arrange
      when(mockRepository.getMeditations())
          .thenAnswer((_) async => Result.success(testMeditations));

      // Act
      final result = await useCase(
        category: MeditationCategory.sleep,
        minDuration: 600,
      );

      // Assert
      expect(result.dataOrNull?.length, equals(1));
      expect(result.dataOrNull?.first.category, equals(MeditationCategory.sleep));
      expect(result.dataOrNull?.first.durationSeconds, greaterThanOrEqualTo(600));
    });

    test('should return failure when repository fails', () async {
      // Arrange
      final exception = Exception('Network error');
      when(mockRepository.getMeditations())
          .thenAnswer((_) async => Result.failure(exception));

      // Act
      final result = await useCase();

      // Assert
      expect(result, isA<Failure<List<MeditationEntity>>>());
    });

    test('should return empty list when no meditations match filters',
        () async {
      // Arrange
      when(mockRepository.getMeditations())
          .thenAnswer((_) async => Result.success(testMeditations));

      // Act
      final result = await useCase(
        category: MeditationCategory.gratitude, // No gratitude meditations
      );

      // Assert
      expect(result.dataOrNull?.length, equals(0));
    });
  });
}
