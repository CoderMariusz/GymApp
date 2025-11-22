import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../router/router.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/email_text_field.dart';
import '../widgets/oauth_button.dart';
import '../widgets/password_text_field.dart';

/// Register page - User account creation
/// Story 1.1: User Account Creation
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  String? _emailError;
  String? _passwordError;
  bool _showPasswordRequirements = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleEmailChanged(String value) {
    setState(() {
      _emailError = null;
    });
  }

  void _handlePasswordChanged(String value) {
    setState(() {
      _passwordError = null;
      _showPasswordRequirements = value.isNotEmpty;
    });
  }

  Future<void> _handleRegister() async {
    // Clear errors
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    // Validate form
    if (_emailController.text.isEmpty) {
      setState(() {
        _emailError = 'Email is required';
      });
      return;
    }

    if (_passwordController.text.isEmpty) {
      setState(() {
        _passwordError = 'Password is required';
      });
      return;
    }

    // Register with email
    await ref.read(authStateProvider.notifier).registerWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          name: _nameController.text.isNotEmpty
              ? _nameController.text.trim()
              : null,
        );
  }

  Future<void> _handleGoogleSignIn() async {
    await ref.read(authStateProvider.notifier).registerWithGoogle();
  }

  Future<void> _handleAppleSignIn() async {
    await ref.read(authStateProvider.notifier).registerWithApple();
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'LifeOS Privacy Policy\n\n'
            'We take your privacy seriously. Your data is stored securely and encrypted. '
            'You can export or delete your data at any time.\n\n'
            'For full privacy policy, visit: lifeos.com/privacy',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    // Listen to auth state and show errors/navigate
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      next.maybeWhen(
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        authenticated: (_) {
          // Navigate to onboarding
          context.go(AppRoutes.onboarding);
        },
        orElse: () {},
      );
    });

    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),

                // Logo/Title
                Text(
                  'LifeOS',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your Life Operating System',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Title
                Text(
                  'Create your account',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start your journey to a better life',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey,
                      ),
                ),
                const SizedBox(height: 32),

                // Social Auth Buttons
                OAuthButton(
                  provider: 'Google',
                  onPressed: _handleGoogleSignIn,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 12),

                // Apple Sign-In (iOS only)
                if (Platform.isIOS) ...[
                  OAuthButton(
                    provider: 'Apple',
                    onPressed: _handleAppleSignIn,
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 24),
                ],

                // Divider
                const Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('OR'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),

                // Name field (optional)
                TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Name (optional)',
                    hintText: 'Enter your name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 16),

                // Email field
                EmailTextField(
                  controller: _emailController,
                  errorText: _emailError,
                  onChanged: _handleEmailChanged,
                ),
                const SizedBox(height: 16),

                // Password field
                PasswordTextField(
                  controller: _passwordController,
                  errorText: _passwordError,
                  onChanged: _handlePasswordChanged,
                  showRequirements: _showPasswordRequirements,
                ),
                const SizedBox(height: 24),

                // Privacy Policy
                Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: _showPrivacyPolicy,
                        child: Text(
                          'By signing up, you agree to our Privacy Policy',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey,
                                    decoration: TextDecoration.underline,
                                  ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Register button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleRegister,
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 24),

                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    GestureDetector(
                      onTap: isLoading
                          ? null
                          : () => context.go(AppRoutes.login),
                      child: Text(
                        'Sign in',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
