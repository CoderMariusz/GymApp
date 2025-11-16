# Story 1.5: Data Sync Across Devices

**Epic:** Epic 1 - Core Platform Foundation
**Phase:** MVP
**Priority:** P0
**Status:** drafted
**Estimated Effort:** 5 SP

---

## User Story

**As a** user with multiple devices
**I want** my data synced in real-time
**So that** I can seamlessly switch between my phone and tablet

---

## Acceptance Criteria

1. ✅ Workout data synced via Supabase Realtime (<5s latency)
2. ✅ Mood logs synced across devices
3. ✅ Goals synced across devices
4. ✅ Meditation progress synced across devices
5. ✅ Sync works offline (queued, synced when online)
6. ✅ Conflict resolution: Last-write-wins
7. ✅ Sync status indicator in app (syncing/synced/offline)

---

## Functional Requirements Covered

- **FR98:** Data sync across devices (realtime)
- **NFR-P5:** Offline-first support (data accessible without internet)

---

## UX Notes

- Subtle sync indicator in navigation bar (cloud icon)
- "Offline mode" banner when no internet (reassuring, not alarming)
- No user action required for sync (automatic)

**Design Reference:** UX Design Specification - Sync Indicators

---

## Technical Implementation

### Frontend (Flutter)

**Architecture:** Hybrid Sync (Write-Through Cache + Sync Queue)

**Local Database (Drift/SQLite):**
```dart
// lib/core/database/app_database.dart
@DriftDatabase(tables: [
  Workouts,
  MoodLogs,
  Goals,
  MeditationSessions,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  // Local-first storage
  // All writes go to local DB first
}
```

**Sync Queue:**
```dart
// lib/core/sync/sync_queue.dart
class SyncQueue {
  Future<void> enqueueWrite(SyncItem item) async {
    // Add to sync_queue table
    // Mark as pending
    // Trigger sync if online
  }

  Future<void> processPendingSync() async {
    final pendingItems = await db.getPendingSyncItems();
    for (final item in pendingItems) {
      await _syncToSupabase(item);
      await db.markSyncComplete(item.id);
    }
  }
}
```

**Supabase Realtime:**
```dart
// lib/core/sync/realtime_sync.dart
class RealtimeSync {
  void subscribeToChanges() {
    supabase
      .from('workouts')
      .stream(primaryKey: ['id'])
      .listen((List<Map<String, dynamic>> data) {
        // Update local Drift database
        _updateLocalDatabase(data);
      });

    // Repeat for mood_logs, goals, meditation_sessions
  }
}
```

### Backend (Supabase)

**Realtime Configuration:**
```sql
-- Enable realtime on all user tables
ALTER PUBLICATION supabase_realtime ADD TABLE workouts;
ALTER PUBLICATION supabase_realtime ADD TABLE mood_logs;
ALTER PUBLICATION supabase_realtime ADD TABLE goals;
ALTER PUBLICATION supabase_realtime ADD TABLE meditation_sessions;
```

**Conflict Resolution:**
```sql
-- Last-write-wins (updated_at timestamp)
-- No custom conflict logic (simple for MVP)
-- User's most recent edit always wins
```

### Sync Lifecycle

**App Lifecycle Triggers (Opportunistic Sync):**
```dart
class SyncService {
  void initializeSync() {
    // Sync on app launch
    WidgetsBinding.instance.addObserver(
      LifecycleEventHandler(
        resumeCallBack: () async => await _syncNow(),
      ),
    );

    // Sync when connectivity restored
    Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        _syncNow();
      }
    });
  }
}
```

**Sync Status Indicator:**
```dart
enum SyncStatus { synced, syncing, offline }

final syncStatusProvider = StateProvider<SyncStatus>((ref) {
  // Check connectivity + pending queue
  return SyncStatus.synced;
});
```

### Performance Optimization

**Tiered Lazy Loading:**
- **Critical data (15MB):** User profile, active goals, today's workouts
- **Popular data (auto-cache):** Last 7 days workouts, recent mood logs
- **On-demand:** Historical data (>7 days), archived goals

**Battery Optimization:**
- No background polling (saves ~2% battery)
- Sync only on app lifecycle events
- <5% battery usage in 8 hours (NFR-P6)

---

## Dependencies

**Prerequisites:**
- Story 1.1 (User accounts must exist)
- Story 1.2 (User must be logged in)

**Blocks:**
- All data-heavy features (workouts, mood, goals, meditations)

---

## Testing Requirements

### Unit Tests
```dart
test('should enqueue write when offline')
test('should sync queued items when online')
test('should resolve conflict with last-write-wins')
test('should update local DB on realtime event')
```

### Integration Tests
```dart
testWidgets('workout logged offline syncs when online')
testWidgets('realtime sync updates across devices')
testWidgets('conflict resolution works correctly')
```

**Coverage Target:** 75%+ (complex sync logic)

---

## Definition of Done

- [ ] Workout data syncs in <5s
- [ ] Mood logs sync across devices
- [ ] Goals sync across devices
- [ ] Meditation progress syncs
- [ ] Offline writes queued and synced when online
- [ ] Last-write-wins conflict resolution works
- [ ] Sync status indicator shows correct state
- [ ] No data loss in offline mode
- [ ] Battery usage <5% in 8 hours
- [ ] Unit tests pass (75%+ coverage)
- [ ] Integration tests pass
- [ ] Multi-device testing complete
- [ ] Code reviewed and approved
- [ ] Merged to develop branch

---

## Notes

**Architecture Decision:**
- **D3: Hybrid Sync (Write-Through Cache + Sync Queue)**
- Write to local DB first (instant UI update)
- Queue sync to Supabase (background)
- Supabase Realtime for incoming changes

**Performance:**
- Sync latency <5s (NFR-P5)
- Offline mode fully functional
- Battery usage <5% (opportunistic sync, no polling)

**Edge Cases:**
- User logs workout on Device A (offline)
- User logs workout on Device B (online)
- Device A comes online → Both workouts synced (no conflict)
- If same workout edited on both → Last edit wins (updated_at)

---

## Related Stories

- **Previous:** Story 1.4 (User Profile Management)
- **Next:** Story 1.6 (GDPR Compliance)
- **Enables:** Epic 2 (Life Coach), Epic 3 (Fitness), Epic 4 (Mind)

---

**Created:** 2025-01-16
**Last Updated:** 2025-01-16
**Author:** Bob (Scrum Master - BMAD)
