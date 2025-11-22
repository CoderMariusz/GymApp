import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/auth/data/datasources/supabase_auth_datasource.dart';
import 'package:lifeos/core/auth/data/models/user_model.dart';
import 'package:lifeos/core/auth/data/repositories/auth_repository_impl.dart';
import 'package:lifeos/core/auth/domain/entities/user_entity.dart';
import 'package:lifeos/core/auth/domain/exceptions/auth_exceptions.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:mocktail/mocktail.dart';

class MockSupabaseAuthDataSource extends Mock
    implements SupabaseAuthDataSource {}

void main() {
  late AuthRepositoryImpl repository;
  late MockSupabaseAuthDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockSupabaseAuthDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  final testUserModel = UserModel(
    id: '123',
    email: 'test@example.com',
    name: 'Test User',
    emailVerified: false,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('AuthRepositoryImpl - registerWithEmail', () {
    const email = 'test@example.com';
    const password = 'ValidPass123!';
    const name = 'Test User';

    test('should return Success with UserEntity when registration succeeds',
        () async {
      // Arrange
      when(() => mockDataSource.registerWithEmail(
            email: email,
            password: password,
            name: name,
          )).thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );

      // Assert
      expect(result, isA<Success<UserEntity>>());
      expect(result.isSuccess, true);
      final userEntity = (result as Success<UserEntity>).value;
      expect(userEntity.email, email);
      expect(userEntity.name, name);

      verify(() => mockDataSource.registerWithEmail(
            email: email,
            password: password,
            name: name,
          )).called(1);
    });

    test('should return Failure when email already exists', () async {
      // Arrange
      when(() => mockDataSource.registerWithEmail(
            email: email,
            password: password,
            name: name,
          )).thenThrow(const EmailAlreadyExistsException());

      // Act
      final result = await repository.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );

      // Assert
      expect(result, isA<Failure<UserEntity>>());
      expect(result.isFailure, true);
      final failure = result as Failure<UserEntity>;
      expect(failure.exception, isA<EmailAlreadyExistsException>());
      expect(failure.message, contains('already registered'));
    });

    test('should return Failure when network error occurs', () async {
      // Arrange
      when(() => mockDataSource.registerWithEmail(
            email: email,
            password: password,
            name: name,
          )).thenThrow(const NetworkException());

      // Act
      final result = await repository.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );

      // Assert
      expect(result, isA<Failure<UserEntity>>());
      final failure = result as Failure<UserEntity>;
      expect(failure.exception, isA<NetworkException>());
      expect(failure.message, contains('Connection failed'));
    });

    test('should return Failure with UnknownAuthException for unexpected errors',
        () async {
      // Arrange
      when(() => mockDataSource.registerWithEmail(
            email: email,
            password: password,
            name: name,
          )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.registerWithEmail(
        email: email,
        password: password,
        name: name,
      );

      // Assert
      expect(result, isA<Failure<UserEntity>>());
      final failure = result as Failure<UserEntity>;
      expect(failure.exception, isA<UnknownAuthException>());
    });
  });

  group('AuthRepositoryImpl - registerWithGoogle', () {
    test('should return Success with UserEntity when Google OAuth succeeds',
        () async {
      // Arrange
      final googleUser = testUserModel.copyWith(
        email: 'test@gmail.com',
        emailVerified: true,
      );

      when(() => mockDataSource.registerWithGoogle())
          .thenAnswer((_) async => googleUser);

      // Act
      final result = await repository.registerWithGoogle();

      // Assert
      expect(result, isA<Success<UserEntity>>());
      final userEntity = (result as Success<UserEntity>).value;
      expect(userEntity.emailVerified, true);
      expect(userEntity.email, contains('gmail.com'));

      verify(() => mockDataSource.registerWithGoogle()).called(1);
    });

    test('should return Failure when OAuth is cancelled', () async {
      // Arrange
      when(() => mockDataSource.registerWithGoogle())
          .thenThrow(const OAuthCancelledException());

      // Act
      final result = await repository.registerWithGoogle();

      // Assert
      expect(result, isA<Failure<UserEntity>>());
      final failure = result as Failure<UserEntity>;
      expect(failure.exception, isA<OAuthCancelledException>());
    });

    test('should return Failure when OAuth fails', () async {
      // Arrange
      when(() => mockDataSource.registerWithGoogle())
          .thenThrow(const OAuthFailedException());

      // Act
      final result = await repository.registerWithGoogle();

      // Assert
      expect(result, isA<Failure<UserEntity>>());
      final failure = result as Failure<UserEntity>;
      expect(failure.exception, isA<OAuthFailedException>());
    });
  });

  group('AuthRepositoryImpl - registerWithApple', () {
    test('should return Success with UserEntity when Apple Sign-In succeeds',
        () async {
      // Arrange
      final appleUser = testUserModel.copyWith(
        email: 'test@privaterelay.appleid.com',
        emailVerified: true,
      );

      when(() => mockDataSource.registerWithApple())
          .thenAnswer((_) async => appleUser);

      // Act
      final result = await repository.registerWithApple();

      // Assert
      expect(result, isA<Success<UserEntity>>());
      final userEntity = (result as Success<UserEntity>).value;
      expect(userEntity.emailVerified, true);

      verify(() => mockDataSource.registerWithApple()).called(1);
    });

    test('should return Failure when Apple Sign-In is cancelled', () async {
      // Arrange
      when(() => mockDataSource.registerWithApple())
          .thenThrow(const OAuthCancelledException());

      // Act
      final result = await repository.registerWithApple();

      // Assert
      expect(result, isA<Failure<UserEntity>>());
      final failure = result as Failure<UserEntity>;
      expect(failure.exception, isA<OAuthCancelledException>());
    });
  });

  group('AuthRepositoryImpl - loginWithEmail', () {
    const email = 'test@example.com';
    const password = 'ValidPass123!';

    test('should return Success with UserEntity when login succeeds',
        () async {
      // Arrange
      when(() => mockDataSource.loginWithEmail(
            email: email,
            password: password,
          )).thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.loginWithEmail(
        email: email,
        password: password,
      );

      // Assert
      expect(result, isA<Success<UserEntity>>());
      final userEntity = (result as Success<UserEntity>).value;
      expect(userEntity.email, email);

      verify(() => mockDataSource.loginWithEmail(
            email: email,
            password: password,
          )).called(1);
    });

    test('should return Failure when credentials are invalid', () async {
      // Arrange
      when(() => mockDataSource.loginWithEmail(
            email: email,
            password: password,
          )).thenThrow(const InvalidCredentialsException());

      // Act
      final result = await repository.loginWithEmail(
        email: email,
        password: password,
      );

      // Assert
      expect(result, isA<Failure<UserEntity>>());
      final failure = result as Failure<UserEntity>;
      expect(failure.exception, isA<InvalidCredentialsException>());
    });

    test('should return Failure when user not found', () async {
      // Arrange
      when(() => mockDataSource.loginWithEmail(
            email: email,
            password: password,
          )).thenThrow(const UserNotFoundException());

      // Act
      final result = await repository.loginWithEmail(
        email: email,
        password: password,
      );

      // Assert
      expect(result, isA<Failure<UserEntity>>());
      final failure = result as Failure<UserEntity>;
      expect(failure.exception, isA<UserNotFoundException>());
    });
  });

  group('AuthRepositoryImpl - getCurrentUser', () {
    test('should return Success with UserEntity when user is logged in',
        () async {
      // Arrange
      when(() => mockDataSource.getCurrentUser())
          .thenAnswer((_) async => testUserModel);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, isA<Success<UserEntity?>>());
      final userEntity = (result as Success<UserEntity?>).value;
      expect(userEntity, isNotNull);
      expect(userEntity!.id, testUserModel.id);

      verify(() => mockDataSource.getCurrentUser()).called(1);
    });

    test('should return Success with null when no user is logged in',
        () async {
      // Arrange
      when(() => mockDataSource.getCurrentUser())
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, isA<Success<UserEntity?>>());
      final userEntity = (result as Success<UserEntity?>).value;
      expect(userEntity, isNull);
    });

    test('should return Failure when error occurs', () async {
      // Arrange
      when(() => mockDataSource.getCurrentUser())
          .thenThrow(Exception('Failed to get user'));

      // Act
      final result = await repository.getCurrentUser();

      // Assert
      expect(result, isA<Failure<UserEntity?>>());
    });
  });

  group('AuthRepositoryImpl - signOut', () {
    test('should return Success when sign out succeeds', () async {
      // Arrange
      when(() => mockDataSource.signOut()).thenAnswer((_) async {});

      // Act
      final result = await repository.signOut();

      // Assert
      expect(result, isA<Success<void>>());
      verify(() => mockDataSource.signOut()).called(1);
    });

    test('should return Failure when sign out fails', () async {
      // Arrange
      when(() => mockDataSource.signOut())
          .thenThrow(Exception('Sign out failed'));

      // Act
      final result = await repository.signOut();

      // Assert
      expect(result, isA<Failure<void>>());
    });
  });

  group('AuthRepositoryImpl - sendEmailVerification', () {
    const email = 'test@example.com';

    test('should return Success when email verification is sent', () async {
      // Arrange
      when(() => mockDataSource.sendEmailVerification(email))
          .thenAnswer((_) async {});

      // Act
      final result = await repository.sendEmailVerification(email);

      // Assert
      expect(result, isA<Success<void>>());
      verify(() => mockDataSource.sendEmailVerification(email)).called(1);
    });

    test('should return Failure when sending verification fails', () async {
      // Arrange
      when(() => mockDataSource.sendEmailVerification(email))
          .thenThrow(const NetworkException());

      // Act
      final result = await repository.sendEmailVerification(email);

      // Assert
      expect(result, isA<Failure<void>>());
      final failure = result as Failure<void>;
      expect(failure.exception, isA<NetworkException>());
    });
  });

  group('AuthRepositoryImpl - authStateChanges', () {
    test('should emit UserEntity when user is authenticated', () async {
      // Arrange
      final stream = Stream.value(testUserModel);
      when(() => mockDataSource.authStateChanges).thenAnswer((_) => stream);

      // Act
      final result = repository.authStateChanges;

      // Assert
      await expectLater(
        result,
        emits(predicate<UserEntity?>((user) => user?.id == testUserModel.id)),
      );
    });

    test('should emit null when user is unauthenticated', () async {
      // Arrange
      final stream = Stream<UserModel?>.value(null);
      when(() => mockDataSource.authStateChanges).thenAnswer((_) => stream);

      // Act
      final result = repository.authStateChanges;

      // Assert
      await expectLater(result, emits(null));
    });
  });
}
