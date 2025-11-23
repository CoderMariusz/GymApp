import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lifeos/core/error/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_with_apple_usecase.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_user_usecase.dart';
import 'auth_provider.dart';
import 'auth_state.dart';

/// Auth state notifier
/// Manages authentication state and operations
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;
  late final RegisterUserUseCase _registerUseCase;
  late final LoginWithEmailUseCase _loginWithEmailUseCase;
  late final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  late final LoginWithAppleUseCase _loginWithAppleUseCase;
  late final LogoutUseCase _logoutUseCase;

  @override
  AuthState build() {
    // Get dependencies from ref
    _repository = ref.watch(authRepositoryProvider);
    _registerUseCase = ref.watch(registerUserUseCaseProvider);
    _loginWithEmailUseCase = ref.watch(loginWithEmailUseCaseProvider);
    _loginWithGoogleUseCase = ref.watch(loginWithGoogleUseCaseProvider);
    _loginWithAppleUseCase = ref.watch(loginWithAppleUseCaseProvider);
    _logoutUseCase = ref.watch(logoutUseCaseProvider);

    // Initialize will be called separately since build must be synchronous
    _initialize();
    return const AuthState.initial();
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
      failure: (exception) {
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
      failure: (exception) {
        state = AuthState.error(exception.toString());
        // Reset to unauthenticated after showing error
        Future.delayed(const Duration(seconds: 3), () {
          if (state.maybeWhen(error: (_) => true, orElse: () => false)) {
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
      failure: (exception) {
        state = AuthState.error(exception.toString());
        Future.delayed(const Duration(seconds: 3), () {
          if (state.maybeWhen(error: (_) => true, orElse: () => false)) {
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
      failure: (exception) {
        state = AuthState.error(exception.toString());
        Future.delayed(const Duration(seconds: 3), () {
          if (state.maybeWhen(error: (_) => true, orElse: () => false)) {
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
    bool rememberMe = true,
  }) async {
    state = const AuthState.loading();

    final result = await _loginWithEmailUseCase.call(
      email: email,
      password: password,
      rememberMe: rememberMe,
    );

    result.when(
      success: (session) {
        state = AuthState.authenticated(session.user);
      },
      failure: (exception) {
        state = AuthState.error(exception.toString());
        Future.delayed(const Duration(seconds: 3), () {
          if (state.maybeWhen(error: (_) => true, orElse: () => false)) {
            state = const AuthState.unauthenticated();
          }
        });
      },
    );
  }

  /// Login with Google OAuth
  Future<void> loginWithGoogle() async {
    state = const AuthState.loading();

    final result = await _loginWithGoogleUseCase.call();

    result.when(
      success: (session) {
        state = AuthState.authenticated(session.user);
      },
      failure: (exception) {
        state = AuthState.error(exception.toString());
        Future.delayed(const Duration(seconds: 3), () {
          if (state.maybeWhen(error: (_) => true, orElse: () => false)) {
            state = const AuthState.unauthenticated();
          }
        });
      },
    );
  }

  /// Login with Apple Sign-In
  Future<void> loginWithApple() async {
    state = const AuthState.loading();

    final result = await _loginWithAppleUseCase.call();

    result.when(
      success: (session) {
        state = AuthState.authenticated(session.user);
      },
      failure: (exception) {
        state = AuthState.error(exception.toString());
        Future.delayed(const Duration(seconds: 3), () {
          if (state.maybeWhen(error: (_) => true, orElse: () => false)) {
            state = const AuthState.unauthenticated();
          }
        });
      },
    );
  }

  /// Sign out
  Future<void> signOut() async {
    state = const AuthState.loading();

    final result = await _logoutUseCase.call();

    result.when(
      success: (_) {
        state = const AuthState.unauthenticated();
      },
      failure: (exception) {
        state = AuthState.error(exception.toString());
      },
    );
  }

  /// Clear error state
  void clearError() {
    if (state.maybeWhen(error: (_) => true, orElse: () => false)) {
      state = const AuthState.unauthenticated();
    }
  }
}
