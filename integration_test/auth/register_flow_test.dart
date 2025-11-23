import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lifeos/main.dart' as app;

/// Integration tests for user registration flow
/// Tests complete end-to-end registration scenarios
///
/// Note: These tests require a real Supabase instance
/// For CI/CD, consider using test database or mocked backend
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Registration Flow Integration Tests', () {
    testWidgets('Complete email registration flow', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on the registration page
      expect(find.text('Create your account'), findsOneWidget);

      // Generate unique test email
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testEmail = 'test+$timestamp@lifeos.app';
      const testPassword = 'TestPass123!';
      const testName = 'Test User';

      // Enter registration data
      final nameField = find.byType(TextField).at(0);
      final emailField = find.byType(TextField).at(1);
      final passwordField = find.byType(TextField).at(2);

      await tester.enterText(nameField, testName);
      await tester.enterText(emailField, testEmail);
      await tester.enterText(passwordField, testPassword);
      await tester.pumpAndSettle();

      // Verify password requirements are shown
      expect(find.text('Password requirements:'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNWidgets(4)); // All requirements met

      // Tap privacy policy link (should show dialog)
      final privacyLink = find.text('By signing up, you agree to our Privacy Policy');
      await tester.tap(privacyLink);
      await tester.pumpAndSettle();
      expect(find.text('Privacy Policy'), findsOneWidget);

      // Close dialog
      final closeButton = find.text('Close');
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Tap Create Account button
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);

      // Wait for loading and navigation
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should navigate to onboarding or show success
      // Note: Actual navigation depends on Supabase response
      // In real implementation, you would verify:
      // 1. User is created in Supabase
      // 2. Email verification email is sent
      // 3. User profile is created in database
      // 4. Navigation to onboarding occurs

      // For now, verify no error is shown
      expect(find.text('Email already exists'), findsNothing);
      expect(find.text('Connection failed'), findsNothing);
    }, timeout: const Timeout(Duration(minutes: 2)));

    testWidgets('Handle email already exists error', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Use an email that already exists in test database
      const existingEmail = 'existing@lifeos.app';
      const testPassword = 'TestPass123!';

      // Enter registration data
      final emailField = find.byType(TextField).at(1);
      final passwordField = find.byType(TextField).at(2);

      await tester.enterText(emailField, existingEmail);
      await tester.enterText(passwordField, testPassword);
      await tester.pumpAndSettle();

      // Tap Create Account button
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);

      // Wait for error response
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show error message
      // Note: Exact error message depends on Supabase response
      expect(find.byType(SnackBar), findsOneWidget);
    }, skip: true); // Skip in CI - requires specific test data

    testWidgets('Validate weak password rejection', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Enter weak password
      final emailField = find.byType(TextField).at(1);
      final passwordField = find.byType(TextField).at(2);

      await tester.enterText(emailField, 'test@lifeos.app');
      await tester.enterText(passwordField, 'weak'); // Too short, no special chars
      await tester.pumpAndSettle();

      // Verify password requirements show unmet conditions
      expect(find.text('Password requirements:'), findsOneWidget);
      expect(find.byIcon(Icons.circle_outlined), findsWidgets); // Some requirements not met

      // Tap Create Account button
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      // Should not proceed (client-side validation)
      // User should still be on registration page
      expect(find.text('Create your account'), findsOneWidget);
    });

    testWidgets('Validate invalid email format', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Enter invalid email
      final emailField = find.byType(TextField).at(1);
      final passwordField = find.byType(TextField).at(2);

      await tester.enterText(emailField, 'invalid-email');
      await tester.enterText(passwordField, 'ValidPass123!');
      await tester.pumpAndSettle();

      // Tap Create Account button
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Should show error (from use case validation)
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('Navigate to login page from registration', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Verify we're on registration page
      expect(find.text('Create your account'), findsOneWidget);

      // Tap "Sign in" link
      final signInLink = find.text('Sign in');
      await tester.tap(signInLink);
      await tester.pumpAndSettle();

      // Should navigate to login page
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in to continue your journey'), findsOneWidget);
    });

    testWidgets('Toggle password visibility', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Enter password
      final passwordField = find.byType(TextField).at(2);
      await tester.enterText(passwordField, 'TestPass123!');
      await tester.pumpAndSettle();

      // Password should be obscured initially
      var textField = tester.widget<TextField>(passwordField);
      expect(textField.obscureText, true);

      // Tap visibility icon
      final visibilityIcon = find.byIcon(Icons.visibility);
      await tester.tap(visibilityIcon);
      await tester.pumpAndSettle();

      // Password should now be visible
      textField = tester.widget<TextField>(passwordField);
      expect(textField.obscureText, false);

      // Tap again to hide
      final visibilityOffIcon = find.byIcon(Icons.visibility_off);
      await tester.tap(visibilityOffIcon);
      await tester.pumpAndSettle();

      // Password should be obscured again
      textField = tester.widget<TextField>(passwordField);
      expect(textField.obscureText, true);
    });

    testWidgets('Show loading state during registration', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Enter valid data
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final testEmail = 'test+$timestamp@lifeos.app';

      final emailField = find.byType(TextField).at(1);
      final passwordField = find.byType(TextField).at(2);

      await tester.enterText(emailField, testEmail);
      await tester.enterText(passwordField, 'TestPass123!');
      await tester.pumpAndSettle();

      // Tap Create Account button
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);

      // Immediately check for loading indicator
      await tester.pump(const Duration(milliseconds: 100));

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsWidgets);

      // Wait for completion
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }, skip: true); // Skip in CI - timing dependent
  });

  group('Google OAuth Flow Integration Tests', () {
    testWidgets('Google OAuth button triggers sign-in', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Find and tap Google OAuth button
      final googleButton = find.text('Continue with Google');
      expect(googleButton, findsOneWidget);

      await tester.tap(googleButton);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Note: Actual OAuth flow requires real Google credentials
      // and cannot be fully tested in integration tests without:
      // 1. Test Google account credentials
      // 2. OAuth redirect handling
      // 3. Deep link testing

      // For now, verify the button exists and is tappable
      expect(find.text('Continue with Google'), findsOneWidget);
    }, skip: true); // Skip - requires OAuth setup
  });

  group('Form Validation Integration Tests', () {
    testWidgets('Clear errors when user starts typing', (tester) async {
      // Start app
      app.main();
      await tester.pumpAndSettle();

      // Trigger validation errors
      final createAccountButton = find.text('Create Account');
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Email is required'), findsOneWidget);

      // Start typing in email field
      final emailField = find.byType(TextField).at(1);
      await tester.enterText(emailField, 'test');
      await tester.pumpAndSettle();

      // Email error should be cleared
      expect(find.text('Email is required'), findsNothing);

      // Trigger password error
      await tester.tap(createAccountButton);
      await tester.pumpAndSettle();

      expect(find.text('Password is required'), findsOneWidget);

      // Start typing in password field
      final passwordField = find.byType(TextField).at(2);
      await tester.enterText(passwordField, 'pass');
      await tester.pumpAndSettle();

      // Password error should be cleared
      expect(find.text('Password is required'), findsNothing);
    });
  });
}
