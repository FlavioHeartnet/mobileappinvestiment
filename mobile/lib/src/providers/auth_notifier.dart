import 'package:flutter_riverpod/legacy.dart';
import 'package:mobile/src/services/auth_service.dart';

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final String? userEmail;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.error,
    this.userEmail,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    String? userEmail,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      userEmail: userEmail ?? this.userEmail,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _service;
  AuthNotifier(this._service) : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final ok = await _service.login(email, password);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: ok,
        userEmail: ok ? email : null,
        error: ok ? null : 'Falha ao fazer login',
      );
      return ok;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final ok = await _service.signup(name, email, password);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: ok,
        userEmail: ok ? email : null,
        error: ok ? null : 'Falha ao criar conta',
      );
      return ok;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final ok = await _service.signInWithGoogle();
      final currentUser = _service.getCurrentUser();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: ok,
        userEmail: ok ? currentUser?.email : null,
        error: ok ? null : 'Falha ao fazer login com Google',
      );
      return ok;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _service.logout();
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService());
});
