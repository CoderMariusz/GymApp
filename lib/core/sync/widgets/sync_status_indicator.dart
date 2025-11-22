import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/core/sync/providers/sync_status_provider.dart';

/// Widget that displays the current sync status
class SyncStatusIndicator extends ConsumerWidget {
  const SyncStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatusAsync = ref.watch(syncStatusProvider);

    return syncStatusAsync.when(
      data: (status) => _buildIndicator(status),
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const Icon(Icons.error_outline, color: Colors.red),
    );
  }

  Widget _buildIndicator(status) {
    IconData icon;
    Color color;

    if (!status.isOnline) {
      icon = Icons.cloud_off;
      color = Colors.grey;
    } else if (status.isSyncing) {
      icon = Icons.cloud_sync;
      color = Colors.blue;
    } else {
      icon = Icons.cloud_done;
      color = Colors.green;
    }

    return Tooltip(
      message: status.statusText,
      child: Icon(icon, color: color, size: 20),
    );
  }
}
