# Shared Templates Library
**Generated:** 2025-11-23
**Purpose:** Reusable templates to reduce token usage by 60-80% across story contexts

---

## How to Use This Library

When creating story contexts, **reference these templates instead of rewriting everything**:
- ✅ **Use:** "See TEMPLATE-CRUD-01 for CRUD operations"
- ✅ **Customize:** Only document what's **DIFFERENT** from the template
- ✅ **Save:** 2,000-2,500 tokens per story (60-80% reduction)

**Example:**
Instead of writing 3,000 tokens for full CRUD context, write:
```markdown
**Base Template:** TEMPLATE-CRUD-01 (User-scoped CRUD)
**Customizations:**
- Add field: `mood_score` (INTEGER 1-5)
- Validation: mood_score required
- UI: Emoji slider instead of text input
```
*Token count: ~500 tokens (83% savings!) ✅*

---

## 📐 ARCHITECTURE TEMPLATES

### TEMPLATE-ARCH-01: CRUD Pattern (Create, Read, Update, Delete)

**Use Cases:** Goals, workouts, check-ins, measurements, templates, journal entries

**Architecture:**
```
┌─────────────────────────────────────────────────────────┐
│                   CRUD ARCHITECTURE                      │
└─────────────────────────────────────────────────────────┘

USER ACTION              REPOSITORY LAYER         DATABASE
────────────────────────────────────────────────────────────
Create Entity    →    repository.create()    →  INSERT
                 ←    Result<Entity>          ←  RETURNING id

Read Entity      →    repository.getById()   →  SELECT WHERE id
                 ←    Result<Entity?>         ←  ROW | NULL

Update Entity    →    repository.update()    →  UPDATE WHERE id
                 ←    Result<Entity>          ←  RETURNING *

Delete Entity    →    repository.delete()    →  UPDATE is_deleted=true
                 ←    Result<void>            ←  (Soft delete)

List Entities    →    repository.list()      →  SELECT WHERE user_id
                 ←    Result<List<Entity>>    ←  ORDER BY created_at DESC
```

**Standard Implementation:**

```dart
// FREEZED MODEL
@freezed
class Entity with _$Entity {
  const factory Entity({
    required String id,
    required String userId,
    required String name,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _Entity;

  factory Entity.fromJson(Map<String, dynamic> json) => _$EntityFromJson(json);
}

// REPOSITORY INTERFACE
abstract class EntityRepository {
  Future<Result<Entity>> create(EntityCreate data);
  Future<Result<Entity?>> getById(String id);
  Future<Result<List<Entity>>> list({int limit = 20, int offset = 0});
  Future<Result<Entity>> update(String id, EntityUpdate data);
  Future<Result<void>> delete(String id); // Soft delete
}

// PROVIDER
@riverpod
class EntityNotifier extends _$EntityNotifier {
  @override
  FutureOr<List<Entity>> build() async {
    final repo = ref.read(entityRepositoryProvider);
    final result = await repo.list();
    return result.fold(
      onSuccess: (entities) => entities,
      onFailure: (error) => throw error,
    );
  }

  Future<void> create(EntityCreate data) async {
    state = const AsyncValue.loading();
    final repo = ref.read(entityRepositoryProvider);
    final result = await repo.create(data);
    result.fold(
      onSuccess: (entity) {
        state = AsyncValue.data([entity, ...state.value ?? []]);
      },
      onFailure: (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }

  Future<void> delete(String id) async {
    final repo = ref.read(entityRepositoryProvider);
    final result = await repo.delete(id);
    result.fold(
      onSuccess: (_) {
        state = AsyncValue.data(
          state.value?.where((e) => e.id != id).toList() ?? [],
        );
      },
      onFailure: (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }
}
```

**Standard UI Pattern:**

```dart
// LIST VIEW
class EntityListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitiesAsync = ref.watch(entityNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Entities')),
      body: entitiesAsync.when(
        data: (entities) => RefreshIndicator(
          onRefresh: () => ref.refresh(entityNotifierProvider.future),
          child: ListView.builder(
            itemCount: entities.length,
            itemBuilder: (context, index) => EntityCard(entities[index]),
          ),
        ),
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorWidget(error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/entities/create'),
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

### TEMPLATE-ARCH-02: AI Integration Pattern

**Use Cases:** Daily plan generation, CBT chat, goal suggestions, meditation recommendations, insight generation

**Architecture:**
```
┌─────────────────────────────────────────────────────────┐
│              AI INTEGRATION ARCHITECTURE                 │
└─────────────────────────────────────────────────────────┘

