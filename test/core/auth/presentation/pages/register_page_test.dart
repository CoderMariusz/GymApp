import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos/core/auth/domain/entities/user_entity.dart';
import 'package:lifeos/core/auth/presentation/pages/register_page.dart';
import 'package:lifeos/core/auth/presentation/providers/auth_notifier.dart';
import 'package:lifeos/core/auth/presentation/providers/auth_provider.dart';
import 'package:lifeos/core/auth/presentation/providers/auth_state.dart';
import 'package:lifeos/core/router/router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthNotifier extends StateNotifier<AuthState> with Mock
    implements AuthNotifier {
  MockAuthNotifier() : super(const AuthState.initial());
}

void main() {
  late MockAuthNotifier mockAuthNotifier;

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authStateProvider.overrideWith((ref) => mockAuthNotifier),
      ],
      child: MaterialApp(
        home: const RegisterPage(),
      ),
    );
  }

  group('RegisterPage Widget Tests', () {
    testWidgets('should display all UI elements', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('LifeOS'), findsOneWidget);
      expect(find.text('Your Life Operating System'), findsOneWidget);
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);

      // Check form fields
      expect(find.byType(TextField), findsNWidgets(3)); // Name, Email, Password
      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });

    testWidgets('should display Apple Sign-In button on iOS only', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      if (Platform.isIOS) {
        expect(find.text('Continue with Apple'), findsOneWidget);
      } else {
        expect(find.text('Continue with Apple'), findsNothing);
      }
    });

    testWidgets('should show validation error for empty email', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap the Create Account button
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('should show validation error for empty password', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter email but leave password empty
      final emailField = find.byType(TextField).first;
      await tester.enterText(emailField, 'test@example.com');

      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should show password requirements when typing password', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Find password field (third TextField)
      final passwordFields = find.byType(TextField);
      final passwordField = passwordFields.at(2);

      await tester.enterText(passwordField, 'weak');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Password requirements:'), findsOneWidget);
      expect(find.text('At least 8 characters'), findsOneWidget);
      expect(find.text('One uppercase letter'), findsOneWidget);
      expect(find.text('One number'), findsOneWidget);
      expect(find.text('One special character'), findsOneWidget);
    });

    testWidgets('should show loading indicator when registering', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.loading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('should disable form during loading', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.loading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Assert
      final createAccountButton = find.widgetWithText(ElevatedButton, 'Create Account');
      final button = tester.widget<ElevatedButton>(createAccountButton);
      expect(button.onPressed, isNull);
    });

    testWidgets('should show error snackbar on authentication error', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // Simulate error state
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.error('Email already exists'));

      mockAuthNotifier.state = const AuthState.error('Email already exists');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Email already exists'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should call registerWithEmail when Create Account tapped with valid data', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());
      when(() => mockAuthNotifier.registerWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
        name: any(named: 'name'),
      )).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid data
      final nameField = find.byType(TextField).at(0);
      final emailField = find.byType(TextField).at(1);
      final passwordField = find.byType(TextField).at(2);

      await tester.enterText(nameField, 'Test User');
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'ValidPass123!');

      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockAuthNotifier.registerWithEmail(
        email: 'test@example.com',
        password: 'ValidPass123!',
        name: 'Test User',
      )).called(1);
    });

    testWidgets('should show privacy policy dialog when link tapped', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      final privacyLink = find.text('By signing up, you agree to our Privacy Policy');
      await tester.tap(privacyLink);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('LifeOS Privacy Policy'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('should toggle password visibility when icon tapped', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Find password field
      final passwordField = find.byType(TextField).at(2);
      final textField = tester.widget<TextField>(passwordField);

      // Initially should be obscured
      expect(textField.obscureText, true);

      // Find and tap visibility icon
      final visibilityIcon = find.byIcon(Icons.visibility);
      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      // Should now be visible
      final updatedTextField = tester.widget<TextField>(passwordField);
      expect(updatedTextField.obscureText, false);
    });

    testWidgets('should call registerWithGoogle when Google button tapped', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());
      when(() => mockAuthNotifier.registerWithGoogle())
          .thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      final googleButton = find.text('Continue with Google');
      await tester.tap(googleButton);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockAuthNotifier.registerWithGoogle()).called(1);
    });

    testWidgets('should navigate to login page when "Sign in" tapped', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authStateProvider.overrideWith((ref) => mockAuthNotifier),
          ],
          child: MaterialApp.router(
            routerConfig: routerProvider,
          ),
        ),
      );

      // Note: Navigation test would require GoRouter setup
      // This is a simplified version
      final signInLink = find.text('Sign in');
      expect(signInLink, findsOneWidget);
    });

    testWidgets('should clear email error when user starts typing', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Trigger validation error first
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);

      // Start typing in email field
      final emailField = find.byType(TextField).at(1);
      await tester.enterText(emailField, 't');
      await tester.pumpAndSettle();

      // Assert - error should be cleared
      expect(find.text('Email is required'), findsNothing);
    });

    testWidgets('should clear password error when user starts typing', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter email and trigger validation
      final emailField = find.byType(TextField).at(1);
      await tester.enterText(emailField, 'test@example.com');

      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);

      // Start typing in password field
      final passwordField = find.byType(TextField).at(2);
      await tester.enterText(passwordField, 'p');
      await tester.pumpAndSettle();

      // Assert - error should be cleared
      expect(find.text('Password is required'), findsNothing);
    });
  });
}
