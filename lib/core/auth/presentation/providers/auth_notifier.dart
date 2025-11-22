import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/register_user_usecase.dart';
import 'auth_state.dart';

/// Auth state notifier
/// Manages authentication state and operations
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final RegisterUserUseCase _registerUseCase;

  AuthNotifier({
    required AuthRepository repository,
    required RegisterUserUseCase registerUseCase,
  })  : _repository = repository,
        _registerUseCase = registerUseCase,
        super(const AuthState.initial()) {
    _initialize();
  }

  /// Initialize - check for existing session
  Future<void> _initialize() async {
    final result = await _repository.getCurrentUser();

    result.when(
      success: (user) {
        if (user != null) {
          state = AuthState.authenticated(user);
        } else {
          state = const AuthState.unauthenticated();
        }
      },
      failure: (_, __) {
        state = const AuthState.unauthenticated();
      },
    );

    // Listen to auth state changes
    _repository.authStateChanges.listen((user) {
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    });
  }

  /// Register with email and password
  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    state = const AuthState.loading();

    final result = await _registerUseCase.callWithEmail(
      email: email,
      password: password,
      name: name,
    );

    result.when(
      success: (user) {
        state = AuthState.authenticated(user);
      },
      failure: (exception, message) {
        state = AuthState.error(message);
        // Reset to unauthenticated after showing error
        Future.delayed(const Duration(seconds: 3), () {
          if (state is _Error) {
            state = const AuthState.unauthenticated();
          }
        });
      },
    );
  }

  /// Register with Google OAuth
  Future<void> registerWithGoogle() async {
    state = const AuthState.loading();

    final result = await _registerUseCase.callWithGoogle();

    result.when(
      success: (user) {
        state = AuthState.authenticated(user);
      },
      failure: (exception, message) {
        state = AuthState.error(message);
        Future.delayed(const Duration(seconds: 3), () {
          if (state is _Error) {
            state = const AuthState.unauthenticated();
          }
        });
      },
    );
  }

  /// Register with Apple Sign-In
  Future<void> registerWithApple() async {
    state = const AuthState.loading();

    final result = await _registerUseCase.callWithApple();

    result.when(
      success: (user) {
        state = AuthState.authenticated(user);
      },
      failure: (exception, message) {
        state = AuthState.error(message);
        Future.delayed(const Duration(seconds: 3), () {
          if (state is _Error) {
            state = const AuthState.unauthenticated();
          }
        });
      },
    );
  }

  /// Login with email and password
  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await _repository.loginWithEmail(
      email: email,
      password: password,
    );

    result.when(
      success: (user) {
        state = AuthState.authenticated(user);
      },
      failure: (exception, message) {
        state = AuthState.error(message);
        Future.delayed(const Duration(seconds: 3), () {
          if (state is _Error) {
            state = const AuthState.unauthenticated();
          }
        });
      },
    );
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AuthState.loading();

    final result = await _repository.signOut();

    result.when(
      success: (_) {
        state = const AuthState.unauthenticated();
      },
      failure: (exception, message) {
        state = AuthState.error(message);
      },
    );
  }

  /// Clear error state
  void clearError() {
    if (state is _Error) {
      state = const AuthState.unauthenticated();
    }
  }
}
