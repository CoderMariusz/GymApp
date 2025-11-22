import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lifeos/core/auth/presentation/pages/login_page.dart';
import 'package:lifeos/core/auth/presentation/pages/register_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// App Router Configuration
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/login',
    debugLogDiagnostics: true,

    // Redirect logic
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isAuthRoute =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // If not logged in and not on auth route, redirect to login
      if (!isLoggedIn && !isAuthRoute) {
        return '/login';
      }

      // If logged in and on auth route, redirect to home
      if (isLoggedIn && isAuthRoute) {
        return '/home';
      }

      return null;
    },

    // Routes
    routes: [
      // Auth Routes (Story 1.1)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Onboarding Route (Epic 7 - placeholder)
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingPlaceholder(),
      ),

      // Main App Routes (implemented in other stories)
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomePlaceholder(),
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.matchedLocation}'),
      ),
    ),
  );

  // Prevent instantiation
  AppRouter._();
}

/// Placeholder for onboarding page (to be implemented in Epic 7)
class OnboardingPlaceholder extends StatelessWidget {
  const OnboardingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Onboarding')),
      body: const Center(
        child: Text('Onboarding Flow - To be implemented in Epic 7'),
      ),
    );
  }
}

/// Placeholder for home screen (implemented in other stories)
class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LifeOS Home')),
      body: const Center(
        child: Text('Home Screen - See other feature branches'),
      ),
    );
  }
}
