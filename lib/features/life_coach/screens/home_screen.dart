import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lifeos/core/theme/app_theme.dart';

/// Home Screen - Life Coach Dashboard
/// Main screen after login, shows overview of Life Coach module
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('LifeOS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Text(
                'Welcome back!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                user?.userMetadata?['full_name'] ?? user?.email ?? 'User',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),

              const SizedBox(height: 32),

              // Quick Actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Action Cards
              _QuickActionCard(
                icon: Icons.wb_sunny_outlined,
                title: 'Morning Check-in',
                subtitle: 'Start your day with intention',
                color: AppTheme.energeticTeal,
                onTap: () {
                  // TODO: Navigate to morning check-in
                },
              ),
              const SizedBox(height: 12),

              _QuickActionCard(
                icon: Icons.fitness_center_outlined,
                title: 'Log Workout',
                subtitle: 'Track your fitness progress',
                color: AppTheme.fitnessOrange,
                onTap: () {
                  // TODO: Navigate to workout logging
                },
              ),
              const SizedBox(height: 12),

              _QuickActionCard(
                icon: Icons.self_improvement_outlined,
                title: 'Meditate',
                subtitle: 'Find your calm',
                color: AppTheme.mindPurple,
                onTap: () {
                  // TODO: Navigate to meditation
                },
              ),

              const SizedBox(height: 32),

              // Modules Section
              Text(
                'Your Modules',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),

              // Module Cards
              Row(
                children: [
                  Expanded(
                    child: _ModuleCard(
                      icon: Icons.psychology_outlined,
                      title: 'Life Coach',
                      subtitle: 'Active',
                      color: AppTheme.deepBlue,
                      isActive: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ModuleCard(
                      icon: Icons.fitness_center_outlined,
                      title: 'Fitness',
                      subtitle: 'Free Trial',
                      color: AppTheme.fitnessOrange,
                      isActive: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ModuleCard(
                      icon: Icons.self_improvement_outlined,
                      title: 'Mind',
                      subtitle: 'Free Trial',
                      color: AppTheme.mindPurple,
                      isActive: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: SizedBox()), // Placeholder
                ],
              ),

              const SizedBox(height: 32),

              // Today's Insight (placeholder)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outlined,
                            color: AppTheme.energeticTeal,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Today's Insight",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Start tracking your activities to receive personalized insights from our Cross-Module Intelligence engine.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Navigation (placeholder)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.deepBlue,
        unselectedItemColor: AppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Fitness',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.self_improvement_outlined),
            activeIcon: Icon(Icons.self_improvement),
            label: 'Mind',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

/// Quick Action Card Widget
class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Module Card Widget
class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isActive;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isActive ? AppTheme.success : AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
