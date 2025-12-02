# 🚀 BATCH 3: Data - Tracking & CRUD Operations

## 📊 Overview

**Stories:** 3
**Estimated Time:** 2-3 days
**Token Savings:** ~52% (11K tokens saved)
**Dependencies:** Base Repository, Tracking Mixin (already created)

### Stories Included:
1. **2.3** Goal Creation & Tracking (Life Coach)
2. **3.6** Body Measurements Tracking (Fitness)
3. **3.7** Workout Templates (Pre-built + Custom) (Fitness)

---

## 🎯 Implementation Strategy

**Key Pattern:** All 3 stories share CRUD + Tracking:
- Create, Read, Update, Delete operations
- Progress tracking over time
- Historical data storage
- Trend analysis

**Reusable Components (Already Created):**
- ✅ `lib/core/data/base_repository.dart`
- ✅ `lib/core/data/tracking_mixin.dart`
- ✅ `lib/core/data/history_repository.dart`

**Reusable Widgets (From Batch 1):**
- ✅ `lib/core/widgets/daily_input_form.dart`
- ✅ `lib/core/widgets/submit_button_widget.dart`

---

## 📁 File Structure

```
lib/features/
├── life_coach/
│   ├── data/
│   │   ├── datasources/
│   │   │   └── goals_local_datasource.dart          # Drift operations
│   │   ├── models/
│   │   │   ├── goal_model.dart                      # Freezed model
│   │   │   └── goal_progress_model.dart             # Progress snapshots
│   │   └── repositories/
│   │       └── goals_repository_impl.dart           # Repository + Tracking
│   ├── domain/
│   │   ├── entities/
│   │   │   ├── goal_entity.dart                     # Freezed entity
│   │   │   └── goal_progress_entity.dart            # Progress entity
│   │   ├── repositories/
│   │   │   └── goals_repository.dart                # Interface with Tracking
│   │   └── usecases/
│   │       ├── create_goal_usecase.dart
│   │       ├── update_goal_usecase.dart
│   │       ├── delete_goal_usecase.dart
│   │       ├── get_goals_usecase.dart
│   │       ├── record_goal_progress_usecase.dart
│   │       └── get_goal_stats_usecase.dart
│   └── presentation/
│       ├── pages/
│       │   ├── goals_list_page.dart                 # List view
│       │   ├── goal_detail_page.dart                # Detail + progress
│       │   ├── create_goal_page.dart                # Create/Edit form
│       │   └── goal_progress_page.dart              # Progress timeline
│       ├── providers/
│       │   └── goals_provider.dart                  # Riverpod state
│       └── widgets/
│           ├── goal_card.dart                       # List item
│           ├── goal_progress_chart.dart             # Progress visualization
│           └── milestone_badge.dart                 # Milestone indicator
│
└── fitness/
    ├── data/
    │   ├── datasources/
    │   │   ├── measurements_local_datasource.dart   # Drift operations
    │   │   └── templates_local_datasource.dart      # Drift operations
    │   ├── models/
    │   │   ├── body_measurement_model.dart          # Freezed model
    │   │   └── workout_template_model.dart          # Freezed model
    │   └── repositories/
    │       ├── measurements_repository_impl.dart    # Repository + History
    │       └── templates_repository_impl.dart       # Repository
    ├── domain/
    │   ├── entities/
    │   │   ├── body_measurement_entity.dart         # Freezed entity
    │   │   └── workout_template_entity.dart         # Freezed entity
    │   ├── repositories/
    │   │   ├── measurements_repository.dart         # Interface
    │   │   └── templates_repository.dart            # Interface
    │   └── usecases/
    │       ├── record_measurement_usecase.dart
    │       ├── get_measurement_history_usecase.dart
    │       ├── create_template_usecase.dart
    │       ├── get_templates_usecase.dart
    │       └── clone_template_usecase.dart
    └── presentation/
        ├── pages/
        │   ├── measurements_page.dart               # Story 3.6
        │   ├── measurement_history_page.dart        # History + charts
        │   ├── templates_page.dart                  # Story 3.7
        │   ├── create_template_page.dart            # Template builder
        │   └── template_detail_page.dart            # Template details
        ├── providers/
        │   ├── measurements_provider.dart           # Riverpod state
        │   └── templates_provider.dart              # Riverpod state
        └── widgets/
            ├── measurement_input_dialog.dart        # Quick input
            ├── measurement_chart.dart               # Weight/body fat chart
            ├── template_card.dart                   # Template list item
            └── exercise_template_list.dart          # Exercises in template
```

