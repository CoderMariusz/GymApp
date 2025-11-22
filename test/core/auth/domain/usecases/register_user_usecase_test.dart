import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/auth/domain/entities/user_entity.dart';
import 'package:lifeos/core/auth/domain/exceptions/auth_exceptions.dart';
import 'package:lifeos/core/auth/domain/repositories/auth_repository.dart';
import 'package:lifeos/core/auth/domain/usecases/register_user_usecase.dart';
import 'package:lifeos/core/utils/result.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUserUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUserUseCase(mockRepository);
  });

  group('RegisterUserUseCase', () {
    group('callWithEmail', () {
      const email = 'test@example.com';
      const password = 'ValidPass123!';
      const name = 'Test User';

      final userEntity = UserEntity(
        id: '123',
        email: email,
        name: name,
        emailVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      test('should return Success with UserEntity when registration succeeds',
          () async {
        // Arrange
        when(() => mockRepository.registerWithEmail(
              email: email,
              password: password,
              name: name,
            )).thenAnswer((_) async => Success(userEntity));

        // Act
        final result = await useCase.callWithEmail(
          email: email,
          password: password,
          name: name,
        );

        // Assert
        expect(result, isA<Success<UserEntity>>());
        expect(result.isSuccess, true);
        expect((result as Success).value, userEntity);
        verify(() => mockRepository.registerWithEmail(
              email: email,
              password: password,
              name: name,
            )).called(1);
      });

      test('should return Failure when email is invalid', () async {
        // Arrange
        const invalidEmail = 'invalid-email';

        // Act
        final result = await useCase.callWithEmail(
          email: invalidEmail,
          password: password,
        );

        // Assert
        expect(result, isA<Failure<UserEntity>>());
        expect(result.isFailure, true);
        expect((result as Failure).exception, isA<InvalidEmailException>());
        verifyNever(() => mockRepository.registerWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ));
      });

      test('should return Failure when password is weak', () async {
        // Arrange
        const weakPassword = 'weak';

        // Act
        final result = await useCase.callWithEmail(
          email: email,
          password: weakPassword,
        );

        // Assert
        expect(result, isA<Failure<UserEntity>>());
        expect(result.isFailure, true);
        expect((result as Failure).exception, isA<WeakPasswordException>());
        verifyNever(() => mockRepository.registerWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            ));
      });

      test('should return Failure when repository throws exception', () async {
        // Arrange
        when(() => mockRepository.registerWithEmail(
              email: email,
              password: password,
              name: name,
            )).thenAnswer(
          (_) async => const Failure(
            EmailAlreadyExistsException(),
            'This email is already registered. Try logging in?',
          ),
        );

        // Act
        final result = await useCase.callWithEmail(
          email: email,
          password: password,
          name: name,
        );

        // Assert
        expect(result, isA<Failure<UserEntity>>());
        expect(result.isFailure, true);
        expect(
          (result as Failure).exception,
          isA<EmailAlreadyExistsException>(),
        );
      });
    });

    group('callWithGoogle', () {
      final userEntity = UserEntity(
        id: '123',
        email: 'test@gmail.com',
        name: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      test('should return Success when Google OAuth succeeds', () async {
        // Arrange
        when(() => mockRepository.registerWithGoogle())
            .thenAnswer((_) async => Success(userEntity));

        // Act
        final result = await useCase.callWithGoogle();

        // Assert
        expect(result, isA<Success<UserEntity>>());
        expect((result as Success).value, userEntity);
        verify(() => mockRepository.registerWithGoogle()).called(1);
      });

      test('should return Failure when Google OAuth fails', () async {
        // Arrange
        when(() => mockRepository.registerWithGoogle()).thenAnswer(
          (_) async => const Failure(
            OAuthCancelledException(),
            'Sign in cancelled',
          ),
        );

        // Act
        final result = await useCase.callWithGoogle();

        // Assert
        expect(result, isA<Failure<UserEntity>>());
        expect((result as Failure).exception, isA<OAuthCancelledException>());
      });
    });

    group('callWithApple', () {
      final userEntity = UserEntity(
        id: '123',
        email: 'test@privaterelay.appleid.com',
        name: 'Test User',
        emailVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      test('should return Success when Apple Sign-In succeeds', () async {
        // Arrange
        when(() => mockRepository.registerWithApple())
            .thenAnswer((_) async => Success(userEntity));

        // Act
        final result = await useCase.callWithApple();

        // Assert
        expect(result, isA<Success<UserEntity>>());
        expect((result as Success).value, userEntity);
        verify(() => mockRepository.registerWithApple()).called(1);
      });

      test('should return Failure when Apple Sign-In fails', () async {
        // Arrange
        when(() => mockRepository.registerWithApple()).thenAnswer(
          (_) async => const Failure(
            OAuthFailedException(),
            'Sign in failed. Please try again.',
          ),
        );

        // Act
        final result = await useCase.callWithApple();

        // Assert
        expect(result, isA<Failure<UserEntity>>());
        expect((result as Failure).exception, isA<OAuthFailedException>());
      });
    });
  });
}
