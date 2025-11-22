import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:lifeos/features/settings/domain/repositories/settings_repository.dart';
import 'package:lifeos/features/settings/domain/usecases/delete_account_usecase.dart';

@GenerateMocks([SettingsRepository])
import 'delete_account_usecase_test.mocks.dart';

void main() {
  group('DeleteAccountUseCase', () {
    late MockSettingsRepository mockRepository;
    late DeleteAccountUseCase useCase;

    setUp(() {
      mockRepository = MockSettingsRepository();
      useCase = DeleteAccountUseCase(mockRepository);
    });

    test('should request account deletion successfully', () async {
      // Arrange
      const password = 'test-password';
      const requestId = 'deletion-request-id';
      when(mockRepository.requestAccountDeletion(password))
          .thenAnswer((_) async => requestId);

      // Act
      final result = await useCase.call(password);

      // Assert
      expect(result, requestId);
      verify(mockRepository.requestAccountDeletion(password)).called(1);
    });

    test('should throw exception when password is empty', () async {
      // Act & Assert
      expect(
        () => useCase.call(''),
        throwsA(isA<Exception>()),
      );
      verifyNever(mockRepository.requestAccountDeletion(any));
    });

    test('should throw exception when password is incorrect', () async {
      // Arrange
      const password = 'wrong-password';
      when(mockRepository.requestAccountDeletion(password))
          .thenThrow(Exception('Invalid password'));

      // Act & Assert
      expect(
        () => useCase.call(password),
        throwsA(isA<Exception>()),
      );
    });

    test('should check if account has pending deletion', () async {
      // Arrange
      when(mockRepository.hasPendingDeletion()).thenAnswer((_) async => true);

      // Act
      final result = await useCase.hasPendingDeletion();

      // Assert
      expect(result, true);
      verify(mockRepository.hasPendingDeletion()).called(1);
    });

    test('should get scheduled deletion date', () async {
      // Arrange
      final scheduledDate = DateTime(2025, 1, 30);
      when(mockRepository.getDeletionScheduledDate())
          .thenAnswer((_) async => scheduledDate);

      // Act
      final result = await useCase.getScheduledDeletionDate();

      // Assert
      expect(result, scheduledDate);
      verify(mockRepository.getDeletionScheduledDate()).called(1);
    });
  });
}
