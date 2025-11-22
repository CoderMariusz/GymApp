import 'package:lifeos/core/error/result.dart';

import '../auth/domain/usecases/check_auth_status_usecase.dart';

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

      // Use pattern matching with freezed Result
      return authStatusResult.when(
        success: (session) => session != null ? '/home' : '/login',
        failure: (_) => '/login',
      );
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
      return authStatusResult.when(
        success: (session) => session != null,
        failure: (_) => false,
      );
    } catch (e) {
      return false;
    }
  }
}
