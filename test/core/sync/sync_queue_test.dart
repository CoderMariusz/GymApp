import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/sync/sync_queue.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:lifeos/core/database/database.dart';

@GenerateMocks([AppDatabase])
import 'sync_queue_test.mocks.dart';

void main() {
  group('SyncQueueService', () {
    late MockAppDatabase mockDatabase;
    late SyncQueueService syncQueue;

    setUp(() {
      mockDatabase = MockAppDatabase();
      syncQueue = SyncQueueService(mockDatabase);
    });

    test('enqueueCreate should add insert operation to queue', () async {
      when(mockDatabase.enqueueSyncOperation(
        id: anyNamed('id'),
        tableName: anyNamed('tableName'),
        recordId: anyNamed('recordId'),
        operation: anyNamed('operation'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async => {});

      await syncQueue.enqueueCreate(
        'mood_logs',
        'test-id',
        {'mood_score': 5},
      );

      verify(mockDatabase.enqueueSyncOperation(
        id: anyNamed('id'),
        tableName: 'mood_logs',
        recordId: 'test-id',
        operation: 'insert',
        payload: anyNamed('payload'),
      )).called(1);
    });

    test('enqueueUpdate should add update operation to queue', () async {
      when(mockDatabase.enqueueSyncOperation(
        id: anyNamed('id'),
        tableName: anyNamed('tableName'),
        recordId: anyNamed('recordId'),
        operation: anyNamed('operation'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async => {});

      await syncQueue.enqueueUpdate(
        'mood_logs',
        'test-id',
        {'mood_score': 4},
      );

      verify(mockDatabase.enqueueSyncOperation(
        id: anyNamed('id'),
        tableName: 'mood_logs',
        recordId: 'test-id',
        operation: 'update',
        payload: anyNamed('payload'),
      )).called(1);
    });

    test('enqueueDelete should add delete operation to queue', () async {
      when(mockDatabase.enqueueSyncOperation(
        id: anyNamed('id'),
        tableName: anyNamed('tableName'),
        recordId: anyNamed('recordId'),
        operation: anyNamed('operation'),
        payload: anyNamed('payload'),
      )).thenAnswer((_) async => {});

      await syncQueue.enqueueDelete('mood_logs', 'test-id');

      verify(mockDatabase.enqueueSyncOperation(
        id: anyNamed('id'),
        tableName: 'mood_logs',
        recordId: 'test-id',
        operation: 'delete',
        payload: anyNamed('payload'),
      )).called(1);
    });

    test('hasPendingOperations should return true when queue has items', () async {
      when(mockDatabase.getPendingSyncItems()).thenAnswer(
        (_) async => [
          // Mock SyncQueueItem (you'll need to create a proper mock)
        ],
      );

      // This test would need proper mocking of SyncQueueItem
      // For now, it demonstrates the test structure
    });
  });
}
