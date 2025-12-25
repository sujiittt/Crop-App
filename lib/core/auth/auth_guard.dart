import 'package:flutter/material.dart';
import '../../presentation/auth/widgets/soft_login_prompt.dart';
import '../../presentation/auth/login_screen.dart';

class AuthGuard {
  static Future<bool> ensureLoggedIn(
      BuildContext context, {
        required bool isLoggedIn,
        required VoidCallback onLogin,
      }) async {
    if (isLoggedIn) {
      return true;
    }

    // Open soft prompt
    await SoftLoginPrompt.show(
      context,
      onContinue: () {
        Navigator.pop(context);

        // Wait 200ms so the bottom sheet can close safely
        Future.delayed(const Duration(milliseconds: 200), () {
          Navigator.pushNamed(context, LoginScreen.routeName);
        });

        onLogin();
      },
    );

    return false;
  }
}
