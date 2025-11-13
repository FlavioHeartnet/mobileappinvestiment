import 'dart:async';

class AuthService {
  const AuthService();

  /// Simulate a network login. Accepts 'demo' / 'demo' as valid credentials.
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (username.trim() == 'demo' && password == 'demo') return true;
    // simple local rule: accept any non-empty username with password 'password' for testing
    if (username.trim().isNotEmpty && password == 'password') return true;
    return false;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
