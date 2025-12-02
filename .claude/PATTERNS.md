# PATTERNS - Wzorce kodu GymApp

> Kopiuj te wzorce zamiast szukać podobnego kodu w projekcie.

---

## Clean Architecture Structure

```
lib/features/{feature_name}/
├── data/
│   ├── datasources/
│   │   ├── {feature}_local_datasource.dart   # Drift operations
│   │   └── {feature}_remote_datasource.dart  # Supabase operations
│   ├── models/
│   │   └── {feature}_model.dart              # JSON serialization
│   └── repositories/
│       └── {feature}_repository_impl.dart    # Implements interface
├── domain/
│   ├── entities/
│   │   └── {feature}_entity.dart             # Pure domain object
│   ├── repositories/
│   │   └── {feature}_repository.dart         # Interface (abstract)
│   └── usecases/
│       └── {verb}_{noun}_usecase.dart        # Single responsibility
└── presentation/
    ├── pages/
    │   └── {feature}_page.dart               # Screen widget
    ├── providers/
    │   └── {feature}_provider.dart           # Riverpod state
    └── widgets/
        └── {feature}_widget.dart             # Reusable UI
```

---

## Riverpod Provider (riverpod_annotation)

### AsyncNotifier Pattern
```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '{feature}_provider.g.dart';

@riverpod
class FeatureNotifier extends _$FeatureNotifier {
  @override
  Future<FeatureState> build() async {
    final repository = ref.watch(featureRepositoryProvider);
    return repository.getInitialData();
  }

  Future<void> doSomething(String param) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(featureRepositoryProvider);
      return repository.performAction(param);
    });
  }
}
```

### Simple Provider
```dart
@riverpod
Future<List<Item>> items(ItemsRef ref) async {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.getAll();
}
```

### Provider with Parameter
```dart
@riverpod
Future<Item?> itemById(ItemByIdRef ref, String id) async {
  final repository = ref.watch(itemRepositoryProvider);
  return repository.getById(id);
}
```

---

## Repository Pattern

### Interface (Domain)
```dart
abstract class FeatureRepository {
  Future<List<Entity>> getAll();
  Future<Entity?> getById(String id);
  Future<void> save(Entity entity);
  Future<void> delete(String id);
}
```

### Implementation (Data)
```dart
class FeatureRepositoryImpl implements FeatureRepository {
  final AppDatabase _db;
  final SupabaseClient _supabase;

  FeatureRepositoryImpl(this._db, this._supabase);

  @override
  Future<List<Entity>> getAll() async {
    // Offline-first: read from Drift
    final localData = await _db.select(_db.featureTable).get();
    return localData.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> save(Entity entity) async {
    // Write to Drift first
    await _db.into(_db.featureTable).insertOnConflictUpdate(
      entity.toCompanion(),
    );
    // Queue for sync
    // ... sync logic
  }
}
```

---

## UseCase Pattern

```dart
class GetItemsUsecase {
  final FeatureRepository _repository;

  GetItemsUsecase(this._repository);

  Future<List<Entity>> call({String? filter}) async {
    final items = await _repository.getAll();
    if (filter != null) {
      return items.where((e) => e.category == filter).toList();
    }
    return items;
  }
}
```

---

## Drift Table Definition

```dart
@DataClassName('FeatureData')
class FeatureTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get metadataJson => text().named('metadata_json').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at').withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();

  // Sync metadata (standard)
  BoolColumn get isSynced => boolean().named('is_synced').withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().named('last_synced_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{userId, title}]; // Optional
}
```

---

## Page Widget Pattern

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeaturePage extends ConsumerWidget {
  const FeaturePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(featureNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature'),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (data) => _buildContent(context, ref, data),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, FeatureState data) {
    return ListView.builder(
      itemCount: data.items.length,
      itemBuilder: (context, index) => _buildItem(data.items[index]),
    );
  }

  Widget _buildItem(Item item) {
    return ListTile(
      title: Text(item.title),
      subtitle: Text(item.description ?? ''),
    );
  }
}
```

---

## AI Service Call Pattern

```dart
// Using AIService
final aiService = ref.read(aiServiceProvider);

final response = await aiService.chat(
  AIRequest(
    messages: [
      AIMessage(role: 'system', content: 'You are a life coach...'),
      AIMessage(role: 'user', content: userMessage),
    ],
    model: 'gpt-4o-mini',
    maxTokens: 500,
  ),
);

if (response.isSuccess) {
  final content = response.content;
  // Process AI response
} else {
  // Handle error
  throw response.error!;
}
```

---

## GoRouter Route Definition

```dart
// lib/core/router/app_router.dart

GoRoute(
  path: '/feature',
  name: 'feature',
  builder: (context, state) => const FeaturePage(),
  routes: [
    GoRoute(
      path: 'detail/:id',
      name: 'feature-detail',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return FeatureDetailPage(id: id);
      },
    ),
  ],
),
```

---

## Error Handling Pattern

```dart
// lib/core/error/result.dart - używaj Result<T, Failure>

Future<Result<Entity, Failure>> safeOperation() async {
  try {
    final data = await repository.getData();
    return Result.success(data);
  } on NetworkException catch (e) {
    return Result.failure(NetworkFailure(e.message));
  } on DatabaseException catch (e) {
    return Result.failure(DatabaseFailure(e.message));
  } catch (e) {
    return Result.failure(UnknownFailure(e.toString()));
  }
}
```

---

## Form Validation Pattern

```dart
class FormValidators {
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'To pole jest wymagane';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Nieprawidłowy adres email';
    }
    return null;
  }

  static String? minLength(String? value, int min) {
    if (value == null || value.length < min) {
      return 'Minimum $min znaków';
    }
    return null;
  }
}
```

---

## Naming Conventions

| Element | Format | Przykład |
|---------|--------|----------|
| File | snake_case | `daily_plan_provider.dart` |
| Class | PascalCase | `DailyPlanProvider` |
| Variable/Method | camelCase | `getDailyPlan()` |
| Constant | camelCase | `const defaultTimeout = 30` |
| Enum value | camelCase | `LoadingState.inProgress` |
| Provider | camelCase + Provider | `dailyPlanNotifierProvider` |
| Table | PascalCase + Table | `DailyPlansTable` |

---

*Kopiuj, dostosuj, używaj.*
