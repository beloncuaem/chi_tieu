import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_config.dart';

class AuthRepository {
  SupabaseClient? get _client => SupabaseConfig.client;

  User? get currentUser => _client?.auth.currentUser;
  Session? get currentSession => _client?.auth.currentSession;
  Stream<AuthState>? get onAuthStateChange => _client?.auth.onAuthStateChange;

  bool get isConfigured => SupabaseConfig.isInitialized;

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase chưa được cấu hình. Vui lòng kiểm tra file .env');
    }

    return await client.auth.signUp(
      email: email.trim(),
      password: password,
      data: fullName != null && fullName.isNotEmpty
          ? {'full_name': fullName.trim()}
          : null,
    );
  }

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase chưa được cấu hình. Vui lòng kiểm tra file .env');
    }

    return await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<bool> signInWithGoogle() async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase chưa được cấu hình. Vui lòng kiểm tra file .env');
    }

    try {
      return await client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.chitieu://login-callback/',
      );
    } catch (e) {
      debugPrint('Google Sign-in error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    final client = _client;
    if (client != null) {
      await client.auth.signOut();
    }
  }

  Future<void> resetPassword(String email) async {
    final client = _client;
    if (client == null) {
      throw Exception('Supabase chưa được cấu hình. Vui lòng kiểm tra file .env');
    }
    await client.auth.resetPasswordForEmail(email.trim());
  }
}