---

## 🗄️ Database Schema (Drift)

### Goals Table
```dart
class Goals extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()(); // 'fitness', 'career', 'health', etc.

  // Goal specifics
  DateTimeColumn get targetDate => dateTime().nullable()();
  RealColumn get targetValue => real().nullable()();
  TextColumn get unit => text().nullable()(); // 'kg', 'reps', 'days', etc.

  // Progress tracking
  RealColumn get currentValue => real().withDefault(const Constant(0.0))();
  IntColumn get completionPercentage => integer().withDefault(const Constant(0))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();

  // Metadata
  TextColumn get tags => text().nullable()(); // JSON array
  IntColumn get priority => integer().withDefault(const Constant(1))(); // 1-5
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

### GoalProgress Table
```dart
class GoalProgress extends Table {
  TextColumn get id => text()();
  TextColumn get goalId => text()();
  DateTimeColumn get timestamp => dateTime()();
  RealColumn get value => real()();
  TextColumn get notes => text().nullable()();
  TextColumn get metadata => text().nullable()(); // JSON
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### BodyMeasurements Table
```dart
class BodyMeasurements extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get timestamp => dateTime()();

  // Measurements (all nullable)
  RealColumn get weight => real().nullable()();
  RealColumn get bodyFat => real().nullable()();
  RealColumn get muscleMass => real().nullable()();
  RealColumn get chest => real().nullable()();
  RealColumn get waist => real().nullable()();
  RealColumn get hips => real().nullable()();
  RealColumn get biceps => real().nullable()();
  RealColumn get thighs => real().nullable()();
  RealColumn get calves => real().nullable()();

  // Photo reference
  TextColumn get photoUrl => text().nullable()();

  // Notes
  TextColumn get notes => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

### WorkoutTemplates Table
```dart
class WorkoutTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().nullable()(); // null = pre-built
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get category => text()(); // 'strength', 'cardio', 'mobility'
  TextColumn get difficulty => text()(); // 'beginner', 'intermediate', 'advanced'
  IntColumn get estimatedDuration => integer()(); // minutes

  // Template data (JSON)
  TextColumn get exercises => text()(); // JSON array of exercises

