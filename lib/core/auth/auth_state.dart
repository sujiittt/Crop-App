import 'package:shared_preferences/shared_preferences.dart';

class AuthState {
  static const _loginKey = 'is_logged_in';

  AuthState._internal();
  static final AuthState instance = AuthState._internal();

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_loginKey) ?? false;
  }

  /// Mark user as logged in
  Future<void> setLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, true);
  }

  /// Mark user as logged out
  Future<void> setLoggedOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_loginKey, false);
  }
}
