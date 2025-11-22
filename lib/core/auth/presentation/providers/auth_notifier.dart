import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../utils/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_with_apple_usecase.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_user_usecase.dart';
import 'auth_state.dart';

/// Auth state notifier
/// Manages authentication state and operations
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final RegisterUserUseCase _registerUseCase;
  final LoginWithEmailUseCase _loginWithEmailUseCase;
  final LoginWithGoogleUseCase _loginWithGoogleUseCase;
  final LoginWithAppleUseCase _loginWithAppleUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthNotifier({
    required AuthRepository repository,
    required RegisterUserUseCase registerUseCase,
    required LoginWithEmailUseCase loginWithEmailUseCase,
    required LoginWithGoogleUseCase loginWithGoogleUseCase,
    required LoginWithAppleUseCase loginWithAppleUseCase,
    required LogoutUseCase logoutUseCase,
  })  : _repository = repository,
        _registerUseCase = registerUseCase,
        _loginWithEmailUseCase = loginWithEmailUseCase,
        _loginWithGoogleUseCase = loginWithGoogleUseCase,
        _loginWithAppleUseCase = loginWithAppleUseCase,
        _logoutUseCase = logoutUseCase,
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

  /// Login with Google OAuth
  Future<void> loginWithGoogle() async {
    state = const AuthState.loading();

    final result = await _loginWithGoogleUseCase.call();

    result.when(
      success: (session) {
        state = AuthState.authenticated(session.user);
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

  /// Login with Apple Sign-In
  Future<void> loginWithApple() async {
    state = const AuthState.loading();

    final result = await _loginWithAppleUseCase.call();

    result.when(
      success: (session) {
        state = AuthState.authenticated(session.user);
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

    final result = await _logoutUseCase.call();

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
