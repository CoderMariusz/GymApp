import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lifeos/core/sync/providers/sync_status_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget that initializes sync service when user is authenticated
class SyncInitializer extends ConsumerStatefulWidget {
  final Widget child;

  const SyncInitializer({required this.child, super.key});

  @override
  ConsumerState<SyncInitializer> createState() => _SyncInitializerState();
}

class _SyncInitializerState extends ConsumerState<SyncInitializer> with WidgetsBindingObserver {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeSync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeSync();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final syncService = ref.read(syncServiceProvider);

    switch (state) {
      case AppLifecycleState.resumed:
        // App came to foreground - trigger sync
        syncService.sync();
        break;
      case AppLifecycleState.paused:
        // App going to background - no action needed
        break;
      case AppLifecycleState.detached:
        // App is terminating
        _disposeSync();
        break;
      default:
        break;
    }
  }

  Future<void> _initializeSync() async {
    if (_initialized) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final syncService = ref.read(syncServiceProvider);
      await syncService.initialize(user.id);
      setState(() {
        _initialized = true;
      });
    }
  }

  Future<void> _disposeSync() async {
    if (_initialized) {
      final syncService = ref.read(syncServiceProvider);
      await syncService.dispose();
      setState(() {
        _initialized = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    final authState = Supabase.instance.client.auth.onAuthStateChange;
    authState.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        _initializeSync();
      } else if (event == AuthChangeEvent.signedOut) {
        _disposeSync();
      }
    });

    return widget.child;
  }
}
