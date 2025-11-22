import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../initialization/app_initializer.dart';
import '../../data/datasources/secure_storage_datasource.dart';
import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/session_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/session_repository.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/login_with_apple_usecase.dart';
import '../../domain/usecases/login_with_email_usecase.dart';
import '../../domain/usecases/login_with_google_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_user_usecase.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

/// Supabase client provider
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Supabase auth datasource provider
final supabaseAuthDataSourceProvider = Provider<SupabaseAuthDataSource>((ref) {
  final client = ref.watch(supabaseProvider);
  return SupabaseAuthDataSource(client);
});

/// Auth repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(supabaseAuthDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

/// Register user use case provider
final registerUserUseCaseProvider = Provider<RegisterUserUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterUserUseCase(repository);
});

/// Flutter secure storage provider
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
});

/// Secure storage datasource provider
final secureStorageDataSourceProvider = Provider<SecureStorageDataSource>((ref) {
  final storage = ref.watch(flutterSecureStorageProvider);
  return SecureStorageDataSource(storage);
});

/// Session repository provider
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final dataSource = ref.watch(secureStorageDataSourceProvider);
  return SessionRepositoryImpl(dataSource);
});

/// Login with email use case provider
final loginWithEmailUseCaseProvider = Provider<LoginWithEmailUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  return LoginWithEmailUseCase(authRepository, sessionRepository);
});

/// Login with Google use case provider
final loginWithGoogleUseCaseProvider = Provider<LoginWithGoogleUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  return LoginWithGoogleUseCase(authRepository, sessionRepository);
});

/// Login with Apple use case provider
final loginWithAppleUseCaseProvider = Provider<LoginWithAppleUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  return LoginWithAppleUseCase(authRepository, sessionRepository);
});

/// Check auth status use case provider
final checkAuthStatusUseCaseProvider = Provider<CheckAuthStatusUseCase>((ref) {
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  return CheckAuthStatusUseCase(sessionRepository);
});

/// Logout use case provider
final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final sessionRepository = ref.watch(sessionRepositoryProvider);
  return LogoutUseCase(authRepository, sessionRepository);
});

/// App initializer provider
final appInitializerProvider = Provider<AppInitializer>((ref) {
  final checkAuthStatusUseCase = ref.watch(checkAuthStatusUseCaseProvider);
  return AppInitializer(checkAuthStatusUseCase);
});

/// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final registerUseCase = ref.watch(registerUserUseCaseProvider);
  final loginWithEmailUseCase = ref.watch(loginWithEmailUseCaseProvider);
  final loginWithGoogleUseCase = ref.watch(loginWithGoogleUseCaseProvider);
  final loginWithAppleUseCase = ref.watch(loginWithAppleUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);

  return AuthNotifier(
    repository: repository,
    registerUseCase: registerUseCase,
    loginWithEmailUseCase: loginWithEmailUseCase,
    loginWithGoogleUseCase: loginWithGoogleUseCase,
    loginWithAppleUseCase: loginWithAppleUseCase,
    logoutUseCase: logoutUseCase,
  );
});
