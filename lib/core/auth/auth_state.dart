import 'package:firebase_auth/firebase_auth.dart';

class AuthState {
  AuthState._internal();
  static final AuthState instance = AuthState._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if user is logged in
  bool get isLoggedInSync => _auth.currentUser != null;

  /// Async check (useful later)
  Future<bool> isLoggedIn() async {
    return _auth.currentUser != null;
  }

  /// Current user
  User? get currentUser => _auth.currentUser;

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
