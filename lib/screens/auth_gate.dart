import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'auth_selection_screen.dart';
import 'welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.onLocaleChange});

  final Function(Locale) onLocaleChange;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        if (authService.isAuthenticated) {
          return WelcomeScreen(onLocaleChange: onLocaleChange);
        }
        return AuthSelectionScreen(onLocaleChange: onLocaleChange);
      },
    );
  }
}
