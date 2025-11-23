import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/router.dart';
import '../providers/auth_provider.dart';
import '../widgets/password_text_field.dart';

/// Reset password page - Set new password after clicking reset link
/// Story 1.3: Password Reset Flow
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _passwordError;
  String? _confirmPasswordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handlePasswordReset() async {
    // Clear errors
    setState(() {
      _passwordError = null;
      _confirmPasswordError = null;
    });

    // Validate password
    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      return;
    }

    // Validate confirm password
    if (_confirmPasswordController.text.isEmpty) {
      setState(() {
        _confirmPasswordError = 'Please confirm your password';
      });
      return;
    }

    // Check if passwords match
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _confirmPasswordError = 'Passwords do not match';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatePasswordUseCase = ref.read(updatePasswordUseCaseProvider);

      final result = await updatePasswordUseCase.call(
        _passwordController.text,
      );

      result.map(
        success: (success) {
          // Show success message
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Password reset successfully! Logging you in...'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate to home (user is already authenticated via reset token)
          context.go(AppRoutes.home);
        },
        failure: (failure) {
          setState(() {
            _isLoading = false;
            _passwordError = failure.exception.toString();
          });
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _passwordError = 'An unexpected error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Icon
                Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Create new password',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your new password must be different from your previous password.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Password requirements
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Password requirements:',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      _buildRequirement('At least 8 characters'),
                      _buildRequirement('At least one uppercase letter'),
                      _buildRequirement('At least one number'),
                      _buildRequirement('At least one special character'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // New password field
                PasswordTextField(
                  controller: _passwordController,
                  errorText: _passwordError,
                  onChanged: (_) => setState(() => _passwordError = null),
                  labelText: 'New Password',
                ),
                const SizedBox(height: 16),

                // Confirm password field
                PasswordTextField(
                  controller: _confirmPasswordController,
                  errorText: _confirmPasswordError,
                  onChanged: (_) =>
                      setState(() => _confirmPasswordError = null),
                  labelText: 'Confirm Password',
                ),
                const SizedBox(height: 24),

                // Reset password button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handlePasswordReset,
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Reset Password',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
