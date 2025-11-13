import 'dart:convert';

/// Comprehensive validation system for QuikTik app
/// This system prevents runtime errors by validating all inputs before processing
class QuikTikValidator {
  // Email validation
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Phone number validation
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) return false;
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(phone);
  }

  // Name validation
  static bool isValidName(String? name) {
    if (name == null || name.isEmpty) return false;
    return name.trim().length >= 2 && name.trim().length <= 50;
  }

  // Password validation
  static bool isValidPassword(String? password) {
    if (password == null || password.isEmpty) return false;
    return password.length >= 8 && 
           password.contains(RegExp(r'[A-Z]')) &&
           password.contains(RegExp(r'[a-z]')) &&
           password.contains(RegExp(r'[0-9]'));
  }

  // Safe string conversion
  static String safeString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  // Safe integer conversion
  static int safeInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  // Safe double conversion
  static double safeDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  // Safe boolean conversion
  static bool safeBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return defaultValue;
  }

  // Safe list validation
  static List<T> safeList<T>(dynamic value, {List<T>? defaultValue}) {
    defaultValue ??= <T>[];
    if (value == null) return defaultValue;
    if (value is List<T>) return value;
    if (value is List) {
      try {
        return value.cast<T>();
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  // Safe map validation
  static Map<String, dynamic> safeMap(dynamic value, {Map<String, dynamic>? defaultValue}) {
    defaultValue ??= <String, dynamic>{};
    if (value == null) return defaultValue;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      try {
        return Map<String, dynamic>.from(value);
      } catch (e) {
        return defaultValue;
      }
    }
    return defaultValue;
  }

  // Safe JSON parsing
  static Map<String, dynamic> safeJsonDecode(String? jsonString) {
    if (jsonString == null || jsonString.isEmpty) return {};
    try {
      final decoded = jsonDecode(jsonString);
      return safeMap(decoded);
    } catch (e) {
      return {};
    }
  }

  // Validate required fields
  static ValidationResult validateRequired(Map<String, dynamic> data, List<String> requiredFields) {
    final missingFields = <String>[];
    
    for (final field in requiredFields) {
      final value = data[field];
      if (value == null || 
          (value is String && value.trim().isEmpty) ||
          (value is List && value.isEmpty) ||
          (value is Map && value.isEmpty)) {
        missingFields.add(field);
      }
    }
    
    if (missingFields.isNotEmpty) {
      return ValidationResult.failure(
        'Missing required fields: ${missingFields.join(', ')}'
      );
    }
    
    return ValidationResult.success();
  }

  // Validate establishment data
  static ValidationResult validateEstablishment(Map<String, dynamic> data) {
    final requiredFields = ['id', 'name', 'address'];
    final requiredValidation = validateRequired(data, requiredFields);
    if (!requiredValidation.isValid) return requiredValidation;

    final name = safeString(data['name']);
    if (name.length < 2 || name.length > 100) {
      return ValidationResult.failure('Establishment name must be between 2 and 100 characters');
    }

    final address = safeString(data['address']);
    if (address.length < 5 || address.length > 200) {
      return ValidationResult.failure('Address must be between 5 and 200 characters');
    }

    return ValidationResult.success();
  }

  // Validate user input for forms
  static ValidationResult validateUserInput(String fieldName, String? value, {
    bool required = false,
    int? minLength,
    int? maxLength,
    String? pattern,
  }) {
    // Check if required
    if (required && (value == null || value.trim().isEmpty)) {
      return ValidationResult.failure('$fieldName is required');
    }

    // If value is null or empty and not required, it's valid
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.success();
    }

    final trimmedValue = value.trim();

    // Check minimum length
    if (minLength != null && trimmedValue.length < minLength) {
      return ValidationResult.failure('$fieldName must be at least $minLength characters');
    }

    // Check maximum length
    if (maxLength != null && trimmedValue.length > maxLength) {
      return ValidationResult.failure('$fieldName must not exceed $maxLength characters');
    }

    // Check pattern
    if (pattern != null) {
      final regex = RegExp(pattern);
      if (!regex.hasMatch(trimmedValue)) {
        return ValidationResult.failure('$fieldName format is invalid');
      }
    }

    return ValidationResult.success();
  }

  // Sanitize user input to prevent injection attacks (though less relevant in Flutter)
  static String sanitizeInput(String? input) {
    if (input == null) return '';
    
    String sanitized = input.trim();
    
    // Remove script tags and their content
    sanitized = sanitized.replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '');
    
    // Remove all other HTML tags
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>'), '');
    
    // Limit length
    if (sanitized.length > 1000) {
      sanitized = sanitized.substring(0, 1000);
    }
    
    return sanitized;
  }

  // Validate URL
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // Validate queue number
  static ValidationResult validateQueueNumber(dynamic value) {
    final number = safeInt(value);
    if (number <= 0 || number > 999) {
      return ValidationResult.failure('Queue number must be between 1 and 999');
    }
    return ValidationResult.success();
  }

  // Validate time format
  static bool isValidTimeFormat(String? time) {
    if (time == null || time.isEmpty) return false;
    final timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
    return timeRegex.hasMatch(time);
  }

  // Validate date
  static bool isValidDate(String? date) {
    if (date == null || date.isEmpty) return false;
    
    // Use regex to validate basic format first
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}(T\d{2}:\d{2}:\d{2}(\.\d{3})?)?Z?$');
    if (!dateRegex.hasMatch(date)) return false;
    
    try {
      final parts = date.split('T')[0].split('-');
      if (parts.length != 3) return false;
      
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      
      // Validate ranges
      if (year < 1900 || year > 3000) return false;
      if (month < 1 || month > 12) return false;
      if (day < 1 || day > 31) return false;
      
      // Additional validation for specific months
      if (month == 2 && day > 29) return false;
      if ((month == 4 || month == 6 || month == 9 || month == 11) && day > 30) return false;
      
      // Try to parse to ensure it's a valid date
      DateTime.parse('${date.split('T')[0]}T00:00:00Z');
      return true;
    } catch (e) {
      return false;
    }
  }

  // Safe date parsing
  static DateTime? safeParseDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }
}

/// Result class for validation operations
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  ValidationResult._(this.isValid, this.errorMessage);

  factory ValidationResult.success() => ValidationResult._(true, null);
  factory ValidationResult.failure(String message) => ValidationResult._(false, message);

  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $errorMessage';
}

/// Extension methods for safe operations on common types
extension SafeStringExtension on String? {
  String orEmpty() => this ?? '';
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  
  String? get nullIfEmpty => (this?.isEmpty ?? true) ? null : this;
  
  int toIntOrDefault([int defaultValue = 0]) {
    return QuikTikValidator.safeInt(this, defaultValue: defaultValue);
  }
  
  double toDoubleOrDefault([double defaultValue = 0.0]) {
    return QuikTikValidator.safeDouble(this, defaultValue: defaultValue);
  }
}

extension SafeListExtension<T> on List<T>? {
  List<T> orEmpty() => this ?? <T>[];
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  
  T? safeElementAt(int index) {
    if (this == null || index < 0 || index >= this!.length) return null;
    return this![index];
  }
}

extension SafeMapExtension on Map<String, dynamic>? {
  Map<String, dynamic> orEmpty() => this ?? <String, dynamic>{};
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  
  T? safeGet<T>(String key, {T? defaultValue}) {
    if (this == null || !this!.containsKey(key)) return defaultValue;
    final value = this![key];
    if (value is T) return value;
    return defaultValue;
  }
}