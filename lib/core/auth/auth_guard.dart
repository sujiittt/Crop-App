import 'package:flutter/material.dart';
import '../../presentation/auth/widgets/soft_login_prompt.dart';

class AuthGuard {
  /// Returns true if action is allowed
  /// Returns false if blocked (login prompt shown)
  static Future<bool> ensureLoggedIn(
      BuildContext context, {
        required bool isLoggedIn,
        required VoidCallback onLogin,
      }) async {
    if (isLoggedIn) {
      return true;
    }

    await SoftLoginPrompt.show(
      context,
      onContinue: onLogin,
    );

    return false;
  }
}
