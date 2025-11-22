/// Password validation result
class PasswordValidationResult {
  final bool isValid;
  final List<String> errors;

  const PasswordValidationResult({
    required this.isValid,
    this.errors = const [],
  });

  factory PasswordValidationResult.valid() {
    return const PasswordValidationResult(isValid: true);
  }

  factory PasswordValidationResult.invalid(List<String> errors) {
    return PasswordValidationResult(isValid: false, errors: errors);
  }
}

/// Password validator
/// Validates password according to requirements:
/// - Minimum 8 characters
/// - At least 1 uppercase letter
/// - At least 1 number
/// - At least 1 special character
class PasswordValidator {
  static const int minLength = 8;

  /// Validates a password
  static PasswordValidationResult validate(String password) {
    final errors = <String>[];

    // Check minimum length
    if (password.length < minLength) {
      errors.add('Password must be at least $minLength characters');
    }

    // Check for uppercase letter
    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('Password must contain at least one uppercase letter');
    }

    // Check for number
    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('Password must contain at least one number');
    }

    // Check for special character
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add('Password must contain at least one special character');
    }

    if (errors.isEmpty) {
      return PasswordValidationResult.valid();
    }

    return PasswordValidationResult.invalid(errors);
  }

  /// Quick validation - returns true if valid
  static bool isValid(String password) {
    return validate(password).isValid;
  }

  /// Get user-friendly error message
  static String getErrorMessage(String password) {
    final result = validate(password);
    if (result.isValid) return '';

    return result.errors.join('\n');
  }

  /// Get password requirements text
  static String get requirementsText {
    return '''
Password requirements:
• At least $minLength characters
• At least one uppercase letter
• At least one number
• At least one special character (!@#\$%^&*...)
''';
  }
}

/// Email validator
class EmailValidator {
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates an email address
  static bool isValid(String email) {
    return _emailRegex.hasMatch(email.trim());
  }

  /// Get error message for invalid email
  static String? getErrorMessage(String email) {
    if (email.isEmpty) {
      return 'Email is required';
    }

    if (!isValid(email)) {
      return 'Please enter a valid email address';
    }

    return null;
  }
}