TRIGGER              CONTEXT AGGREGATION       AI CALL
──────────────────────────────────────────────────────────
User Action    →   Fetch user context    →   Build prompt
                   - User data                  - Template
                   - Historical data            - Context
                   - Preferences                - Examples
                   (<500ms)                     (<200ms)
                        ↓                           ↓
                   Tier Routing           →   Call AI API
                   - Free → Llama              - Stream response
                   - Std → Claude              - Parse JSON
                   - Pro → GPT-4               (<2.5s)
                        ↓                           ↓
                   Save Result            ←   Validate output
                   - Database                  - Fallback template
                   - Cache                     - Error handling
                   (<200ms)                    (<100ms)
                        ↓
                   Display UI
                   - Optimistic update
                   - Loading states
```

**Standard Implementation:**

```dart
// CONTEXT AGGREGATION
@freezed
class AIContext with _$AIContext {
  const factory AIContext({
    required String userId,
    required Map<String, dynamic> userData,
    required List<String> historicalData,
    required AIPersonality personality,
    required SubscriptionTier tier,
  }) = _AIContext;
}

class ContextAggregationService {
  Future<Result<AIContext>> aggregateContext(String userId) async {
    // Fetch data from multiple sources
    final user = await _userRepo.getById(userId);
    final history = await _historyRepo.getRecent(userId, days: 7);

    return Result.success(AIContext(
      userId: userId,
      userData: user.toJson(),
      historicalData: history.map((e) => e.toJson()).toList(),
      personality: user.aiPersonality,
      tier: user.tier,
    ));
  }
}

// AI PROMPT BUILDER
class AIPromptBuilder {
  String buildPrompt(AIContext context, String templateId) {
    final template = _templates[templateId]!;
    return template
      .replaceAll('{{userData}}', jsonEncode(context.userData))
      .replaceAll('{{personality}}', _getPersonalityPrompt(context.personality));
  }

  String _getPersonalityPrompt(AIPersonality p) {
    return switch (p) {
      AIPersonality.sage => 'Respond calmly and thoughtfully...',
      AIPersonality.momentum => 'Respond with energy and motivation...',
    };
  }
}

// AI SERVICE WITH TIER ROUTING
class AIService {
  Future<Result<AIResponse>> generate(
    String prompt,
    SubscriptionTier tier,
  ) async {
    try {
      final response = switch (tier) {
        SubscriptionTier.free => await _llamaClient.generate(prompt),
        SubscriptionTier.standard => await _claudeClient.generate(prompt),
        SubscriptionTier.premium => await _gpt4Client.generate(prompt),
      };

      return Result.success(AIResponse(
        content: response.content,
        model: response.model,
        tokensUsed: response.tokensUsed,
      ));
    } catch (e) {
      // Fallback to template
      return Result.success(_getFallbackResponse());
    }
  }
}

// PROVIDER
@riverpod
class AIGenerationNotifier extends _$AIGenerationNotifier {
  @override
  FutureOr<AIResponse?> build() => null;

