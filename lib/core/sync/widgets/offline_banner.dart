import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/core/sync/providers/connectivity_provider.dart';

/// Banner that appears when the device is offline
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(isOnlineProvider);

    return isOnlineAsync.when(
      data: (isOnline) {
        if (isOnline) return const SizedBox.shrink();

        return MaterialBanner(
          backgroundColor: Colors.orange.shade100,
          leading: const Icon(Icons.wifi_off, color: Colors.orange),
          content: const Text(
            'You are offline. Changes will sync when connection is restored.',
            style: TextStyle(color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Dismiss banner (optional)
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
