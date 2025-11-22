import '../../../utils/result.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/secure_storage_datasource.dart';
import '../models/auth_session_model.dart';

/// Implementation of SessionRepository
/// Uses SecureStorageDataSource for actual storage operations
class SessionRepositoryImpl implements SessionRepository {
  final SecureStorageDataSource _dataSource;

  const SessionRepositoryImpl(this._dataSource);

  @override
  Future<Result<void>> saveSession(AuthSessionEntity session) async {
    try {
      final model = AuthSessionModel.fromEntity(session);

      await _dataSource.saveSession(
        accessToken: model.accessToken,
        refreshToken: model.refreshToken,
        expiresAt: model.expiresAt,
        userData: model.user.toJson(),
      );

      return const Success(null);
    } catch (e) {
      return Failure(
        Exception('Failed to save session'),
        'Failed to save session: $e',
      );
    }
  }

  @override
  Future<Result<AuthSessionEntity?>> loadSession() async {
    try {
      final data = await _dataSource.loadSession();

      if (data == null) {
        return const Success(null);
      }

      final model = AuthSessionModel.fromJson({
        'accessToken': data['accessToken'],
        'refreshToken': data['refreshToken'],
        'expiresAt': (data['expiresAt'] as DateTime).toIso8601String(),
        'user': data['userData'],
      });

      return Success(model.toEntity());
    } catch (e) {
      return Failure(
        Exception('Failed to load session'),
        'Failed to load session: $e',
      );
    }
  }

  @override
  Future<Result<void>> deleteSession() async {
    try {
      await _dataSource.deleteSession();
      return const Success(null);
    } catch (e) {
      return Failure(
        Exception('Failed to delete session'),
        'Failed to delete session: $e',
      );
    }
  }

  @override
  Future<Result<void>> saveRememberMePreference(bool rememberMe) async {
    try {
      await _dataSource.saveRememberMePreference(rememberMe);
      return const Success(null);
    } catch (e) {
      return Failure(
        Exception('Failed to save preference'),
        'Failed to save remember me preference: $e',
      );
    }
  }

  @override
  Future<Result<bool>> loadRememberMePreference() async {
    try {
      final rememberMe = await _dataSource.loadRememberMePreference();
      return Success(rememberMe);
    } catch (e) {
      // Default to true on error
      return const Success(true);
    }
  }

  @override
  Future<Result<void>> clearAll() async {
    try {
      await _dataSource.clearAll();
      return const Success(null);
    } catch (e) {
      return Failure(
        Exception('Failed to clear all data'),
        'Failed to clear all data: $e',
      );
    }
  }
}