  Future<void> generate(String userId) async {
    state = const AsyncValue.loading();

    // Step 1: Aggregate context
    final contextResult = await ref.read(
      contextAggregationServiceProvider,
    ).aggregateContext(userId);

    final context = contextResult.getOrThrow();

    // Step 2: Build prompt
    final prompt = ref.read(aiPromptBuilderProvider).buildPrompt(
      context,
      'daily_plan_v1',
    );

    // Step 3: Call AI
    final aiResult = await ref.read(aiServiceProvider).generate(
      prompt,
      context.tier,
    );

    aiResult.fold(
      onSuccess: (response) {
        state = AsyncValue.data(response);
      },
      onFailure: (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }
}
```

**Rate Limiting:**
```dart
class RateLimiter {
  Future<Result<void>> checkLimit(String userId, SubscriptionTier tier) async {
    final count = await _redis.get('ai:$userId:today');

    final limit = switch (tier) {
      SubscriptionTier.free => 5,
      SubscriptionTier.standard => 999999, // Unlimited
      SubscriptionTier.premium => 999999,
    };

    if (count >= limit) {
      return Result.failure(
        AppError.rateLimitExceeded('Daily limit reached'),
      );
    }

    await _redis.incr('ai:$userId:today');
    return Result.success(null);
  }
}
```

---

### TEMPLATE-ARCH-03: List + Detail View Pattern

**Use Cases:** Workouts, meditations, goals, journal entries, exercises

**Architecture:**
```
┌─────────────────────────────────────────────────────────┐
│            LIST + DETAIL VIEW ARCHITECTURE               │
└─────────────────────────────────────────────────────────┘

LIST VIEW                    DETAIL VIEW                  ACTIONS
──────────────────────────────────────────────────────────────────
ListView.builder      →   DetailScreen(id)        →   Edit/Delete
- Pull to refresh         - Hero animation             - FAB
- Pagination              - AppBar with back           - Bottom sheet
- Empty state             - ScrollView body            - Confirmations
- Loading skeleton        - Action buttons
```

**Standard Pattern:**
```dart
// LIST SCREEN
class EntityListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitiesAsync = ref.watch(entityNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Entities')),
      body: entitiesAsync.when(
        data: (entities) {
          if (entities.isEmpty) {
            return EmptyState(
              icon: Icons.inbox,
              message: 'No entities yet',
              action: () => context.push('/entities/create'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(entityNotifierProvider.future),
            child: ListView.builder(
              itemCount: entities.length,
              itemBuilder: (context, index) {
                final entity = entities[index];
                return ListTile(
                  leading: Hero(
                    tag: 'entity-${entity.id}',
                    child: Icon(Icons.star),
                  ),
                  title: Text(entity.name),
                  subtitle: Text(entity.createdAt.toFormattedString()),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () => context.push('/entities/${entity.id}'),
                );
              },
            ),
          );
        },
        loading: () => SkeletonListView(itemCount: 10),
        error: (error, _) => ErrorView(error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/entities/create'),
        child: Icon(Icons.add),
      ),
    );
  }
}

// DETAIL SCREEN
class EntityDetailScreen extends ConsumerWidget {
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entityAsync = ref.watch(entityByIdProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text('Entity Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => context.push('/entities/$id/edit'),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _showDeleteConfirmation(context, ref),
          ),
        ],
      ),
      body: entityAsync.when(
        data: (entity) => SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'entity-${entity.id}',
                child: Icon(Icons.star, size: 100),
              ),
              SizedBox(height: 24),
              Text(entity.name, style: Theme.of(context).textTheme.headlineMedium),
              SizedBox(height: 8),
              Text('Created ${entity.createdAt.toFormattedString()}'),
              // ... more details
            ],
          ),
        ),
        loading: () => SkeletonDetailView(),
        error: (error, _) => ErrorView(error),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Entity?'),
        content: Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(entityNotifierProvider.notifier).delete(id);
      if (context.mounted) {
        context.pop();
      }
    }
  }
}
```

---

## 🗄️ DATABASE TEMPLATES

### TEMPLATE-DB-01: User-Scoped Table

**Use Cases:** Goals, workouts, check-ins, journal entries, measurements

**Schema:**
```sql
CREATE TABLE entities (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- Entity-specific fields go here --
  name TEXT NOT NULL,
  description TEXT,

  -- Standard audit fields
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  is_deleted BOOLEAN DEFAULT FALSE NOT NULL
);

-- Performance indexes
CREATE INDEX idx_entities_user_id ON entities(user_id) WHERE NOT is_deleted;
CREATE INDEX idx_entities_created_at ON entities(created_at DESC);

-- RLS Policies (Row Level Security)
ALTER TABLE entities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own entities"
  ON entities FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create their own entities"
  ON entities FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own entities"
  ON entities FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own entities"
  ON entities FOR DELETE
  USING (auth.uid() = user_id);

