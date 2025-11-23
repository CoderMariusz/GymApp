import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for connectivity instance
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Provider for connectivity status stream
final connectivityStatusProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.onConnectivityChanged;
});

/// Provider for checking if device is online
final isOnlineProvider = StreamProvider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.onConnectivityChanged.map(
        (result) => !result.contains(ConnectivityResult.none),
      );
});