  BoolColumn get isPreBuilt => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get timesUsed => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastUsed => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

## 🔧 Implementation Steps

### Phase 1: Database & Base Layer (1 hour)

1. **Update Drift tables**
   ```dart
   // lib/core/database/tables/batch3_tables.dart
   ```

2. **Run code generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Create base implementations**
   - Test BaseRepository pattern
   - Test TrackingMixin integration
   - Test HistoryRepository pattern

---

### Phase 2: Story 2.3 - Goal Creation & Tracking (4 hours)

#### Domain Layer

**Goal Entity:**
```dart
// lib/features/life_coach/domain/entities/goal_entity.dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'goal_entity.freezed.dart';
part 'goal_entity.g.dart';

@freezed
class GoalEntity with _$GoalEntity {
  const factory GoalEntity({
    required String id,
    required String userId,
    required String title,
    String? description,
    required String category,
    DateTime? targetDate,
    double? targetValue,
    String? unit,
    @Default(0.0) double currentValue,
    @Default(0) int completionPercentage,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    List<String>? tags,
    @Default(1) int priority,
    @Default(false) bool isArchived,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _GoalEntity;

  factory GoalEntity.fromJson(Map<String, dynamic> json) =>
      _$GoalEntityFromJson(json);
}

extension GoalEntityX on GoalEntity {
  bool get hasTarget => targetValue != null && targetValue! > 0;

  double get progressPercentage {
    if (!hasTarget) return 0;
    return (currentValue / targetValue! * 100).clamp(0, 100);
  }

  bool get isOverdue {
    if (targetDate == null || isCompleted) return false;
    return DateTime.now().isAfter(targetDate!);
  }

  Duration? get timeRemaining {
    if (targetDate == null || isCompleted) return null;
    return targetDate!.difference(DateTime.now());
  }
}
```

**Goals Repository Interface:**
```dart
// lib/features/life_coach/domain/repositories/goals_repository.dart
abstract class GoalsRepository extends BaseRepository<GoalEntity, String>
    with TrackingMixin<GoalEntity, String> {

  // Additional goal-specific methods
  Future<Result<List<GoalEntity>>> getActiveGoals();
  Future<Result<List<GoalEntity>>> getCompletedGoals();
  Future<Result<List<GoalEntity>>> getGoalsByCategory(String category);
  Future<Result<void>> archiveGoal(String goalId);
  Future<Result<void>> unarchiveGoal(String goalId);
}
```

**Repository Implementation:**
```dart
// lib/features/life_coach/data/repositories/goals_repository_impl.dart
class GoalsRepositoryImpl extends BaseRepository<GoalEntity, String>
    with TrackingMixin<GoalEntity, String>
    implements GoalsRepository {

  final AppDatabase database;
  final String userId;

  GoalsRepositoryImpl({
    required this.database,
    required this.userId,
  });

  @override
  Future<Result<GoalEntity>> create(GoalEntity entity) async {
    try {
      final model = GoalModel.fromEntity(entity);
      await database.into(database.goals).insert(model.toDrift());
      return Result.success(entity);
    } catch (e) {
      return Result.failure(DatabaseException(e.toString()));
    }
  }

  @override
  Future<Result<GoalEntity>> getById(String id) async {
    try {
      final query = database.select(database.goals)
        ..where((t) => t.id.equals(id) & t.userId.equals(userId));

      final result = await query.getSingleOrNull();

      if (result == null) {
        return Result.failure(NotFoundException('Goal not found'));
      }

      return Result.success(GoalModel.fromDrift(result).toEntity());
    } catch (e) {
      return Result.failure(DatabaseException(e.toString()));
    }
  }

  @override
  Future<Result<List<GoalEntity>>> getAll({Map<String, dynamic>? params}) async {
    try {
      final query = database.select(database.goals)
        ..where((t) => t.userId.equals(userId) & t.isArchived.equals(false))
        ..orderBy([
          (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.desc),
          (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
        ]);

      final results = await query.get();

      return Result.success(
        results.map((e) => GoalModel.fromDrift(e).toEntity()).toList(),
      );
    } catch (e) {
      return Result.failure(DatabaseException(e.toString()));
    }
  }

  @override
  Future<Result<GoalEntity>> update(GoalEntity entity) async {
    try {
      final model = GoalModel.fromEntity(entity.copyWith(
        updatedAt: DateTime.now(),
      ));

      await database.update(database.goals).replace(model.toDrift());

      return Result.success(entity);
    } catch (e) {
      return Result.failure(DatabaseException(e.toString()));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await (database.delete(database.goals)
        ..where((t) => t.id.equals(id))).go();

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseException(e.toString()));
    }
  }

  // TrackingMixin implementations
  @override
  Future<Result<List<ProgressSnapshot<GoalEntity>>>> getProgressHistory(
    String goalId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = database.select(database.goalProgress)
        ..where((t) => t.goalId.equals(goalId));

      if (startDate != null) {
        query = query..where((t) => t.timestamp.isBiggerOrEqualValue(startDate));
      }

      if (endDate != null) {
        query = query..where((t) => t.timestamp.isSmallerOrEqualValue(endDate));
      }

      query = query..orderBy([(t) => OrderingTerm.asc(t.timestamp)]);

      final results = await query.get();
      final goal = await getById(goalId);

      return goal.when(
        success: (goalEntity) {
          final snapshots = results.map((progress) {
            return ProgressSnapshot<GoalEntity>(
              entity: goalEntity,
              timestamp: progress.timestamp,
              value: progress.value,
              metadata: progress.metadata != null
                  ? jsonDecode(progress.metadata!) as Map<String, dynamic>
                  : null,
            );
          }).toList();

          return Result.success(snapshots);
        },
        failure: (error) => Result.failure(error),
      );
    } catch (e) {
      return Result.failure(DatabaseException(e.toString()));
    }
  }

  @override
  Future<Result<void>> recordProgress(
    String goalId,
    Map<String, dynamic> data,
  ) async {
    try {
      final progress = GoalProgressCompanion.insert(
        id: uuid.v4(),
        goalId: goalId,
        timestamp: DateTime.now(),
        value: data['value'] as double,
        notes: Value(data['notes'] as String?),
        metadata: Value(data['metadata'] != null
            ? jsonEncode(data['metadata'])
            : null),
        createdAt: DateTime.now(),
      );

      await database.into(database.goalProgress).insert(progress);

      // Update goal's current value
      final goal = await getById(goalId);
      await goal.when(
        success: (goalEntity) async {
          final updated = goalEntity.copyWith(
            currentValue: data['value'] as double,
          );
          await update(updated);
        },
        failure: (_) {},
      );

      return Result.success(null);
    } catch (e) {
      return Result.failure(DatabaseException(e.toString()));
    }
  }

  @override
  Future<Result<double>> getProgressPercentage(String goalId) async {
    final goal = await getById(goalId);
    return goal.when(
      success: (entity) => Result.success(entity.progressPercentage),
      failure: (error) => Result.failure(error),
    );
  }

  @override
  Future<Result<List<GoalEntity>>> getActiveGoals() async {
    try {
      final query = database.select(database.goals)
        ..where((t) =>
            t.userId.equals(userId) &
            t.isCompleted.equals(false) &
            t.isArchived.equals(false))
        ..orderBy([
          (t) => OrderingTerm(expression: t.priority, mode: OrderingMode.desc),
        ]);

      final results = await query.get();

      return Result.success(
        results.map((e) => GoalModel.fromDrift(e).toEntity()).toList(),
      );
    } catch (e) {
      return Result.failure(DatabaseException(e.toString()));
    }
  }

  // ... other methods
}
```

#### Presentation Layer

**Goals List Page:**
```dart
// lib/features/life_coach/presentation/pages/goals_list_page.dart
class GoalsListPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(activeGoalsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('My Goals'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/goals/create'),
          ),
        ],
      ),
      body: goalsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.flag, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No goals yet'),
                  SizedBox(height: 8),
                  FilledButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('Create Your First Goal'),
                    onPressed: () => Navigator.pushNamed(context, '/goals/create'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              return GoalCard(
                goal: goals[index],
                onTap: () => Navigator.pushNamed(
                  context,
                  '/goals/detail',
                  arguments: goals[index].id,
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

**Goal Card Widget:**
```dart
// lib/features/life_coach/presentation/widgets/goal_card.dart
class GoalCard extends StatelessWidget {
  final GoalEntity goal;
  final VoidCallback onTap;

