import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/auth/domain/entities/user_entity.dart';
import 'package:lifeos/core/auth/domain/exceptions/auth_exceptions.dart';
import 'package:lifeos/core/auth/domain/repositories/auth_repository.dart';
import 'package:lifeos/core/auth/domain/usecases/register_user_usecase.dart';
import 'package:lifeos/core/auth/presentation/providers/auth_notifier.dart';
import 'package:lifeos/core/auth/presentation/providers/auth_state.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockRegisterUserUseCase extends Mock implements RegisterUserUseCase {}

void main() {
  late AuthNotifier authNotifier;
  late MockAuthRepository mockRepository;
  late MockRegisterUserUseCase mockRegisterUseCase;

  final testUser = UserEntity(
    id: '123',
    email: 'test@example.com',
    name: 'Test User',
    emailVerified: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    mockRepository = MockAuthRepository();
    mockRegisterUseCase = MockRegisterUserUseCase();

    // Setup default behavior for initialization
    when(() => mockRepository.getCurrentUser())
        .thenAnswer((_) async => const Success(null));
    when(() => mockRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());

    authNotifier = AuthNotifier(
      repository: mockRepository,
      registerUseCase: mockRegisterUseCase,
    );
  });

  tearDown(() {
    authNotifier.dispose();
  });

  group('AuthNotifier - Initialization', () {
    test('should start with initial state', () {
      // Assert
      expect(authNotifier.state, const AuthState.initial());
    });

    test('should set unauthenticated state when no user is logged in',
        () async {
      // Arrange
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Success(null));
      when(() => mockRepository.authStateChanges)
          .thenAnswer((_) => const Stream.empty());

      // Act
      authNotifier = AuthNotifier(
        repository: mockRepository,
        registerUseCase: mockRegisterUseCase,
      );

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authNotifier.state, const AuthState.unauthenticated());
    });

    test('should set authenticated state when user is logged in', () async {
      // Arrange
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => Success(testUser));
      when(() => mockRepository.authStateChanges)
          .thenAnswer((_) => const Stream.empty());

      // Act
      authNotifier = AuthNotifier(
        repository: mockRepository,
        registerUseCase: mockRegisterUseCase,
      );

      // Wait for initialization
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authNotifier.state, isA<AuthState>());
      authNotifier.state.maybeWhen(
        authenticated: (user) {
          expect(user.id, testUser.id);
          expect(user.email, testUser.email);
        },
        orElse: () => fail('Expected authenticated state'),
      );
    });
  });

  group('AuthNotifier - registerWithEmail', () {
    const email = 'test@example.com';
    const password = 'ValidPass123!';
    const name = 'Test User';

    test('should set loading state and then authenticated on success',
        () async {
      // Arrange
      when(() => mockRegisterUseCase.callWithEmail(
            email: email,
            password: password,
            name: name,
          )).thenAnswer((_) async => Success(testUser));

      // Track state changes
      final states = <AuthState>[];
      authNotifier.addListener((state) => states.add(state));

      // Act
      await authNotifier.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );

      // Assert
      expect(states, [
        const AuthState.loading(),
        AuthState.authenticated(testUser),
      ]);

      verify(() => mockRegisterUseCase.callWithEmail(
            email: email,
            password: password,
            name: name,
          )).called(1);
    });

    test('should set loading state and then error on failure', () async {
      // Arrange
      const errorMessage = 'Email already exists';
      when(() => mockRegisterUseCase.callWithEmail(
            email: email,
            password: password,
            name: name,
          )).thenAnswer(
        (_) async => const Failure(
          EmailAlreadyExistsException(),
          errorMessage,
        ),
      );

      // Track state changes
      final states = <AuthState>[];
      authNotifier.addListener((state) => states.add(state));

      // Act
      await authNotifier.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );

      // Assert
      expect(states[0], const AuthState.loading());
      expect(states[1], const AuthState.error(errorMessage));
    });

    test('should auto-clear error state after 3 seconds', () async {
      // Arrange
      when(() => mockRegisterUseCase.callWithEmail(
            email: email,
            password: password,
            name: name,
          )).thenAnswer(
        (_) async => const Failure(
          WeakPasswordException(),
          'Weak password',
        ),
      );

      // Act
      await authNotifier.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );

      // Should be in error state
      expect(authNotifier.state, const AuthState.error('Weak password'));

      // Wait for auto-clear
      await Future.delayed(const Duration(seconds: 4));

      // Should be unauthenticated
      expect(authNotifier.state, const AuthState.unauthenticated());
    });
  });

  group('AuthNotifier - registerWithGoogle', () {
    test('should set loading state and then authenticated on success',
        () async {
      // Arrange
      when(() => mockRegisterUseCase.callWithGoogle())
          .thenAnswer((_) async => Success(testUser));

      // Track state changes
      final states = <AuthState>[];
      authNotifier.addListener((state) => states.add(state));

      // Act
      await authNotifier.registerWithGoogle();

      // Assert
      expect(states, [
        const AuthState.loading(),
        AuthState.authenticated(testUser),
      ]);

      verify(() => mockRegisterUseCase.callWithGoogle()).called(1);
    });

    test('should handle OAuth cancelled error', () async {
      // Arrange
      when(() => mockRegisterUseCase.callWithGoogle()).thenAnswer(
        (_) async => const Failure(
          OAuthCancelledException(),
          'Sign in cancelled',
        ),
      );

      // Act
      await authNotifier.registerWithGoogle();

      // Assert
      expect(authNotifier.state, const AuthState.error('Sign in cancelled'));
    });

    test('should handle OAuth failed error', () async {
      // Arrange
      when(() => mockRegisterUseCase.callWithGoogle()).thenAnswer(
        (_) async => const Failure(
          OAuthFailedException(),
          'Sign in failed. Please try again.',
        ),
      );

      // Act
      await authNotifier.registerWithGoogle();

      // Assert
      expect(
        authNotifier.state,
        const AuthState.error('Sign in failed. Please try again.'),
      );
    });
  });

  group('AuthNotifier - registerWithApple', () {
    test('should set loading state and then authenticated on success',
        () async {
      // Arrange
      when(() => mockRegisterUseCase.callWithApple())
          .thenAnswer((_) async => Success(testUser));

      // Track state changes
      final states = <AuthState>[];
      authNotifier.addListener((state) => states.add(state));

      // Act
      await authNotifier.registerWithApple();

      // Assert
      expect(states, [
        const AuthState.loading(),
        AuthState.authenticated(testUser),
      ]);

      verify(() => mockRegisterUseCase.callWithApple()).called(1);
    });

    test('should handle Apple Sign-In errors', () async {
      // Arrange
      when(() => mockRegisterUseCase.callWithApple()).thenAnswer(
        (_) async => const Failure(
          OAuthCancelledException(),
          'Sign in cancelled',
        ),
      );

      // Act
      await authNotifier.registerWithApple();

      // Assert
      expect(authNotifier.state, const AuthState.error('Sign in cancelled'));
    });
  });

  group('AuthNotifier - loginWithEmail', () {
    const email = 'test@example.com';
    const password = 'ValidPass123!';

    test('should set loading state and then authenticated on success',
        () async {
      // Arrange
      when(() => mockRepository.loginWithEmail(
            email: email,
            password: password,
          )).thenAnswer((_) async => Success(testUser));

      // Track state changes
      final states = <AuthState>[];
      authNotifier.addListener((state) => states.add(state));

      // Act
      await authNotifier.loginWithEmail(
        email: email,
        password: password,
      );

      // Assert
      expect(states, [
        const AuthState.loading(),
        AuthState.authenticated(testUser),
      ]);

      verify(() => mockRepository.loginWithEmail(
            email: email,
            password: password,
          )).called(1);
    });

    test('should handle invalid credentials error', () async {
      // Arrange
      when(() => mockRepository.loginWithEmail(
            email: email,
            password: password,
          )).thenAnswer(
        (_) async => const Failure(
          InvalidCredentialsException(),
          'Invalid email or password',
        ),
      );

      // Act
      await authNotifier.loginWithEmail(
        email: email,
        password: password,
      );

      // Assert
      expect(
        authNotifier.state,
        const AuthState.error('Invalid email or password'),
      );
    });
  });

  group('AuthNotifier - signOut', () {
    test('should set loading state and then unauthenticated on success',
        () async {
      // Arrange
      when(() => mockRepository.signOut())
          .thenAnswer((_) async => const Success(null));

      // Track state changes
      final states = <AuthState>[];
      authNotifier.addListener((state) => states.add(state));

      // Act
      await authNotifier.signOut();

      // Assert
      expect(states, [
        const AuthState.loading(),
        const AuthState.unauthenticated(),
      ]);

      verify(() => mockRepository.signOut()).called(1);
    });

    test('should set error state when sign out fails', () async {
      // Arrange
      when(() => mockRepository.signOut()).thenAnswer(
        (_) async => const Failure(
          UnknownAuthException('Sign out failed'),
          'Sign out failed',
        ),
      );

      // Act
      await authNotifier.signOut();

      // Assert
      expect(authNotifier.state, const AuthState.error('Sign out failed'));
    });
  });

  group('AuthNotifier - clearError', () {
    test('should clear error state to unauthenticated', () {
      // Arrange
      authNotifier.state = const AuthState.error('Test error');

      // Act
      authNotifier.clearError();

      // Assert
      expect(authNotifier.state, const AuthState.unauthenticated());
    });

    test('should not change state if not in error', () {
      // Arrange
      authNotifier.state = const AuthState.loading();

      // Act
      authNotifier.clearError();

      // Assert
      expect(authNotifier.state, const AuthState.loading());
    });
  });

  group('AuthNotifier - authStateChanges stream', () {
    test('should update state when auth state changes', () async {
      // Arrange
      final streamController = StreamController<UserEntity?>();
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => const Success(null));
      when(() => mockRepository.authStateChanges)
          .thenAnswer((_) => streamController.stream);

      authNotifier = AuthNotifier(
        repository: mockRepository,
        registerUseCase: mockRegisterUseCase,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Act - emit authenticated user
      streamController.add(testUser);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authNotifier.state, isA<AuthState>());
      authNotifier.state.maybeWhen(
        authenticated: (user) => expect(user.id, testUser.id),
        orElse: () => fail('Expected authenticated state'),
      );

      // Act - emit null (sign out)
      streamController.add(null);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(authNotifier.state, const AuthState.unauthenticated());

      streamController.close();
    });
  });
}

// Helper extension for testing
extension _StateNotifierTest on AuthNotifier {
  void addListener(void Function(AuthState state) listener) {
    // This is a simplified version for testing
    // In real implementation, you would use addListener from StateNotifier
  }

  set state(AuthState newState) {
    // Setter for testing purposes
    // In real implementation, this would be protected
  }
}
