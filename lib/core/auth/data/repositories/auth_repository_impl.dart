import '../../../utils/result.dart';
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

      return Success(userModel.toEntity());
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'An unexpected error occurred',
      );
    }
  }

  @override
  Future<Result<UserEntity>> registerWithGoogle() async {
    try {
      final userModel = await _dataSource.registerWithGoogle();
      return Success(userModel.toEntity());
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'An unexpected error occurred',
      );
    }
  }

  @override
  Future<Result<UserEntity>> registerWithApple() async {
    try {
      final userModel = await _dataSource.registerWithApple();
      return Success(userModel.toEntity());
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'An unexpected error occurred',
      );
    }
  }

  @override
  Future<Result<UserEntity>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _dataSource.loginWithEmail(
        email: email,
        password: password,
      );

      return Success(userModel.toEntity());
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'An unexpected error occurred',
      );
    }
  }

  @override
  Future<Result<UserEntity>> loginWithGoogle() async {
    try {
      final userModel = await _dataSource.registerWithGoogle();
      return Success(userModel.toEntity());
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'An unexpected error occurred',
      );
    }
  }

  @override
  Future<Result<UserEntity>> loginWithApple() async {
    try {
      final userModel = await _dataSource.registerWithApple();
      return Success(userModel.toEntity());
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'An unexpected error occurred',
      );
    }
  }

  @override
  Future<Result<void>> sendEmailVerification(String email) async {
    try {
      await _dataSource.sendEmailVerification(email);
      return const Success(null);
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'An unexpected error occurred',
      );
    }
  }

  @override
  Future<Result<void>> verifyEmail(String token) async {
    // Email verification is handled by Supabase automatically
    // This method is a placeholder for future implementation
    return const Success(null);
  }

  @override
  Future<Result<UserEntity?>> getCurrentUser() async {
    try {
      final userModel = await _dataSource.getCurrentUser();
      return Success(userModel?.toEntity());
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'Failed to get current user',
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _dataSource.signOut();
      return const Success(null);
    } on AuthException catch (e) {
      return Failure(e, e.message);
    } catch (e) {
      return Failure(
        UnknownAuthException(e.toString()),
        'An unexpected error occurred',
      );
    }
  }

  @override
  Future<Result<void>> resetPassword(String email) async {
    // Password reset - to be implemented in Story 1.3
    return const Success(null);
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _dataSource.authStateChanges
        .map((userModel) => userModel?.toEntity());
  }
}
