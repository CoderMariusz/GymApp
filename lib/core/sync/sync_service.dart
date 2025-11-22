import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:lifeos/core/sync/sync_queue.dart';
import 'package:lifeos/core/sync/realtime_sync.dart';
import 'package:lifeos/core/sync/conflict_resolver.dart';

/// Main sync orchestrator for offline-first data sync
class SyncService {
  final AppDatabase _database;
  final SupabaseClient _supabase;
  final SyncQueueService _syncQueue;
  final RealtimeSyncService _realtimeSync;
  final Connectivity _connectivity;

  bool _isOnline = false;
  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _syncTimer;

  final StreamController<SyncStatus> _statusController = StreamController.broadcast();

  SyncService({
    required AppDatabase database,
    required SupabaseClient supabase,
  })  : _database = database,
        _supabase = supabase,
        _syncQueue = SyncQueueService(database),
        _realtimeSync = RealtimeSyncService(
          supabase,
          database,
          ConflictResolver(),
        ),
        _connectivity = Connectivity();

  /// Stream of sync status updates
  Stream<SyncStatus> get statusStream => _statusController.stream;

  /// Current sync status
  SyncStatus get currentStatus => SyncStatus(
        isOnline: _isOnline,
        isSyncing: _isSyncing,
        lastSyncTime: DateTime.now(),
      );

  /// Initialize sync service
  Future<void> initialize(String userId) async {
    // Check initial connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = !connectivityResult.contains(ConnectivityResult.none);

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );

    // Subscribe to Realtime updates if online
    if (_isOnline) {
      await _subscribeToRealtimeUpdates(userId);
      await _processSyncQueue();
    }

    // Set up periodic sync (every 5 minutes)
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_isOnline) {
        _processSyncQueue();
      }
    });

    _emitStatus();
  }

  /// Subscribe to Realtime updates for all tables
  Future<void> _subscribeToRealtimeUpdates(String userId) async {
    final tables = [
      'mood_logs',
      'workout_templates',
      'mental_health_screenings',
      'meditation_sessions',
      'streaks',
      'user_daily_metrics',
    ];

    for (final table in tables) {
      await _realtimeSync.subscribeToTable(
        tableName: table,
        userId: userId,
        onInsert: (data) => _handleRemoteInsert(table, data),
        onUpdate: (data) => _handleRemoteUpdate(table, data),
        onDelete: (data) => _handleRemoteDelete(table, data),
      );
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> result) {
    final wasOnline = _isOnline;
    _isOnline = !result.contains(ConnectivityResult.none);

    if (!wasOnline && _isOnline) {
      // Just came online - process pending queue
      _processSyncQueue();
    }

    _emitStatus();
  }

  /// Process the sync queue
  Future<void> _processSyncQueue() async {
    if (_isSyncing || !_isOnline) return;

    _isSyncing = true;
    _emitStatus();

    try {
      final pendingItems = await _syncQueue.getPendingOperations();

      for (final item in pendingItems) {
        try {
          await _syncItem(item);
          await _syncQueue.markCompleted(item.id);
        } catch (e) {
          await _syncQueue.recordFailure(item.id, e.toString());
        }
      }

      // Clean up completed items
      await _syncQueue.clearCompleted();
    } finally {
      _isSyncing = false;
      _emitStatus();
    }
  }

  /// Sync a single item to Supabase
  Future<void> _syncItem(SyncQueueItem item) async {
    final data = jsonDecode(item.payload) as Map<String, dynamic>;

    switch (item.operation) {
      case 'insert':
        await _supabase.from(item.tableName).insert(data);
        break;
      case 'update':
        await _supabase
            .from(item.tableName)
            .update(data)
            .eq('id', item.recordId);
        break;
      case 'delete':
        await _supabase.from(item.tableName).delete().eq('id', item.recordId);
        break;
    }
  }

  /// Handle remote insert from Realtime
  Future<void> _handleRemoteInsert(String tableName, Map<String, dynamic> data) async {
    // Insert into local database
    switch (tableName) {
      case 'mood_logs':
        await _insertMoodLog(data);
        break;
      // Add other tables as needed
    }
  }

  /// Handle remote update from Realtime
  Future<void> _handleRemoteUpdate(String tableName, Map<String, dynamic> data) async {
    // Update local database
    switch (tableName) {
      case 'mood_logs':
        await _updateMoodLog(data);
        break;
      // Add other tables as needed
    }
  }

  /// Handle remote delete from Realtime
  Future<void> _handleRemoteDelete(String tableName, Map<String, dynamic> data) async {
    final recordId = data['id'] as String;
    // Delete from local database
    switch (tableName) {
      case 'mood_logs':
        await (_database.delete(_database.moodLogs)
              ..where((tbl) => tbl.id.equals(recordId)))
            .go();
        break;
      // Add other tables as needed
    }
  }

  /// Insert mood log from remote
  Future<void> _insertMoodLog(Map<String, dynamic> data) async {
    await _database.into(_database.moodLogs).insert(
          MoodLogsCompanion.insert(
            id: data['id'],
            userId: data['user_id'],
            moodScore: data['mood_score'],
            energyScore: Value(data['energy_score']),
            stressLevel: Value(data['stress_level']),
            notes: Value(data['notes']),
            loggedAt: DateTime.parse(data['logged_at']),
            createdAt: DateTime.parse(data['created_at']),
            isSynced: const Value(true),
            lastSyncedAt: Value(DateTime.now()),
          ),
          mode: InsertMode.insertOrReplace,
        );
  }

  /// Update mood log from remote
  Future<void> _updateMoodLog(Map<String, dynamic> data) async {
    await (_database.update(_database.moodLogs)
          ..where((tbl) => tbl.id.equals(data['id'])))
        .write(
      MoodLogsCompanion(
        moodScore: Value(data['mood_score']),
        energyScore: Value(data['energy_score']),
        stressLevel: Value(data['stress_level']),
        notes: Value(data['notes']),
        isSynced: const Value(true),
        lastSyncedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Emit current status
  void _emitStatus() {
    _statusController.add(currentStatus);
  }

  /// Manually trigger sync
  Future<void> sync() async {
    if (_isOnline) {
      await _processSyncQueue();
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    await _realtimeSync.dispose();
    await _statusController.close();
  }
}

/// Sync status information
class SyncStatus {
  final bool isOnline;
  final bool isSyncing;
  final DateTime lastSyncTime;

  SyncStatus({
    required this.isOnline,
    required this.isSyncing,
    required this.lastSyncTime,
  });

  String get statusText {
    if (!isOnline) return 'Offline';
    if (isSyncing) return 'Syncing...';
    return 'Synced';
  }
}