  const GoalCard({
    required this.goal,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (goal.description != null) ...[
                          SizedBox(height: 4),
                          Text(
                            goal.description!,
                            style: theme.textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (goal.priority >= 4)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'High Priority',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 12),

              // Progress bar
              if (goal.hasTarget) ...[
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: goal.progressPercentage / 100,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${goal.progressPercentage.toStringAsFixed(0)}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
              ],

              // Footer
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text(
                    goal.category,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (goal.targetDate != null) ...[
                    Spacer(),
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: goal.isOverdue ? Colors.red : Colors.grey,
                    ),
                    SizedBox(width: 4),
                    Text(
                      DateFormat.MMMd().format(goal.targetDate!),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: goal.isOverdue ? Colors.red : null,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Testing:**
- [ ] Can create goal
- [ ] Can view goals list
- [ ] Can update goal
- [ ] Can delete goal
- [ ] Progress tracking works
- [ ] Progress history retrieved correctly
- [ ] Progress percentage calculated correctly

---

### Phase 3: Story 3.6 - Body Measurements (2.5 hours)

**Implementation similar to Goals, but focused on historical data:**

Key files:
1. `BodyMeasurementEntity` - Multiple measurement fields
2. `MeasurementsRepository` - Implements `HistoryRepository`
3. `MeasurementsPage` - Input + history view
4. `MeasurementChart` - Line chart for weight/body fat trends

**Measurements Page:**
```dart
// lib/features/fitness/presentation/pages/measurements_page.dart
class MeasurementsPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementsAsync = ref.watch(recentMeasurementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Body Measurements'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showAddMeasurementDialog(context, ref),
          ),
        ],
      ),
      body: measurementsAsync.when(
        data: (measurements) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Weight chart
                MeasurementChart(
                  title: 'Weight Trend',
                  measurements: measurements,
                  getValue: (m) => m.weight,
                  unit: 'kg',
                ),

                // Body fat chart
                MeasurementChart(
                  title: 'Body Fat %',
                  measurements: measurements,
                  getValue: (m) => m.bodyFat,
                  unit: '%',
                ),

                // Recent measurements list
                ...measurements.map((m) => MeasurementListTile(
                  measurement: m,
                  onTap: () => _showMeasurementDetail(context, m),
                )),
              ],
            ),
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
```

**Testing:**
- [ ] Can record measurements
- [ ] History retrieved correctly
- [ ] Charts display correctly
- [ ] Trends calculated

---

### Phase 4: Story 3.7 - Workout Templates (2.5 hours)

**Templates Repository:**
- Pre-built templates (seeded in database)
- User custom templates
- Clone template functionality

**Templates Page:**
```dart
// lib/features/fitness/presentation/pages/templates_page.dart
class TemplatesPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final templatesAsync = ref.watch(workoutTemplatesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Workout Templates'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pre-Built'),
              Tab(text: 'My Templates'),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => Navigator.pushNamed(context, '/templates/create'),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // Pre-built templates
            _TemplatesList(
              templatesAsync: templatesAsync,
              filter: (t) => t.isPreBuilt,
            ),

            // User templates
            _TemplatesList(
              templatesAsync: templatesAsync,
              filter: (t) => !t.isPreBuilt,
            ),
          ],
        ),
      ),
    );
  }
}
```

**Testing:**
- [ ] Can view pre-built templates
- [ ] Can create custom template
- [ ] Can clone template
- [ ] Can use template to start workout

---

## 🧪 Testing Checklist

### Unit Tests
- [ ] Goal entity tests
- [ ] Goal repository tests
- [ ] Measurements repository tests
- [ ] Templates repository tests
- [ ] TrackingMixin tests
- [ ] Progress calculation tests

### Widget Tests
- [ ] GoalsListPage renders
- [ ] GoalCard displays correctly
- [ ] MeasurementsPage renders
- [ ] TemplatesPage renders

### Integration Tests
- [ ] E2E: Create goal, record progress, verify percentage
- [ ] E2E: Record measurements, view chart
- [ ] E2E: Create template, use template

---

## 📈 Success Metrics

- [ ] All 3 stories functional
- [ ] CRUD operations working
- [ ] Progress tracking accurate
- [ ] Historical data retrieved correctly
- [ ] Tests passing (75%+ coverage)
- [ ] BaseRepository pattern validated

---

## ⏱️ Time Breakdown

| Task | Time |
|------|------|
| Database setup | 1 hour |
| Story 2.3 (Goals) | 4 hours |
| Story 3.6 (Measurements) | 2.5 hours |
| Story 3.7 (Templates) | 2.5 hours |
| Testing | 2 hours |
| **TOTAL** | **12 hours** |

Spread across 2-3 days.

---

## 🎯 Dependencies on Batch 1

Batch 3 builds on Batch 1:
- Uses `DailyInputForm` for quick data entry
- Uses `SubmitButton` for consistent UI
- Database patterns established

Can be done in parallel with Batch 1 after shared components are complete.
