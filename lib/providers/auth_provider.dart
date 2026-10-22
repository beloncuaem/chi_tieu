import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import '../data/repositories/auth_repository.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AppAuthState {
  final AuthStatus status;
  final sb.User? user;
  final String? errorMessage;
  final bool isConfigured;

  const AppAuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isConfigured = false,
  });

  AppAuthState copyWith({
    AuthStatus? status,
    sb.User? user,
    String? errorMessage,
    bool? isConfigured,
  }) {
    return AppAuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      isConfigured: isConfigured ?? this.isConfigured,
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthNotifier extends StateNotifier<AppAuthState> {
  final AuthRepository _repo;
  StreamSubscription<sb.AuthState>? _authSubscription;

  AuthNotifier(this._repo)
      : super(AppAuthState(
          isConfigured: _repo.isConfigured,
          user: _repo.currentUser,
          status: _repo.currentUser != null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated,
        )) {
    _listenAuth();
  }

  void _listenAuth() {
    final stream = _repo.onAuthStateChange;
    if (stream != null) {
      _authSubscription = stream.listen((data) {
        final session = data.session;
        if (session != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: session.user,
            errorMessage: null,
          );
        } else {
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            user: null,
            errorMessage: null,
          );
        }
      });
    }
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      final res = await _repo.signInWithEmail(email: email, password: password);
      if (res.user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: res.user,
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _humanReadableError(e.toString()),
      );
      return false;
    }
  }

  Future<bool> signUpWithEmail(
    String email,
    String password, {
    String? fullName,
  }) async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      final res = await _repo.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      if (res.user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: res.user,
        );
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _humanReadableError(e.toString()),
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
      return await _repo.signInWithGoogle();
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: _humanReadableError(e.toString()),
      );
      return false;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      user: null,
    );
  }

  String _humanReadableError(String raw) {
    if (raw.contains('Invalid login credentials')) {
      return 'Email hoặc mật khẩu không chính xác.';
    }
    if (raw.contains('User already registered')) {
      return 'Email này đã được đăng ký tài khoản.';
    }
    if (raw.contains('Password should be at least')) {
      return 'Mật khẩu phải có ít nhất 6 ký tự.';
    }
    if (raw.contains('Supabase chưa được cấu hình')) {
      return 'Chưa cấu hình Supabase. Vui lòng thêm URL và Anon Key vào file .env.';
    }
    return raw.replaceAll('Exception: ', '').replaceAll('AuthException: ', '');
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});

