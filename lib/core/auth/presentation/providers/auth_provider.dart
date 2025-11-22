import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
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

/// Auth state provider
final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  final registerUseCase = ref.watch(registerUserUseCaseProvider);

  return AuthNotifier(
    repository: repository,
    registerUseCase: registerUseCase,
  );
});
