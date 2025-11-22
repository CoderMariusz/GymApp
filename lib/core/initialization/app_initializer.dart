import '../auth/domain/usecases/check_auth_status_usecase.dart';
import '../utils/result.dart';

/// Application initializer
/// Handles app startup logic including auth status check
class AppInitializer {
  final CheckAuthStatusUseCase _checkAuthStatusUseCase;

  const AppInitializer(this._checkAuthStatusUseCase);

  /// Initialize the application
  /// Returns initial route based on auth status
  /// Must complete in <500ms for optimal UX
  Future<String> initialize() async {
    try {
      // Check if user has valid session
      final authStatusResult = await _checkAuthStatusUseCase.call();

      // If check failed or no session, go to login
      if (authStatusResult is Failure || authStatusResult is Success && (authStatusResult as Success).data == null) {
        return '/login';
      }

      // Session exists and is valid, go to home
      return '/home';
    } catch (e) {
      // On error, default to login screen
      return '/login';
    }
  }

  /// Check if user is authenticated
  /// Returns true if valid session exists
  Future<bool> isAuthenticated() async {
    try {
      final authStatusResult = await _checkAuthStatusUseCase.call();
      return authStatusResult is Success && (authStatusResult as Success).data != null;
    } catch (e) {
      return false;
    }
  }
}
