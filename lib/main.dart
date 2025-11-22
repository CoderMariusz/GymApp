import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifeos/core/config/supabase_config.dart';
import 'package:lifeos/core/theme/app_theme.dart';
import 'package:lifeos/core/router/app_router.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  // Run the app with Riverpod
  runApp(
    const ProviderScope(
      child: LifeOSApp(),
    ),
  );
}

/// LifeOS - Your AI-powered operating system for life
class LifeOSApp extends StatelessWidget {
  const LifeOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LifeOS',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,

      // Router
      routerConfig: AppRouter.router,
    );
  }
}
