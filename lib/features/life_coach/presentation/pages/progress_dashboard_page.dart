import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/charts/widgets/line_chart_widget.dart';
import '../../../../core/charts/widgets/bar_chart_widget.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';

class ProgressDashboardPage extends ConsumerWidget {
  const ProgressDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final moodTrendAsync = ref.watch(moodTrendProvider(days: 7));
    final energyTrendAsync = ref.watch(energyTrendProvider(days: 7));
    final goalCompletionAsync = ref.watch(goalCompletionProvider(days: 30));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(dashboardStatsProvider);
              ref.invalidate(moodTrendProvider);
              ref.invalidate(energyTrendProvider);
              ref.invalidate(goalCompletionProvider);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(moodTrendProvider);
          ref.invalidate(energyTrendProvider);
          ref.invalidate(goalCompletionProvider);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Overview Cards
              statsAsync.when(
                data: (stats) => _buildOverviewCards(context, stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),

              // Mood Trend Chart (REUSABLE!)
              moodTrendAsync.when(
                data: (data) => ReusableLineChart(
                  data: data,
                  title: 'Mood Trend (7 Days)',
                  yAxisLabel: 'Mood (1-10)',
                  lineColor: Colors.blue,
                  showGrid: true,
                  showDots: true,
                  minY: 0,
                  maxY: 10,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),

              // Energy Trend Chart (SAME COMPONENT!)
              energyTrendAsync.when(
                data: (data) => ReusableLineChart(
                  data: data,
                  title: 'Energy Trend (7 Days)',
                  yAxisLabel: 'Energy (1-10)',
                  lineColor: Colors.orange,
                  showGrid: true,
                  showDots: true,
                  minY: 0,
                  maxY: 10,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
              const SizedBox(height: 24),

              // Goal Completion Bar Chart
              goalCompletionAsync.when(
                data: (data) => ReusableBarChart(
                  data: data,
                  title: 'Goals Completed (30 Days)',
                  yAxisLabel: 'Goals',
                  barColor: Colors.green,
                ),
                loading: () => const CircularProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(BuildContext context, dynamic stats) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.flag,
            label: 'Active Goals',
            value: stats.activeGoals.toString(),
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.local_fire_department,
            label: 'Streak',
            value: '${stats.checkInStreak} days',
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCard(
            icon: Icons.trending_up,
            label: 'Progress',
            value: '${stats.overallProgress}%',
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}
