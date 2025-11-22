import 'package:lifeos/core/error/result.dart';
import '../../domain/entities/auth_session_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/exceptions/auth_exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/supabase_auth_datasource.dart';

/// Implementation of AuthRepository
/// Uses SupabaseAuthDataSource for actual data operations
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseAuthDataSource _dataSource;

  const AuthRepositoryImpl(this._dataSource);

  @override
  Future<Result<UserEntity>> registerWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final userModel = await _dataSource.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );

      return Result.success(userModel.toEntity());
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownAuthException(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> registerWithGoogle() async {
    try {
      final userModel = await _dataSource.registerWithGoogle();
      return Result.success(userModel.toEntity());
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownAuthException(e.toString()));
    }
  }

  @override
  Future<Result<UserEntity>> registerWithApple() async {
    try {
      final userModel = await _dataSource.registerWithApple();
      return Result.success(userModel.toEntity());
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownAuthException(e.toString()));
    }
  }

  @override
  Future<Result<AuthSessionEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final sessionModel = await _dataSource.loginWithEmailSession(
        email: email,
        password: password,
      );

      return Result.success(sessionModel.toEntity());
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownAuthException(e.toString()));
    }
  }

  @override
  Future<Result<AuthSessionEntity>> loginWithGoogle() async {
    try {
      final sessionModel = await _dataSource.loginWithGoogleSession();
      return Result.success(sessionModel.toEntity());
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownAuthException(e.toString()));
    }
  }

  @override
  Future<Result<AuthSessionEntity>> loginWithApple() async {
    try {
      final sessionModel = await _dataSource.loginWithAppleSession();
      return Result.success(sessionModel.toEntity());
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownAuthException(e.toString()));
    }
  }

  @override
  Future<Result<AuthSessionEntity?>> getCurrentSession() async {
    try {
      final sessionModel = await _dataSource.getCurrentSession();
      return Result.success(sessionModel?.toEntity());
    } catch (e) {
      return Result.failure(
        UnknownAuthException(e.toString()),
        'Failed to get current session',
      );
    }
  }

  @override
  Future<Result<void>> sendEmailVerification(String email) async {
    try {
      await _dataSource.sendEmailVerification(email);
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownAuthException(e.toString()));
    }
  }

  @override
  Future<Result<void>> verifyEmail(String token) async {
    // Email verification is handled by Supabase automatically
    // This method is a placeholder for future implementation
    return const Result.success(null);
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await _dataSource.getCurrentUser();
      return Result.success(userModel?.toEntity());
    } catch (e) {
      return Result.failure(
        UnknownAuthException(e.toString()),
        'Failed to get current user',
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(UnknownAuthException(e.toString()));
    }
  }

  @override
  Future<Result<void>> requestPasswordReset(String email) async {
    try {
      await _dataSource.requestPasswordReset(email);
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(
        UnknownAuthException(e.toString()),
        'Failed to send password reset email',
      );
    }
  }

  @override
  Future<Result<void>> updatePassword(String newPassword) async {
    try {
      await _dataSource.updatePassword(newPassword);
      return const Result.success(null);
    } on AuthException catch (e) {
      return Result.failure(e);
    } catch (e) {
      return Result.failure(
        UnknownAuthException(e.toString()),
        'Failed to update password',
      );
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _dataSource.authStateChanges
        .map((userModel) => userModel?.toEntity());
  }
}
