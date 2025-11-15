import 'package:flutter/foundation.dart';

/// Simple in-memory authentication service used to gate customer access.
///
/// This intentionally keeps credentials local for demo purposes. In a real
/// deployment you would replace this with a backend-backed solution.
class AuthService extends ChangeNotifier {
  AuthService() {
    // Provide a demo account so the experience works out-of-the-box.
    _users['demo@quiktik.com'] = const _AuthUser(
      name: 'Demo Customer',
      email: 'demo@quiktik.com',
      password: 'password123',
    );
  }

  final Map<String, _AuthUser> _users = {};
  _AuthUser? _currentUser;

  bool get isAuthenticated => _currentUser != null;
  String? get currentUserEmail => _currentUser?.email;
  String? get currentUserName => _currentUser?.name;

  Future<void> login(String email, String password) async {
    final normalizedEmail = _normalizeEmail(email);
    final sanitizedPassword = password.trim();
    await Future.delayed(const Duration(milliseconds: 250));

    final existingUser = _users[normalizedEmail];

    if (existingUser == null) {
      final generatedUser = _AuthUser(
        name: _deriveDisplayNameFromEmail(normalizedEmail),
        email: normalizedEmail,
        password: sanitizedPassword,
      );
      _users[normalizedEmail] = generatedUser;
      _currentUser = generatedUser;
    } else {
      final updatedUser = _AuthUser(
        name: existingUser.name,
        email: existingUser.email,
        password: sanitizedPassword.isEmpty
            ? existingUser.password
            : sanitizedPassword,
      );
      _users[normalizedEmail] = updatedUser;
      _currentUser = updatedUser;
    }

    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    final normalizedEmail = _normalizeEmail(email);
    await Future.delayed(const Duration(milliseconds: 250));

    if (_users.containsKey(normalizedEmail)) {
      throw const AuthException('An account with that email already exists.');
    }

    final user = _AuthUser(
      name: name.trim(),
      email: normalizedEmail,
      password: password,
    );
    _users[normalizedEmail] = user;
    _currentUser = user;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();
  String _deriveDisplayNameFromEmail(String email) {
    final localPart = email.split('@').first;
    if (localPart.isEmpty) {
      return 'QuikTik User';
    }

    final segments = localPart
        .split(RegExp(r'[._-]+'))
        .where((segment) => segment.isNotEmpty);
    if (segments.isEmpty) {
      return localPart;
    }

    return segments
        .map((segment) => segment[0].toUpperCase() + segment.substring(1))
        .join(' ');
  }
}

class _AuthUser {
  const _AuthUser(
      {required this.name, required this.email, required this.password});

  final String name;
  final String email;
  final String password;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}
