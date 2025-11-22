import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/core/sync/sync_service.dart';
import 'package:lifeos/core/database/database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the database instance
final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

/// Provider for Supabase client
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for the sync service
final syncServiceProvider = Provider<SyncService>((ref) {
  final database = ref.watch(databaseProvider);
  final supabase = ref.watch(supabaseProvider);
  return SyncService(database: database, supabase: supabase);
});

/// Provider for sync status stream
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.statusStream;
});

/// Provider for current sync status
final currentSyncStatusProvider = Provider<SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.currentStatus;
});
