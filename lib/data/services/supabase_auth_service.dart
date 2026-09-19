import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _client;

  // Inject Supabase client, defaulting to the initialized singleton instance
  SupabaseAuthService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  /// Listen to authentication state changes (e.g., signed in, signed out)
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// Sign in with Email and Password
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      // Map Supabase-specific AuthExceptions to readable messages
      throw Exception(_mapAuthExceptionToMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred during sign in.');
    }
  }

  /// Sign up with Email and Password
  Future<AuthResponse> signUpWithEmailPassword(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw Exception(_mapAuthExceptionToMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred during sign up.');
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } on AuthException catch (e) {
      throw Exception(_mapAuthExceptionToMessage(e));
    } catch (e) {
      throw Exception('An unexpected error occurred during sign out.');
    }
  }

  /// Helper to map Supabase errors to user-friendly messages
  String _mapAuthExceptionToMessage(AuthException e) {
    if (e.message.toLowerCase().contains('invalid login credentials')) {
      return 'Invalid email or password. Please try again.';
    } else if (e.message.toLowerCase().contains('user already registered')) {
      return 'An account with this email already exists.';
    } else if (e.message.toLowerCase().contains('password should be at least')) {
      return 'Password is too weak. Please use a stronger password.';
    }
    return e.message;
  }
}