-- Updated_at trigger
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON entities
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();
```

**Drift Schema:**
```dart
class Entities extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isDeleted => boolean().withDefault(Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
```

---

### TEMPLATE-DB-02: Timestamped Entity with Soft Delete

**Use Cases:** Any entity that needs audit trail

**Pattern:**
```sql
-- Audit fields (add to any table)
created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
updated_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
is_deleted BOOLEAN DEFAULT FALSE NOT NULL,
deleted_at TIMESTAMPTZ

-- Auto-update trigger function
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to table
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON your_table
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

-- Soft delete function
CREATE OR REPLACE FUNCTION soft_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_deleted = TRUE AND OLD.is_deleted = FALSE THEN
    NEW.deleted_at = NOW();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply soft delete trigger
CREATE TRIGGER handle_soft_delete
  BEFORE UPDATE ON your_table
  FOR EACH ROW
  EXECUTE FUNCTION soft_delete();
```

---

### TEMPLATE-DB-03: Sync Queue Pattern (Offline-First)

**Use Cases:** All entities that need offline support

**Schema:**
```sql
CREATE TABLE sync_queue (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  operation TEXT NOT NULL CHECK (operation IN ('CREATE', 'UPDATE', 'DELETE')),
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  payload JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW() NOT NULL,
  synced_at TIMESTAMPTZ,
  retry_count INTEGER DEFAULT 0,
  last_error TEXT
);

CREATE INDEX idx_sync_queue_unsynced ON sync_queue(user_id) WHERE synced_at IS NULL;
```

**Drift Implementation:**
```dart
class SyncQueue extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get operation => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get payload => text()(); // JSON string
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  IntColumn get retryCount => integer().withDefault(Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// Sync Service
class SyncService {
  Future<void> syncPendingOperations() async {
    final pending = await _database.select(_database.syncQueue)
      .where((tbl) => tbl.syncedAt.isNull())
      .get();

    for (final item in pending) {
      try {
        await _syncOperation(item);
        await _markAsSynced(item.id);
      } catch (e) {
        await _incrementRetryCount(item.id, e.toString());
      }
    }
  }
}
```

---

## 💻 CODE TEMPLATES

### TEMPLATE-CODE-01: Freezed Data Model

**Standard Pattern:**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'entity.freezed.dart';
part 'entity.g.dart';

@freezed
class Entity with _$Entity {
  const factory Entity({
    required String id,
    required String userId,
    required String name,
    String? description,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default(false) bool isDeleted,
  }) = _Entity;

  factory Entity.fromJson(Map<String, dynamic> json) => _$EntityFromJson(json);
}

// Create/Update DTOs
@freezed
class EntityCreate with _$EntityCreate {
  const factory EntityCreate({
    required String name,
    String? description,
  }) = _EntityCreate;

  factory EntityCreate.fromJson(Map<String, dynamic> json) =>
      _$EntityCreateFromJson(json);
}

@freezed
class EntityUpdate with _$EntityUpdate {
  const factory EntityUpdate({
    String? name,
    String? description,
  }) = _EntityUpdate;

  factory EntityUpdate.fromJson(Map<String, dynamic> json) =>
      _$EntityUpdateFromJson(json);
}
```

---

### TEMPLATE-CODE-02: Repository Pattern

**Standard Pattern:**
```dart
// Repository Interface
abstract class EntityRepository {
  Future<Result<Entity>> create(EntityCreate data);
  Future<Result<Entity?>> getById(String id);
  Future<Result<List<Entity>>> list({int limit = 20, int offset = 0});
  Future<Result<Entity>> update(String id, EntityUpdate data);
  Future<Result<void>> delete(String id);
}

// Repository Implementation
class EntityRepositoryImpl implements EntityRepository {
  final Database _database;
  final SupabaseClient _supabase;

  @override
  Future<Result<Entity>> create(EntityCreate data) async {
    try {
      // Local-first (Drift)
      final local = await _database.into(_database.entities).insertReturning(
        EntitiesCompanion.insert(
          id: Value(_uuid.v4()),
          userId: _currentUserId,
          name: data.name,
          description: Value(data.description),
        ),
      );

      // Queue for sync
      await _syncQueue.enqueue(
        operation: SyncOperation.create,
        entityType: 'entity',
        entityId: local.id,
        payload: data.toJson(),
      );

      return Result.success(Entity.fromDrift(local));
    } catch (e, st) {
      return Result.failure(AppError.database(e.toString(), st));
    }
  }

  @override
  Future<Result<List<Entity>>> list({int limit = 20, int offset = 0}) async {
    try {
      // Try local first
      final local = await (_database.select(_database.entities)
        ..where((tbl) => tbl.userId.equals(_currentUserId))
        ..where((tbl) => tbl.isDeleted.equals(false))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])
        ..limit(limit, offset: offset)
      ).get();

      if (local.isNotEmpty) {
        return Result.success(local.map(Entity.fromDrift).toList());
      }

      // Fallback to Supabase
      final response = await _supabase
        .from('entities')
        .select()
        .eq('user_id', _currentUserId)
        .eq('is_deleted', false)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

      final entities = (response as List)
        .map((json) => Entity.fromJson(json))
        .toList();

      // Cache locally
      await _database.batch((batch) {
        batch.insertAll(_database.entities, entities);
      });

      return Result.success(entities);
    } catch (e, st) {
      return Result.failure(AppError.network(e.toString(), st));
    }
  }
}

// Provider
@riverpod
EntityRepository entityRepository(EntityRepositoryRef ref) {
  return EntityRepositoryImpl(
    ref.read(databaseProvider),
    ref.read(supabaseClientProvider),
  );
}
```

---

### TEMPLATE-CODE-03: Riverpod AsyncNotifierProvider

**Standard Pattern:**
```dart
@riverpod
class EntityNotifier extends _$EntityNotifier {
  @override
  FutureOr<List<Entity>> build() async {
    final repo = ref.read(entityRepositoryProvider);
    final result = await repo.list();
    return result.fold(
      onSuccess: (entities) => entities,
      onFailure: (error) => throw error,
    );
  }

  Future<void> create(EntityCreate data) async {
    state = const AsyncValue.loading();
    final repo = ref.read(entityRepositoryProvider);
    final result = await repo.create(data);

    result.fold(
      onSuccess: (entity) {
        state = AsyncValue.data([entity, ...state.value ?? []]);
      },
      onFailure: (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }

  Future<void> update(String id, EntityUpdate data) async {
    final repo = ref.read(entityRepositoryProvider);
    final result = await repo.update(id, data);

    result.fold(
      onSuccess: (updated) {
        state = AsyncValue.data(
          state.value?.map((e) => e.id == id ? updated : e).toList() ?? [],
        );
      },
      onFailure: (error) {
        state = AsyncValue.error(error, StackTrace.current);
      },
    );
  }

  Future<void> delete(String id) async {
    // Optimistic update
    final previous = state.value;
    state = AsyncValue.data(
      previous?.where((e) => e.id != id).toList() ?? [],
    );

    final repo = ref.read(entityRepositoryProvider);
    final result = await repo.delete(id);

    result.fold(
      onSuccess: (_) {
        // Delete confirmed, state already updated
      },
      onFailure: (error) {
        // Rollback on error
        state = AsyncValue.data(previous ?? []);
        // Show error to user
        ref.read(toastServiceProvider).showError(error.message);
      },
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    ref.invalidateSelf();
  }
}

// Provider
final entityNotifierProvider =
  AsyncNotifierProvider<EntityNotifier, List<Entity>>(EntityNotifier.new);

// By ID Provider
@riverpod
Future<Entity?> entityById(EntityByIdRef ref, String id) async {
  final repo = ref.read(entityRepositoryProvider);
  final result = await repo.getById(id);
  return result.fold(
    onSuccess: (entity) => entity,
    onFailure: (error) => throw error,
  );
}
```

---

### TEMPLATE-CODE-04: Form Widget with Validation

**Standard Pattern:**
```dart
class EntityFormScreen extends ConsumerStatefulWidget {
  final String? entityId; // null = create, not null = edit

  @override
  ConsumerState<EntityFormScreen> createState() => _EntityFormScreenState();
}

class _EntityFormScreenState extends ConsumerState<EntityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.entityId != null) {
      _loadEntity();
    }
  }

  Future<void> _loadEntity() async {
    final entity = await ref.read(entityByIdProvider(widget.entityId!).future);
    if (entity != null) {
      _nameController.text = entity.name;
      _descriptionController.text = entity.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entityId == null ? 'Create Entity' : 'Edit Entity'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter entity name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Name is required';
                }
                if (value.length < 3) {
                  return 'Name must be at least 3 characters';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Optional description',
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(widget.entityId == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (widget.entityId == null) {
        // Create
        await ref.read(entityNotifierProvider.notifier).create(
          EntityCreate(
            name: _nameController.text,
            description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          ),
        );
      } else {
        // Update
        await ref.read(entityNotifierProvider.notifier).update(
          widget.entityId!,
          EntityUpdate(
            name: _nameController.text,
            description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          ),
        );
      }

      if (mounted) {
        context.pop();
        ref.read(toastServiceProvider).showSuccess(
          widget.entityId == null
            ? 'Entity created successfully'
            : 'Entity updated successfully',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
```

---

## 🧪 TESTING TEMPLATES

### TEMPLATE-TEST-01: Repository Unit Test

**Standard Pattern:**
```dart
void main() {
  group('EntityRepository', () {
    late EntityRepository repository;
    late MockDatabase mockDatabase;
    late MockSupabaseClient mockSupabase;

    setUp(() {
      mockDatabase = MockDatabase();
      mockSupabase = MockSupabaseClient();
      repository = EntityRepositoryImpl(mockDatabase, mockSupabase);
    });

    group('create', () {
      test('should create entity locally and queue for sync', () async {
        // Arrange
        final create = EntityCreate(name: 'Test Entity');
        when(() => mockDatabase.into(any()).insertReturning(any()))
          .thenAnswer((_) async => mockEntityRow);

        // Act
        final result = await repository.create(create);

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull()?.name, 'Test Entity');
        verify(() => mockDatabase.into(any()).insertReturning(any())).called(1);
      });

      test('should return failure on database error', () async {
        // Arrange
        when(() => mockDatabase.into(any()).insertReturning(any()))
          .thenThrow(Exception('Database error'));

        // Act
        final result = await repository.create(EntityCreate(name: 'Test'));

        // Assert
        expect(result.isFailure, true);
        expect(result.error?.type, AppErrorType.database);
      });
    });

    group('list', () {
      test('should return entities from local database', () async {
        // Arrange
        when(() => mockDatabase.select(any()).get())
          .thenAnswer((_) async => [mockEntityRow]);

        // Act
        final result = await repository.list();

        // Assert
        expect(result.isSuccess, true);
        expect(result.getOrNull()?.length, 1);
      });

      test('should fallback to Supabase when local is empty', () async {
        // Arrange
        when(() => mockDatabase.select(any()).get())
          .thenAnswer((_) async => []);
        when(() => mockSupabase.from('entities').select())
          .thenReturn(mockSupabaseQuery);

        // Act
        final result = await repository.list();

        // Assert
        verify(() => mockSupabase.from('entities').select()).called(1);
      });
    });
  });
}
```

---

### TEMPLATE-TEST-02: Provider Test

**Standard Pattern:**
```dart
void main() {
  group('EntityNotifier', () {
    late ProviderContainer container;
    late MockEntityRepository mockRepository;

    setUp(() {
      mockRepository = MockEntityRepository();
      container = ProviderContainer(
        overrides: [
          entityRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() => container.dispose());

    test('should load entities on build', () async {
      // Arrange
      final entities = [mockEntity];
      when(() => mockRepository.list())
        .thenAnswer((_) async => Result.success(entities));

      // Act
      final notifier = container.read(entityNotifierProvider.notifier);
      final state = await container.read(entityNotifierProvider.future);

      // Assert
      expect(state, entities);
      verify(() => mockRepository.list()).called(1);
    });

    test('should create entity and update state', () async {
      // Arrange
      when(() => mockRepository.list())
        .thenAnswer((_) async => Result.success([]));
      when(() => mockRepository.create(any()))
        .thenAnswer((_) async => Result.success(mockEntity));

      final notifier = container.read(entityNotifierProvider.notifier);
      await container.read(entityNotifierProvider.future);

      // Act
      await notifier.create(EntityCreate(name: 'Test'));
      final state = container.read(entityNotifierProvider).value!;

      // Assert
      expect(state.length, 1);
      expect(state.first.name, 'Test');
    });

    test('should handle create error', () async {
      // Arrange
      when(() => mockRepository.list())
        .thenAnswer((_) async => Result.success([]));
      when(() => mockRepository.create(any()))
        .thenAnswer((_) async => Result.failure(AppError.network('Failed')));

      final notifier = container.read(entityNotifierProvider.notifier);
      await container.read(entityNotifierProvider.future);

      // Act
      await notifier.create(EntityCreate(name: 'Test'));
      final state = container.read(entityNotifierProvider);

      // Assert
      expect(state.hasError, true);
    });
  });
}
```

---

### TEMPLATE-TEST-03: Widget Test

**Standard Pattern:**
```dart
void main() {
  group('EntityFormScreen', () {
    testWidgets('should show empty form when creating', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: EntityFormScreen(),
          ),
        ),
      );

      expect(find.text('Create Entity'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Create'), findsOneWidget);
    });

    testWidgets('should validate required fields', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: EntityFormScreen(),
          ),
        ),
      );

      // Tap submit without filling form
      await tester.tap(find.text('Create'));
      await tester.pump();

      // Should show validation error
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('should call create when form is valid', (tester) async {
      final mockNotifier = MockEntityNotifier();
      when(() => mockNotifier.create(any()))
        .thenAnswer((_) async => {});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            entityNotifierProvider.overrideWith(() => mockNotifier),
          ],
          child: MaterialApp(
            home: EntityFormScreen(),
          ),
        ),
      );

      // Fill form
      await tester.enterText(
        find.byType(TextFormField).first,
        'Test Entity',
      );

      // Submit
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      // Verify create was called
      verify(() => mockNotifier.create(any())).called(1);
    });
  });
}
```

---

## 🎨 UI TEMPLATES

### TEMPLATE-UI-01: List View with Pull-to-Refresh

```dart
class EntityListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entitiesAsync = ref.watch(entityNotifierProvider);

    return entitiesAsync.when(
      data: (entities) {
        if (entities.isEmpty) {
          return EmptyState(
            icon: Icons.inbox,
            title: 'No entities yet',
            message: 'Create your first entity to get started',
            actionLabel: 'Create Entity',
            onAction: () => context.push('/entities/create'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => ref.refresh(entityNotifierProvider.future),
          child: ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: entities.length,
            itemBuilder: (context, index) {
              final entity = entities[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(Icons.star),
                  ),
                  title: Text(entity.name),
                  subtitle: Text(entity.createdAt.toFormattedString()),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () => context.push('/entities/${entity.id}'),
                ),
              );
            },
          ),
        );
      },
      loading: () => SkeletonListView(itemCount: 5),
      error: (error, stack) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(entityNotifierProvider),
      ),
    );
  }
}
```

---

### TEMPLATE-UI-02: Loading/Error/Empty States

```dart
// Skeleton Loading
class SkeletonListView extends StatelessWidget {
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 150, height: 20),
                SizedBox(height: 8),
                SkeletonBox(width: double.infinity, height: 14),
                SizedBox(height: 4),
                SkeletonBox(width: 200, height: 14),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Error View
class ErrorView extends StatelessWidget {
  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: Icon(Icons.refresh),
                label: Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// Empty State
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey[400]),
            SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 📋 DEFINITION OF DONE TEMPLATE

### TEMPLATE-DOD-01: Standard Definition of Done

Use this checklist for all stories:

**Development:**
- [ ] Feature implemented according to acceptance criteria
- [ ] Code follows Dart/Flutter style guide
- [ ] No compiler warnings or errors
- [ ] Performance targets met (if specified)
- [ ] Offline support working (if applicable)

**Testing:**
- [ ] Unit tests written (>80% coverage for business logic)
- [ ] Integration tests passing
- [ ] Widget tests for UI components
- [ ] Manual testing completed
- [ ] Edge cases tested

**Documentation:**
- [ ] Code documented (complex logic explained)
- [ ] API contracts documented
- [ ] User-facing features documented

**Quality:**
- [ ] Code reviewed and approved
- [ ] No new technical debt introduced
- [ ] Accessibility checked (VoiceOver, TalkBack)
- [ ] Security considerations addressed

**Deployment:**
- [ ] Feature flag ready (if needed)
- [ ] Database migrations tested
- [ ] Analytics events added
- [ ] Error logging configured

---

## 📈 TOKEN SAVINGS ANALYSIS

### Per-Template Savings

| Template | Typical Full Context | With Template Reference | Savings |
|----------|---------------------|------------------------|---------|
| CRUD Pattern | 2,500 tokens | 500 tokens | 2,000 (80%) |
| AI Integration | 3,000 tokens | 600 tokens | 2,400 (80%) |
| List + Detail | 2,000 tokens | 400 tokens | 1,600 (80%) |
| Database Schema | 1,500 tokens | 300 tokens | 1,200 (80%) |
| Repository | 2,000 tokens | 400 tokens | 1,600 (80%) |
| Provider | 1,500 tokens | 300 tokens | 1,200 (80%) |
| Form Widget | 1,800 tokens | 400 tokens | 1,400 (78%) |
| Testing | 1,500 tokens | 300 tokens | 1,200 (80%) |

### Expected Savings Across Project

**Before Templates:**
- 60 stories × 2,500 tokens avg = 150,000 tokens

**After Templates:**
- High complexity stories (15): 800 tokens avg = 12,000 tokens
- Medium complexity stories (30): 600 tokens avg = 18,000 tokens
- Low complexity stories (15): 400 tokens avg = 6,000 tokens
- **Total: 36,000 tokens**

**Total Savings: 114,000 tokens (76% reduction!) ✅**

---

## 🎯 USAGE GUIDELINES

### When to Use Templates

✅ **USE TEMPLATES for:**
- Standard CRUD operations
- List + Detail views
- Form submissions
- User-scoped database tables
- Standard Riverpod providers
- Basic repository patterns
- Common UI patterns (loading, error, empty states)

❌ **DON'T USE TEMPLATES for:**
- Unique killer features (Smart Pattern Memory, Cross-Module Intelligence)
- Complex algorithms (correlation analysis, pattern detection)
- Security-critical features (E2E encryption, payment processing)
- Novel UX patterns (specific to your app)

### How to Reference Templates

**Good Example:**
```markdown
## Architecture

**Base Template:** TEMPLATE-ARCH-01 (CRUD Pattern)

**Customizations:**
1. Add field: `mood_score` (INTEGER 1-5, required)
2. UI: Emoji slider (😢 😞 😐 😊 😄) instead of text input
3. Validation: mood_score must be 1-5
4. Performance: Query must complete in <20ms

**Implementation differences from template:**
- Custom widget: `EmojiSlider` (see code below)
- Haptic feedback on selection
- Accessibility: VoiceOver reads "Mood: Happy, 4 out of 5"
```

**Bad Example (Don't do this):**
```markdown
## Architecture

Uses CRUD pattern.
```
*Too vague - no details on what's different!*

---

## 📝 TEMPLATE INDEX

### Quick Reference

| Template ID | Name | Use Cases |
|------------|------|-----------|
| **ARCH-01** | CRUD Pattern | Goals, workouts, check-ins |
| **ARCH-02** | AI Integration | Daily plan, CBT chat, suggestions |
| **ARCH-03** | List + Detail | All entity browsing |
| **DB-01** | User-Scoped Table | All user data |
| **DB-02** | Timestamped Entity | Audit trails |
| **DB-03** | Sync Queue | Offline support |
| **CODE-01** | Freezed Model | All data models |
| **CODE-02** | Repository | Data access layer |
| **CODE-03** | Riverpod Provider | State management |
| **CODE-04** | Form Widget | Create/edit forms |
| **TEST-01** | Repository Test | Repository unit tests |
| **TEST-02** | Provider Test | Provider unit tests |
| **TEST-03** | Widget Test | UI widget tests |
| **UI-01** | List View | Entity lists |
| **UI-02** | Loading/Error/Empty | State handling |
| **DOD-01** | Definition of Done | All stories |

---

**Document Status:** ✅ Complete
**Version:** 1.0
**Last Updated:** 2025-11-23
**Token Savings:** 76% average reduction across 60 stories
