import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:lifeos/core/error/exceptions.dart';
import 'package:lifeos/features/mind_emotion/domain/entities/meditation_entity.dart';
import 'package:lifeos/features/mind_emotion/domain/repositories/meditation_repository.dart';
import 'package:lifeos/features/mind_emotion/domain/usecases/download_meditation_usecase.dart';

@GenerateMocks([MeditationRepository])
import 'download_meditation_usecase_test.mocks.dart';

void main() {
  late DownloadMeditationUseCase useCase;
  late MockMeditationRepository mockRepository;
  UserTier currentTier = UserTier.premium;

  setUp(() {
    mockRepository = MockMeditationRepository();
    useCase = DownloadMeditationUseCase(
      repository: mockRepository,
      getUserTier: () => currentTier,
    );
  });

  final testMeditation = MeditationEntity(
    id: 'meditation123',
    title: 'Test Meditation',
    description: 'Description',
    durationSeconds: 600,
    category: MeditationCategory.stressRelief,
    audioUrl: 'https://example.com/audio.mp3',
    thumbnailUrl: 'https://example.com/thumb.jpg',
    createdAt: DateTime(2025, 1, 1),
    isPremium: true,
  );

  group('DownloadMeditationUseCase', () {
    test('should throw TierRestrictionException when user is free tier',
        () async {
      // Arrange
      currentTier = UserTier.free;

      // Act & Assert
      expect(
        () async {
          await for (final _ in useCase(
            meditationId: testMeditation.id,
            meditation: testMeditation,
          )) {}
        },
        throwsA(isA<TierRestrictionException>()),
      );
    });

    test('should start download when user is premium tier', () async {
      // Arrange
      currentTier = UserTier.premium;
      when(mockRepository.isDownloaded(testMeditation.id))
          .thenAnswer((_) async => false);

      when(mockRepository.downloadAudio(any, any)).thenAnswer(
        (_) => Stream.fromIterable([
          DownloadProgress(
            bytesReceived: 50,
            totalBytes: 100,
            percentage: 50.0,
            status: DownloadStatus.downloading,
          ),
          DownloadProgress(
            bytesReceived: 100,
            totalBytes: 100,
            percentage: 100.0,
            status: DownloadStatus.completed,
          ),
        ]),
      );

      // Act
      final progressList = <DownloadProgress>[];
      await for (final progress in useCase(
        meditationId: testMeditation.id,
        meditation: testMeditation,
      )) {
        progressList.add(progress);
      }

      // Assert
      expect(progressList.length, greaterThan(0));
      expect(progressList.last.status, equals(DownloadStatus.completed));
      verify(mockRepository.isDownloaded(testMeditation.id)).called(1);
      verify(mockRepository.downloadAudio(
        testMeditation.audioUrl,
        argThat(contains('meditations')),
      )).called(1);
    });

    test('should return completed immediately if already downloaded', () async {
      // Arrange
      currentTier = UserTier.premium;
      when(mockRepository.isDownloaded(testMeditation.id))
          .thenAnswer((_) async => true);

      // Act
      final progressList = <DownloadProgress>[];
      await for (final progress in useCase(
        meditationId: testMeditation.id,
        meditation: testMeditation,
      )) {
        progressList.add(progress);
      }

      // Assert
      expect(progressList.length, equals(1));
      expect(progressList.first.percentage, equals(100.0));
      expect(progressList.first.status, equals(DownloadStatus.completed));
      verify(mockRepository.isDownloaded(testMeditation.id)).called(1);
      verifyNever(mockRepository.downloadAudio(any, any));
    });
  });
}
