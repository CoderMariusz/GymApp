import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/exceptions/auth_exceptions.dart';
import '../models/auth_session_model.dart';
import '../models/user_model.dart';

/// Supabase authentication data source
/// Handles all Supabase Auth API calls
class SupabaseAuthDataSource {
  final SupabaseClient _client;

  const SupabaseAuthDataSource(this._client);

  /// Register with email and password
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      // Sign up user
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: name != null ? {'name': name} : null,
        emailRedirectTo: 'lifeos://verify',
      );

      if (response.user == null) {
        throw const UnknownAuthException('Failed to create user');
      }

      // Create user profile in database
      await _createUserProfile(
        userId: response.user!.id,
        email: email,
        name: name ?? email.split('@').first,
      );

      // Fetch user profile
      final profileData = await _getUserProfile(response.user!.id);

      return UserModel.fromSupabase(
        user: response.user!,
        profileData: profileData,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  /// Register with Google OAuth
  Future<UserModel> registerWithGoogle() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'lifeos://auth/callback',
      );

      if (!response) {
        throw const OAuthCancelledException();
      }

      // Get current user after OAuth
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const OAuthFailedException();
      }

      // Create/update user profile
      await _createOrUpdateUserProfile(user);

      // Fetch user profile
      final profileData = await _getUserProfile(user.id);

      return UserModel.fromSupabase(
        user: user,
        profileData: profileData,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  /// Register with Apple Sign-In
  Future<UserModel> registerWithApple() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'lifeos://auth/callback',
      );

      if (!response) {
        throw const OAuthCancelledException();
      }

      // Get current user after OAuth
      final user = _client.auth.currentUser;
      if (user == null) {
        throw const OAuthFailedException();
      }

      // Create/update user profile
      await _createOrUpdateUserProfile(user);

      // Fetch user profile
      final profileData = await _getUserProfile(user.id);

      return UserModel.fromSupabase(
        user: user,
        profileData: profileData,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  /// Login with email and password
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const InvalidCredentialsException();
      }

      // Fetch user profile
      final profileData = await _getUserProfile(response.user!.id);

      return UserModel.fromSupabase(
        user: response.user!,
        profileData: profileData,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  /// Get current user
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final profileData = await _getUserProfile(user.id);

      return UserModel.fromSupabase(
        user: user,
        profileData: profileData,
      );
    } catch (e) {
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  /// Stream of auth state changes
  Stream<UserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.asyncMap((event) async {
      final user = event.session?.user;
      if (user == null) return null;

      try {
        final profileData = await _getUserProfile(user.id);
        return UserModel.fromSupabase(
          user: user,
          profileData: profileData,
        );
      } catch (e) {
        return UserModel.fromSupabase(user: user);
      }
    });
  }

  /// Create user profile in database
  Future<void> _createUserProfile({
    required String userId,
    required String email,
    required String name,
  }) async {
    try {
      await _client.from('user_profiles').insert({
        'user_id': userId,
        'full_name': name,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Profile creation might fail if trigger already created it
      // This is okay, we'll fetch it anyway
    }
  }

  /// Create or update user profile (for OAuth)
  Future<void> _createOrUpdateUserProfile(User user) async {
    final name = user.userMetadata?['name'] as String? ??
                 user.userMetadata?['full_name'] as String? ??
                 user.email?.split('@').first ??
                 'User';

    try {
      await _client.from('user_profiles').upsert({
        'user_id': user.id,
        'full_name': name,
        'avatar_url': user.userMetadata?['avatar_url'],
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Ignore errors as profile might be created by trigger
    }
  }

  /// Get user profile from database
  Future<Map<String, dynamic>?> _getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      return null;
    }
  }

  /// Login with email and password (returns session)
  Future<AuthSessionModel> loginWithEmailSession({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null || response.session == null) {
        throw const InvalidCredentialsException();
      }

      // Fetch user profile
      final profileData = await _getUserProfile(response.user!.id);

      return AuthSessionModel.fromSupabase(
        session: response.session!,
        profileData: profileData ?? {},
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  /// Login with Google OAuth (returns session)
  Future<AuthSessionModel> loginWithGoogleSession() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'lifeos://auth/callback',
      );

      if (!response) {
        throw const OAuthCancelledException();
      }

      // Get current session after OAuth
      final session = _client.auth.currentSession;
      if (session == null) {
        throw const OAuthFailedException();
      }

      final user = session.user;

      // Create/update user profile
      await _createOrUpdateUserProfile(user);

      // Fetch user profile
      final profileData = await _getUserProfile(user.id);

      return AuthSessionModel.fromSupabase(
        session: session,
        profileData: profileData ?? {},
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  /// Login with Apple Sign-In (returns session)
  Future<AuthSessionModel> loginWithAppleSession() async {
    try {
      final response = await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: 'lifeos://auth/callback',
      );

      if (!response) {
        throw const OAuthCancelledException();
      }

      // Get current session after OAuth
      final session = _client.auth.currentSession;
      if (session == null) {
        throw const OAuthFailedException();
      }

      final user = session.user;

      // Create/update user profile
      await _createOrUpdateUserProfile(user);

      // Fetch user profile
      final profileData = await _getUserProfile(user.id);

      return AuthSessionModel.fromSupabase(
        session: session,
        profileData: profileData ?? {},
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  /// Get current session
  Future<AuthSessionModel?> getCurrentSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) return null;

      final user = session.user;

      // Fetch user profile
      final profileData = await _getUserProfile(user.id);

      return AuthSessionModel.fromSupabase(
        session: session,
        profileData: profileData ?? {},
      );
    } catch (e) {
      return null;
    }
  }

  /// Request password reset
  /// Sends email with reset link that expires in 1 hour
  Future<void> requestPasswordReset(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'lifeos://reset-password',
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  /// Update password
  /// User must be authenticated via reset token
  /// Old password is automatically invalidated
  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw UnknownAuthException(e.toString());
    }
  }

  /// Handle Supabase auth exceptions
  Exception _handleAuthException(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('email') && message.contains('already')) {
      return const EmailAlreadyExistsException();
    }

    if (message.contains('password') && message.contains('weak')) {
      return const WeakPasswordException();
    }

    if (message.contains('invalid') && message.contains('email')) {
      return const InvalidEmailException();
    }

    if (message.contains('invalid') &&
        (message.contains('credentials') || message.contains('password'))) {
      return const InvalidCredentialsException();
    }

    if (message.contains('network') || message.contains('connection')) {
      return const NetworkException();
    }

    if (message.contains('user') && message.contains('not found')) {
      return const UserNotFoundException();
    }

    return UnknownAuthException(e.message);
  }
}
