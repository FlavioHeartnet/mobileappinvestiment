import 'package:firebase_auth/firebase_auth.dart';
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
      // Update the user's display name
      await userCredential.user?.updateDisplayName(name);
      return true;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    }
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return false; // User cancelled the sign-in

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await _firebaseAuth.signInWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      throw _getErrorMessage(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _googleSignIn.signOut(),
    ]);
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
