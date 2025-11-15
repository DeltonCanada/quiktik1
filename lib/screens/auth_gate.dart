import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/di/app_providers.dart';
import 'auth_selection_screen.dart';
import 'welcome_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key, required this.onLocaleChange});

  final Function(Locale) onLocaleChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    if (authService.isAuthenticated) {
      return WelcomeScreen(onLocaleChange: onLocaleChange);
    }
    return AuthSelectionScreen(onLocaleChange: onLocaleChange);
  }
}
