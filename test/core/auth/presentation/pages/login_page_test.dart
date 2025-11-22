import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos_app/core/auth/presentation/pages/login_page.dart';
import 'package:lifeos_app/core/auth/presentation/providers/auth_notifier.dart';
import 'package:lifeos_app/core/auth/presentation/providers/auth_provider.dart';
import 'package:lifeos_app/core/auth/presentation/providers/auth_state.dart';
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
        home: const LoginPage(),
      ),
    );
  }

  group('LoginPage Widget Tests', () {
    testWidgets('should display all UI elements', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('LifeOS'), findsOneWidget);
      expect(find.text('Your Life Operating System'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in to continue your journey'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);

      // Check form fields (Email, Password)
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Sign up'), findsOneWidget);
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

      // Find and tap the Sign In button
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
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

      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should show loading indicator when logging in', (tester) async {
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
      final signInButton = find.widgetWithText(ElevatedButton, 'Sign In');
      final button = tester.widget<ElevatedButton>(signInButton);
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
          .thenReturn(const AuthState.error('Invalid email or password'));

      mockAuthNotifier.state = const AuthState.error('Invalid email or password');
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Invalid email or password'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should call loginWithEmail when Sign In tapped with valid data', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());
      when(() => mockAuthNotifier.loginWithEmail(
        email: any(named: 'email'),
        password: any(named: 'password'),
      )).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid data
      final emailField = find.byType(TextField).at(0);
      final passwordField = find.byType(TextField).at(1);

      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'ValidPass123!');

      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockAuthNotifier.loginWithEmail(
        email: 'test@example.com',
        password: 'ValidPass123!',
      )).called(1);
    });

    testWidgets('should show snackbar when Forgot Password tapped', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      final forgotPasswordButton = find.text('Forgot password?');
      await tester.tap(forgotPasswordButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Forgot password feature coming soon (Story 1.3)'), findsOneWidget);
    });

    testWidgets('should toggle password visibility when icon tapped', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Find password field
      final passwordField = find.byType(TextField).at(1);
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

    testWidgets('should clear email error when user starts typing', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Trigger validation error first
      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);

      // Start typing in email field
      final emailField = find.byType(TextField).at(0);
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
      final emailField = find.byType(TextField).at(0);
      await tester.enterText(emailField, 'test@example.com');

      final signInButton = find.text('Sign In');
      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);

      // Start typing in password field
      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(passwordField, 'p');
      await tester.pumpAndSettle();

      // Assert - error should be cleared
      expect(find.text('Password is required'), findsNothing);
    });

    testWidgets('should not show password requirements on login page', (tester) async {
      // Arrange
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState.unauthenticated());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter any password
      final passwordField = find.byType(TextField).at(1);
      await tester.enterText(passwordField, 'anypassword');
      await tester.pumpAndSettle();

      // Assert - should NOT show password requirements
      expect(find.text('Password requirements:'), findsNothing);
    });
  });
}
