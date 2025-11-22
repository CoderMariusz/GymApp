import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/sync/conflict_resolver.dart';

void main() {
  group('ConflictResolver', () {
    late ConflictResolver resolver;

    setUp(() {
      resolver = ConflictResolver(strategy: ConflictStrategy.lastWriteWins);
    });

    group('Last Write Wins Strategy', () {
      test('should choose remote when remote is newer', () {
        final localData = {
          'id': '1',
          'value': 'local',
          'updated_at': '2025-01-01T10:00:00Z',
        };
        final remoteData = {
          'id': '1',
          'value': 'remote',
          'updated_at': '2025-01-01T11:00:00Z',
        };

        final result = resolver.resolve(
          localData: localData,
          remoteData: remoteData,
        );

        expect(result.resolvedData['value'], 'remote');
        expect(result.wasConflict, true);
      });

      test('should choose local when local is newer', () {
        final localData = {
          'id': '1',
          'value': 'local',
          'updated_at': '2025-01-01T12:00:00Z',
        };
        final remoteData = {
          'id': '1',
          'value': 'remote',
          'updated_at': '2025-01-01T11:00:00Z',
        };

        final result = resolver.resolve(
          localData: localData,
          remoteData: remoteData,
        );

        expect(result.resolvedData['value'], 'local');
        expect(result.wasConflict, true);
      });

      test('should not report conflict when data is identical', () {
        final localData = {
          'id': '1',
          'value': 'same',
          'updated_at': '2025-01-01T10:00:00Z',
        };
        final remoteData = {
          'id': '1',
          'value': 'same',
          'updated_at': '2025-01-01T10:00:00Z',
        };

        final result = resolver.resolve(
          localData: localData,
          remoteData: remoteData,
        );

        expect(result.wasConflict, false);
      });

      test('should default to remote when timestamps are missing', () {
        final localData = {
          'id': '1',
          'value': 'local',
        };
        final remoteData = {
          'id': '1',
          'value': 'remote',
        };

        final result = resolver.resolve(
          localData: localData,
          remoteData: remoteData,
        );

        expect(result.resolvedData['value'], 'remote');
        expect(result.wasConflict, true);
      });
    });

    group('First Write Wins Strategy', () {
      setUp(() {
        resolver = ConflictResolver(strategy: ConflictStrategy.firstWriteWins);
      });

      test('should choose local when local is older', () {
        final localData = {
          'id': '1',
          'value': 'local',
          'updated_at': '2025-01-01T10:00:00Z',
        };
        final remoteData = {
          'id': '1',
          'value': 'remote',
          'updated_at': '2025-01-01T11:00:00Z',
        };

        final result = resolver.resolve(
          localData: localData,
          remoteData: remoteData,
        );

        expect(result.resolvedData['value'], 'local');
        expect(result.wasConflict, true);
      });

      test('should choose remote when remote is older', () {
        final localData = {
          'id': '1',
          'value': 'local',
          'updated_at': '2025-01-01T12:00:00Z',
        };
        final remoteData = {
          'id': '1',
          'value': 'remote',
          'updated_at': '2025-01-01T11:00:00Z',
        };

        final result = resolver.resolve(
          localData: localData,
          remoteData: remoteData,
        );

        expect(result.resolvedData['value'], 'remote');
        expect(result.wasConflict, true);
      });
    });
  });
}
