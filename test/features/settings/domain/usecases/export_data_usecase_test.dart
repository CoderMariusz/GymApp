import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:lifeos/features/settings/domain/repositories/settings_repository.dart';
import 'package:lifeos/features/settings/domain/usecases/export_data_usecase.dart';

@GenerateMocks([SettingsRepository])
import 'export_data_usecase_test.mocks.dart';

void main() {
  group('ExportDataUseCase', () {
    late MockSettingsRepository mockRepository;
    late ExportDataUseCase useCase;

    setUp(() {
      mockRepository = MockSettingsRepository();
      useCase = ExportDataUseCase(mockRepository);
    });

    test('should request data export successfully', () async {
      // Arrange
      const requestId = 'test-request-id';
      when(mockRepository.requestDataExport())
          .thenAnswer((_) async => requestId);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, requestId);
      verify(mockRepository.requestDataExport()).called(1);
    });

    test('should throw exception when export fails', () async {
      // Arrange
      when(mockRepository.requestDataExport())
          .thenThrow(Exception('Rate limit exceeded'));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsA(isA<Exception>()),
      );
    });

    test('should check export status successfully', () async {
      // Arrange
      const requestId = 'test-request-id';
      const downloadUrl = 'https://example.com/download';
      when(mockRepository.getExportStatus(requestId))
          .thenAnswer((_) async => downloadUrl);

      // Act
      final result = await useCase.checkStatus(requestId);

      // Assert
      expect(result, downloadUrl);
      verify(mockRepository.getExportStatus(requestId)).called(1);
    });

    test('should return null when export is still processing', () async {
      // Arrange
      const requestId = 'test-request-id';
      when(mockRepository.getExportStatus(requestId))
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase.checkStatus(requestId);

      // Assert
      expect(result, isNull);
    });
  });
}
