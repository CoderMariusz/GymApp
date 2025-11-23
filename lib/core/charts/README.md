# Chart Widgets - Reusable UI Components

Foundation layer for data visualization across LifeOS features.

## Overview

This module provides reusable chart widgets with:
- ✅ Generic data aggregation (DRY!)
- ✅ Line charts (trend visualization)
- ✅ Bar charts (comparison visualization)
- ✅ Responsive design
- ✅ Empty states
- ✅ Tooltips

## Setup

1. **Install dependencies** (already in pubspec.yaml):
   ```yaml
   dependencies:
     fl_chart: ^0.68.0
     collection: ^1.18.0
     intl: ^0.19.0
   ```

2. **Run code generation**:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

## Usage

### DataAggregator (DRY!)

Reusable for ANY time-series data:

```dart
import 'package:lifeos/core/charts/processors/data_aggregator.dart';
import 'package:lifeos/core/charts/models/chart_data.dart';

// Example: Aggregate mood data by week
final moodData = await checkInRepo.getRecentCheckIns(days: 30);

final chartData = DataAggregator.aggregateByPeriod(
  items: moodData,
  getDate: (checkIn) => checkIn.date,
  getValue: (checkIn) => checkIn.mood.toDouble(),
  period: AggregationPeriod.weekly,
  type: AggregationType.average,
);
```

### ReusableLineChart

```dart
import 'package:lifeos/core/charts/widgets/line_chart_widget.dart';

ReusableLineChart(
  data: chartData,
  title: 'Mood Trend (7 Days)',
  yAxisLabel: 'Mood (1-10)',
  lineColor: Colors.blue,
  showGrid: true,
  showDots: true,
  minY: 0,
  maxY: 10,
)
```

### ReusableBarChart

```dart
import 'package:lifeos/core/charts/widgets/bar_chart_widget.dart';

ReusableBarChart(
  data: chartData,
  title: 'Weekly Volume',
  yAxisLabel: 'Total kg',
  barColor: Colors.green,
)
```

## DataAggregator API

### Aggregation Periods
- `AggregationPeriod.daily` - Group by day
- `AggregationPeriod.weekly` - Group by week (Mon-Sun)
- `AggregationPeriod.monthly` - Group by month

### Aggregation Types
- `AggregationType.sum` - Total (e.g., workout volume)
- `AggregationType.average` - Mean (e.g., mood trend)
- `AggregationType.max` - Maximum (e.g., personal record)
- `AggregationType.min` - Minimum (e.g., lowest weight)

## Architecture

```
lib/core/charts/
├── models/
│   └── chart_data.dart          # ChartDataPoint model
├── processors/
│   └── data_aggregator.dart     # Generic aggregation (DRY!)
└── widgets/
    ├── line_chart_widget.dart   # Reusable line chart
    └── bar_chart_widget.dart    # Reusable bar chart
```

## Examples

### Fitness: Strength Progress

```dart
final workouts = await workoutRepo.getWorkoutHistory(days: 90);

final strengthData = DataAggregator.aggregateByPeriod(
  items: workouts.where((w) => w.exercise == 'Bench Press'),
  getDate: (workout) => workout.date,
  getValue: (workout) => workout.maxWeight,
  period: AggregationPeriod.weekly,
  type: AggregationType.max,
);

ReusableLineChart(
  data: strengthData,
  title: 'Bench Press Strength (12 Weeks)',
  yAxisLabel: 'Max Weight (kg)',
  lineColor: Colors.red,
)
```

### Life Coach: Goal Completion Rate

```dart
final goals = await goalsRepo.getCompletedGoals(days: 30);

final completionData = DataAggregator.aggregateByPeriod(
  items: goals,
  getDate: (goal) => goal.completedAt!,
  getValue: (_) => 1.0,  // Count each goal as 1
  period: AggregationPeriod.weekly,
  type: AggregationType.sum,
);

ReusableBarChart(
  data: completionData,
  title: 'Goals Completed (30 Days)',
  yAxisLabel: 'Goals',
  barColor: Colors.green,
)
```

## Used By

- ✅ BATCH 4: Progress Dashboard (Story 2.7) - 3 charts
- ✅ BATCH 4: Fitness Charts (Story 3.5) - 3 charts
- ✅ Future: Meditation stats, nutrition tracking, etc.

## Token Budget

- **Creation:** ~3K tokens
- **Total Saves:** ~24K tokens (6 charts × 4K each)
- **Efficiency:** 88% reusability 🎉

## Testing

```bash
flutter test test/core/charts/
```
