import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos_app/core/auth/domain/validators/password_validator.dart';

void main() {
  group('PasswordValidator', () {
    group('validate', () {
      test('should return valid for strong password', () {
        // Arrange
        const password = 'TestPass123!';

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result.isValid, true);
        expect(result.errors, isEmpty);
      });

      test('should fail for password shorter than 8 characters', () {
        // Arrange
        const password = 'Test1!';

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result.isValid, false);
        expect(
          result.errors,
          contains('Password must be at least 8 characters'),
        );
      });

      test('should fail for password without uppercase letter', () {
        // Arrange
        const password = 'testpass123!';

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result.isValid, false);
        expect(
          result.errors,
          contains('Password must contain at least one uppercase letter'),
        );
      });

      test('should fail for password without number', () {
        // Arrange
        const password = 'TestPassword!';

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result.isValid, false);
        expect(
          result.errors,
          contains('Password must contain at least one number'),
        );
      });

      test('should fail for password without special character', () {
        // Arrange
        const password = 'TestPassword123';

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result.isValid, false);
        expect(
          result.errors,
          contains('Password must contain at least one special character'),
        );
      });

      test('should return multiple errors for weak password', () {
        // Arrange
        const password = 'weak';

        // Act
        final result = PasswordValidator.validate(password);

        // Assert
        expect(result.isValid, false);
        expect(result.errors.length, greaterThan(1));
      });
    });

    group('isValid', () {
      test('should return true for valid password', () {
        expect(PasswordValidator.isValid('ValidPass123!'), true);
      });

      test('should return false for invalid password', () {
        expect(PasswordValidator.isValid('weak'), false);
      });
    });
  });

  group('EmailValidator', () {
    test('should return true for valid email', () {
      expect(EmailValidator.isValid('test@example.com'), true);
      expect(EmailValidator.isValid('user.name@domain.co.uk'), true);
    });

    test('should return false for invalid email', () {
      expect(EmailValidator.isValid('invalid'), false);
      expect(EmailValidator.isValid('invalid@'), false);
      expect(EmailValidator.isValid('@domain.com'), false);
      expect(EmailValidator.isValid('test @example.com'), false);
    });

    test('should return false for empty email', () {
      expect(EmailValidator.isValid(''), false);
    });

    test('should return error message for invalid email', () {
      expect(EmailValidator.getErrorMessage(''), isNotNull);
      expect(EmailValidator.getErrorMessage('invalid'), isNotNull);
    });

    test('should return null for valid email', () {
      expect(EmailValidator.getErrorMessage('test@example.com'), isNull);
    });
  });
}
