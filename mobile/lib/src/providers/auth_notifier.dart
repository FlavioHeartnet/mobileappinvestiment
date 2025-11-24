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

  String? _lastRequestedEmail;

  /// Returns the last email used to request a password reset, if any.
  String? get lastRequestedEmail => _lastRequestedEmail;

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true);
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
    state = state.copyWith(isLoading: true);
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

  /// Send password reset email using AuthService
  Future<bool> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true);
    try {
      // persist the requested email for later resend
      _lastRequestedEmail = email;
      final ok = await _service.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false, error: ok ? null : 'Falha ao enviar email');
      return ok;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Resend the password reset email using the last requested email.
  Future<bool> resendPasswordResetEmail() async {
    if (_lastRequestedEmail == null) {
      state = state.copyWith(error: 'Nenhum e-mail registrado para reenviar.');
      return false;
    }
    state = state.copyWith(isLoading: true);
    try {
      final ok = await _service.sendPasswordResetEmail(_lastRequestedEmail!);
      state = state.copyWith(isLoading: false, error: ok ? null : 'Falha ao reenviar email');
      return ok;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true);
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
      // Prefer the thrown message when it's already a user-friendly string,
      // otherwise use a Portuguese fallback.
      final message = e is String
          ? e
          : 'Falha ao entrar com o Google. Verifique sua conexão e tente novamente.';
      state = state.copyWith(
        isLoading: false,
        error: message,
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    try {
      await _service.logout();
    } catch (e) {
      // Record error but proceed to clear auth state to ensure UI goes to login
      state = state.copyWith(error: e.toString());
    } finally {
      state = const AuthState();
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(AuthService());
});
