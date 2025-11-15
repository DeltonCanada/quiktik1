import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../utils/validator.dart';
import '../utils/error_handler.dart';

/// Comprehensive security service for QuikTik application
/// Provides security measures including encryption, validation, and secure storage
class SecurityService {
  static final SecurityService _instance = SecurityService._internal();
  factory SecurityService() => _instance;
  SecurityService._internal();

  static const String _secureStorageKey = 'quiktik_secure_data';
  final Map<String, dynamic> _secureCache = {};
  bool _isInitialized = false;

  /// Initialize security service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize security measures
      await _setupSecureEnvironment();
      _isInitialized = true;
    } catch (error, stackTrace) {
      QuikTikErrorHandler.logError(
          error, stackTrace, 'Security Service Initialization');
    }
  }

  /// Setup secure environment
  Future<void> _setupSecureEnvironment() async {
    // Disable debug logging in production
    if (!kDebugMode) {
      // In production, disable debug prints
      debugPrint = (String? message, {int? wrapWidth}) {};
    }

    // Clear any sensitive data from previous sessions
    _secureCache.clear();
  }

  /// Validate and sanitize API request data
  Map<String, dynamic> sanitizeApiRequest(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};

    for (final entry in data.entries) {
      final key = _sanitizeKey(entry.key);
      final value = _sanitizeValue(entry.value);

      if (key.isNotEmpty && value != null) {
        sanitized[key] = value;
      }
    }

    return sanitized;
  }

  /// Sanitize map keys
  String _sanitizeKey(String key) {
    return QuikTikValidator.sanitizeInput(key)
        .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '')
        .toLowerCase();
  }

  /// Sanitize values based on type
  dynamic _sanitizeValue(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      return QuikTikValidator.sanitizeInput(value);
    } else if (value is Map<String, dynamic>) {
      return sanitizeApiRequest(value);
    } else if (value is List) {
      return value.map((item) => _sanitizeValue(item)).toList();
    } else if (value is num || value is bool) {
      return value;
    }

    return value.toString();
  }

  /// Validate API response for security
  bool validateApiResponse(Map<String, dynamic> response) {
    try {
      // Check for required security headers/fields
      if (!response.containsKey('timestamp')) {
        return false;
      }

      // Validate response structure
      if (response.isEmpty) {
        return false;
      }

      // Check for malicious content
      final jsonString = jsonEncode(response);
      if (_containsMaliciousContent(jsonString)) {
        return false;
      }

      return true;
    } catch (error) {
      return false;
    }
  }

  /// Check for potentially malicious content
  bool _containsMaliciousContent(String content) {
    final maliciousPatterns = [
      r'<script.*?>.*?</script>',
      r'javascript:',
      r'vbscript:',
      r'onload=',
      r'onerror=',
      r'eval\(',
      r'document\.cookie',
    ];

    for (final pattern in maliciousPatterns) {
      if (RegExp(pattern, caseSensitive: false).hasMatch(content)) {
        return true;
      }
    }

    return false;
  }

  /// Generate secure random string
  String generateSecureToken({int length = 32}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();

    return List.generate(length, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /// Simple encryption for sensitive data (for demo purposes - use proper encryption in production)
  String encryptData(String data, String key) {
    try {
      final dataBytes = utf8.encode(data);
      final keyBytes = utf8.encode(key.padRight(32, '0').substring(0, 32));

      final encrypted = <int>[];
      for (int i = 0; i < dataBytes.length; i++) {
        encrypted.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return base64Encode(encrypted);
    } catch (error) {
      throw SecurityException('Failed to encrypt data');
    }
  }

  /// Simple decryption for sensitive data (for demo purposes - use proper encryption in production)
  String decryptData(String encryptedData, String key) {
    try {
      final encrypted = base64Decode(encryptedData);
      final keyBytes = utf8.encode(key.padRight(32, '0').substring(0, 32));

      final decrypted = <int>[];
      for (int i = 0; i < encrypted.length; i++) {
        decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(decrypted);
    } catch (error) {
      throw SecurityException('Failed to decrypt data');
    }
  }

  /// Store sensitive data securely
  Future<void> storeSecureData(String key, dynamic value) async {
    try {
      final secureKey = _generateSecureKey(key);
      final serializedValue = jsonEncode(value);
      final encryptedValue = encryptData(serializedValue, secureKey);

      _secureCache[key] = encryptedValue;
    } catch (error, stackTrace) {
      QuikTikErrorHandler.logError(error, stackTrace, 'Secure Data Storage');
      throw SecurityException('Failed to store secure data');
    }
  }

  /// Retrieve sensitive data securely
  Future<T?> getSecureData<T>(String key) async {
    try {
      final encryptedValue = _secureCache[key];
      if (encryptedValue == null) return null;

      final secureKey = _generateSecureKey(key);
      final decryptedValue = decryptData(encryptedValue, secureKey);
      final deserializedValue = jsonDecode(decryptedValue);

      return deserializedValue as T?;
    } catch (error, stackTrace) {
      QuikTikErrorHandler.logError(error, stackTrace, 'Secure Data Retrieval');
      return null;
    }
  }

  /// Remove sensitive data
  Future<void> removeSecureData(String key) async {
    _secureCache.remove(key);
  }

  /// Clear all sensitive data
  Future<void> clearAllSecureData() async {
    _secureCache.clear();
  }

  /// Generate a secure key for encryption
  String _generateSecureKey(String baseKey) {
    return '$baseKey-$_secureStorageKey-${DateTime.now().day}';
  }

  /// Validate network request security
  bool validateNetworkRequest(Uri uri, {Map<String, String>? headers}) {
    // Ensure HTTPS in production
    if (!kDebugMode && uri.scheme != 'https') {
      return false;
    }

    // Validate host
    if (uri.host.isEmpty) {
      return false;
    }

    // Check for suspicious headers
    if (headers != null) {
      for (final header in headers.entries) {
        if (_containsMaliciousContent(header.key) ||
            _containsMaliciousContent(header.value)) {
          return false;
        }
      }
    }

    return true;
  }

  /// Rate limiting for API calls
  final Map<String, List<DateTime>> _apiCallHistory = {};
  static const int _maxCallsPerMinute = 60;

  bool checkRateLimit(String endpoint) {
    final now = DateTime.now();
    final calls = _apiCallHistory[endpoint] ?? [];

    // Remove calls older than 1 minute
    calls.removeWhere((call) => now.difference(call).inMinutes >= 1);

    if (calls.length >= _maxCallsPerMinute) {
      return false; // Rate limit exceeded
    }

    calls.add(now);
    _apiCallHistory[endpoint] = calls;
    return true;
  }

  /// Secure random number generation
  int generateSecureRandomInt(int min, int max) {
    final random = Random.secure();
    return min + random.nextInt(max - min + 1);
  }

  /// Hash sensitive data (simple implementation - use proper hashing in production)
  String hashData(String data, String salt) {
    final combined = '$data$salt';
    final bytes = utf8.encode(combined);

    // Simple hash implementation (use crypto library in production)
    int hash = 0;
    for (final byte in bytes) {
      hash = ((hash << 5) - hash + byte) & 0xffffffff;
    }

    return hash.toRadixString(16);
  }

  /// Verify data integrity
  bool verifyDataIntegrity(String data, String expectedHash, String salt) {
    final actualHash = hashData(data, salt);
    return actualHash == expectedHash;
  }

  /// Clear sensitive data when app goes to background
  void onAppBackground() {
    if (!kDebugMode) {
      // Clear sensitive cache data
      _secureCache.clear();

      // Clear clipboard if it contains sensitive data
      Clipboard.setData(const ClipboardData(text: ''));
    }
  }

  /// Dispose security service
  void dispose() {
    clearAllSecureData();
    _apiCallHistory.clear();
    _isInitialized = false;
  }
}

/// Security exception class
class SecurityException implements Exception {
  final String message;
  SecurityException(this.message);

  @override
  String toString() => 'SecurityException: $message';
}

/// Security mixin for widgets that handle sensitive data
mixin SecurityMixin {
  /// Validate form input securely
  String? validateSecureInput(
    String? value, {
    required String fieldName,
    bool required = false,
    int? minLength,
    int? maxLength,
    String? pattern,
  }) {
    final validation = QuikTikValidator.validateUserInput(
      fieldName,
      value,
      required: required,
      minLength: minLength,
      maxLength: maxLength,
      pattern: pattern,
    );

    return validation.isValid ? null : validation.errorMessage;
  }

  /// Secure form submission
  Future<bool> submitFormSecurely(
    Map<String, dynamic> formData,
    Future<bool> Function(Map<String, dynamic>) submitFunction,
  ) async {
    try {
      // Sanitize form data
      final sanitizedData = SecurityService().sanitizeApiRequest(formData);

      // Submit data
      return await submitFunction(sanitizedData);
    } catch (error, stackTrace) {
      QuikTikErrorHandler.logError(error, stackTrace, 'Secure Form Submission');
      return false;
    }
  }
}
