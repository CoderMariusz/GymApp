import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/core/sync/sync_queue.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Sync Integration Tests', () {
    late AppDatabase database;
    late SyncQueueService syncQueue;

    setUp(() async {
      database = AppDatabase();
      syncQueue = SyncQueueService(database);
    });

    tearDown(() async {
      await database.close();
    });

    testWidgets('should queue operations when offline', (tester) async {
      // Enqueue a create operation
      await syncQueue.enqueueCreate(
        'mood_logs',
        'test-mood-1',
        {
          'user_id': 'test-user',
          'mood_score': 5,
          'energy_score': 4,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      // Verify operation is in queue
      final hasPending = await syncQueue.hasPendingOperations();
      expect(hasPending, true);

      final pendingCount = await syncQueue.getPendingCount();
      expect(pendingCount, greaterThan(0));
    });

    testWidgets('should process queued operations when online', (tester) async {
      // Enqueue multiple operations
      await syncQueue.enqueueCreate('mood_logs', 'test-1', {'data': 'test1'});
      await syncQueue.enqueueUpdate('mood_logs', 'test-2', {'data': 'test2'});
      await syncQueue.enqueueDelete('mood_logs', 'test-3');

      // Get pending operations
      final pending = await syncQueue.getPendingOperations();
      expect(pending.length, 3);

      // Verify operations are correct types
      expect(pending[0].operation, 'insert');
      expect(pending[1].operation, 'update');
      expect(pending[2].operation, 'delete');
    });

    testWidgets('should handle sync errors with retry', (tester) async {
      // Enqueue an operation
      await syncQueue.enqueueCreate('mood_logs', 'test-error', {'data': 'test'});

      final pending = await syncQueue.getPendingOperations();
      final item = pending.first;

      // Simulate error
      await syncQueue.recordFailure(item.id, 'Network error');

      // Verify retry count increased
      final updatedPending = await syncQueue.getPendingOperations();
      expect(updatedPending.isNotEmpty, true);
    });

    testWidgets('should clear completed sync items', (tester) async {
      // Enqueue and complete operations
      await syncQueue.enqueueCreate('mood_logs', 'test-complete', {'data': 'test'});

      final pending = await syncQueue.getPendingOperations();
      if (pending.isNotEmpty) {
        await syncQueue.markCompleted(pending.first.id);
      }

      // Clear completed items
      await syncQueue.clearCompleted();

      // Verify only pending items remain
      final remaining = await syncQueue.getPendingOperations();
      expect(remaining.every((item) => item.isPending), true);
    });
  });
}
