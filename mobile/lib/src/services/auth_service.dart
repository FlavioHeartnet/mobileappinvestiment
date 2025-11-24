import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  /// Login with email and password
  Future<bool> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    }
  }

  /// Sign up with email and password
  Future<bool> signup(String name, String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Update the user's display name if the user object is available
      final user = userCredential.user;
      if (user != null) {
        await user.updateDisplayName(name);
      }
      return true;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        // Web uses popup flow
        await _firebaseAuth.signInWithPopup(GoogleAuthProvider());
        return true;
      }

      // Guard unsupported platforms (e.g., desktop without a browser flow)
      if (!(defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS)) {
        throw 'Login com Google não é suportado neste dispositivo.';
      }

      // Mobile/desktop: plugin in this project exposes an `authenticate` API
      // that yields token data with idToken.
      await _googleSignIn.initialize();
      final account = await _googleSignIn.authenticate();
      final googleAuth = account.authentication;
      if (googleAuth.idToken == null) {
        throw 'Não foi possível obter credenciais do Google neste dispositivo.';
      }

      final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

      await _firebaseAuth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('No credential available') || msg.contains('No credentials available')) {
        throw 'Não há conta Google disponível neste dispositivo. Adicione uma conta Google nas configurações do dispositivo ou use e-mail e senha.';
      }
      // Surface friendly message when possible
      if (e is String) rethrow;
      throw 'Falha ao entrar com o Google. Verifique sua conexão e tente novamente.';
    }
  }

  /// Logout
  Future<void> logout() async {
    // Always attempt to sign out from Firebase
    try {
      await _firebaseAuth.signOut();
    } catch (_) {
      // Ignore to ensure UI flow continues even if signOut throws
    }
    // Best-effort: sign out from Google if applicable. Some platforms/plugins
    // may throw or require initialization; we guard and ignore failures.
    try {
      // Initialize if the implementation requires it (no-op on others)
      await _googleSignIn.initialize();
    } catch (_) {}
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore Google sign-out errors to avoid blocking logout
    }
  }

  /// Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    }
  }

  /// Get the current user
  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Helper to convert Firebase error codes to user-friendly messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Usuário desativado.';
      case 'email-already-in-use':
        return 'E-mail já está em uso.';
      case 'operation-not-allowed':
        return 'Operação não permitida.';
      case 'weak-password':
        return 'Senha muito fraca.';
      case 'network-request-failed':
        return 'Erro de rede. Tente novamente.';
      default:
        return 'Erro de autenticação: ${e.message}';
    }
  }
}
