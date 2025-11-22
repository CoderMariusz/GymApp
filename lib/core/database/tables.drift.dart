import 'package:drift/drift.dart';

/// Meditation Favorites table (mirrors Supabase for offline support)
@DataClassName('MeditationFavorite')
class MeditationFavorites extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get meditationId => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Meditation Downloads table (local only - tracks downloaded audio files)
@DataClassName('MeditationDownload')
class MeditationDownloads extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get meditationId => text()();
  TextColumn get localFilePath => text()();
  DateTimeColumn get downloadedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Meditation Sessions table (mirrors Supabase for offline support)
@DataClassName('MeditationSession')
class MeditationSessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get meditationId => text()();
  IntColumn get durationListenedSeconds => integer()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Meditation Cache table (caches meditation content for offline browsing)
@DataClassName('MeditationCache')
class MeditationCaches extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  IntColumn get durationSeconds => integer()();
  TextColumn get category => text()();
  TextColumn get audioUrl => text()();
  TextColumn get thumbnailUrl => text()();
  BoolColumn get isPremium => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get cachedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
