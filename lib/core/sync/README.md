# Data Sync System (Story 1.5)

## Overview

This directory contains the offline-first data sync implementation for LifeOS. The sync system enables real-time data synchronization across multiple devices with offline support and conflict resolution.

## Architecture

### Components

1. **Database Layer** (`database.dart`)
   - Drift-based local database with sync-ready tables
   - SyncQueue table for offline operation tracking
   - All tables include `isSynced` and `lastSyncedAt` metadata

2. **Sync Queue** (`sync_queue.dart`)
   - Manages offline operations queue
   - Supports insert, update, delete operations
   - Automatic retry with error tracking

3. **Realtime Sync** (`realtime_sync.dart`)
   - Supabase Realtime subscriptions
   - Listens to remote changes (insert, update, delete)
   - Applies changes to local database

4. **Conflict Resolution** (`conflict_resolver.dart`)
   - Last-write-wins strategy (default)
   - Timestamp-based conflict detection
   - Supports multiple resolution strategies

5. **Sync Service** (`sync_service.dart`)
   - Main orchestrator for sync operations
   - Connectivity monitoring
   - Periodic sync (every 5 minutes)
   - App lifecycle integration

6. **UI Components** (`widgets/`)
   - `SyncStatusIndicator` - Shows sync status (cloud icon)
   - `OfflineBanner` - Displays when offline

## Usage

### 1. Integration in App

Wrap your app with `SyncInitializer`:

```dart
import 'package:lifeos/core/sync/sync_initializer.dart';

class LifeOSApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SyncInitializer(
      child: MaterialApp.router(
        // your app config
      ),
    );
  }
}
```

### 2. Adding Sync Status Indicator

Add to your app bar or navigation:

```dart
import 'package:lifeos/core/sync/widgets/sync_status_indicator.dart';

AppBar(
  actions: [
    SyncStatusIndicator(),
  ],
)
```

### 3. Adding Offline Banner

Add to your scaffold:

```dart
import 'package:lifeos/core/sync/widgets/offline_banner.dart';

Scaffold(
  body: Column(
    children: [
      OfflineBanner(),
      // your content
    ],
  ),
)
```

### 4. Writing Data (Offline-First)

When writing data, always write to local database first, then queue for sync:

```dart
// Example: Creating a mood log
final moodLog = {
  'id': uuid.v4(),
  'user_id': userId,
  'mood_score': 5,
  'created_at': DateTime.now().toIso8601String(),
};

// 1. Write to local database
await database.into(database.moodLogs).insert(
  MoodLogsCompanion.insert(/* ... */),
);

// 2. Queue for sync
final syncQueue = ref.read(syncQueueServiceProvider);
await syncQueue.enqueueCreate('mood_logs', moodLog['id'], moodLog);
```

### 5. Manual Sync Trigger

```dart
final syncService = ref.read(syncServiceProvider);
await syncService.sync();
```

## Database Schema

### SyncQueue Table

```dart
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get tableName => text()();
  TextColumn get recordId => text()();
  TextColumn get operation => text()(); // 'insert' | 'update' | 'delete'
  TextColumn get payload => text()(); // JSON data
  IntColumn get retryCount => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get errorMessage => text().nullable()();
  BoolColumn get isPending => boolean()();
}
```

## Supabase Configuration

### Enable Realtime

The migration `20250122_enable_realtime_sync.sql` enables Realtime on:
- `workout_templates`
- `mood_logs`
- `mental_health_screenings`
- `streaks`
- `ai_conversations`
- `meditation_sessions`

### Automatic Timestamps

All tables with `updated_at` columns automatically update on modification via triggers.

## Sync Flow

### Write Operation (Offline)

1. User creates/updates/deletes data
2. Data written to local Drift database (<100ms)
3. Operation added to SyncQueue
4. When online, SyncQueue processes items
5. Data synced to Supabase
6. SyncQueue item marked completed

### Realtime Update (From Remote)

1. Another device makes changes
2. Supabase Realtime broadcasts change
3. Local app receives change via subscription
4. Conflict resolver checks for conflicts
5. Resolved data written to local database
6. UI updates automatically via streams

## Conflict Resolution

### Last Write Wins (Default)

Compares `updated_at` timestamps and keeps the most recent version.

```dart
final resolver = ConflictResolver(
  strategy: ConflictStrategy.lastWriteWins,
);
```

### Adding Custom Strategy

Extend `ConflictResolver` and implement your own strategy:

```dart
enum ConflictStrategy {
  lastWriteWins,
  firstWriteWins,
  manual, // Requires user intervention
  custom,
}
```

## Testing

### Unit Tests

```bash
flutter test test/core/sync/
```

### Integration Tests

```bash
flutter test integration_test/sync/
```

## Performance

- **Local writes**: <100ms
- **Sync latency**: <5s (when online)
- **Battery usage**: <5% in 8 hours
- **Conflict resolution**: O(1) for last-write-wins

## Troubleshooting

### Sync not working

1. Check connectivity: `ref.watch(isOnlineProvider)`
2. Check sync status: `ref.watch(syncStatusProvider)`
3. Verify Realtime is enabled on Supabase tables
4. Check RLS policies allow user access

### Data conflicts

Check `SyncEvent.wasConflict` in the sync event stream to detect conflicts.

### Queue backup

```dart
final pendingCount = await syncQueue.getPendingCount();
if (pendingCount > 100) {
  // Handle queue backup
}
```

## Future Enhancements

- [ ] Selective sync (choose which tables to sync)
- [ ] Sync priority (critical data first)
- [ ] Bandwidth-aware sync (WiFi vs cellular)
- [ ] Conflict resolution UI for manual conflicts
- [ ] Sync analytics and monitoring
