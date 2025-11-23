import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'database.dart';

part 'database_providers.g.dart';

/// Central database provider
/// Used throughout the app to access the local database
@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}
