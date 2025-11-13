import 'package:flutter/material.dart';

/// Comprehensive validation system for input safety
class ValidationService {
  static final ValidationService _instance = ValidationService._internal();
  factory ValidationService() => _instance;
  ValidationService._internal();

  /// Validate email format
  ValidationResult validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return ValidationResult.error('Email is required');
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(email)) {
      return ValidationResult.error('Invalid email format');
    }

    return ValidationResult.success();
  }

  /// Validate phone number
  ValidationResult validatePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return ValidationResult.error('Phone number is required');
    }

    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    if (!phoneRegex.hasMatch(phone)) {
      return ValidationResult.error('Invalid phone number format');
    }

    return ValidationResult.success();
  }

  /// Validate required field
  ValidationResult validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('$fieldName is required');
    }
    return ValidationResult.success();
  }

  /// Validate minimum length
  ValidationResult validateMinLength(String? value, int minLength, String fieldName) {
    if (value == null || value.length < minLength) {
      return ValidationResult.error('$fieldName must be at least $minLength characters');
    }
    return ValidationResult.success();
  }

  /// Validate maximum length
  ValidationResult validateMaxLength(String? value, int maxLength, String fieldName) {
    if (value != null && value.length > maxLength) {
      return ValidationResult.error('$fieldName must be no more than $maxLength characters');
    }
    return ValidationResult.success();
  }

  /// Validate numeric input
  ValidationResult validateNumeric(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return ValidationResult.error('$fieldName is required');
    }

    if (double.tryParse(value) == null) {
      return ValidationResult.error('$fieldName must be a valid number');
    }

    return ValidationResult.success();
  }

  /// Validate positive number
  ValidationResult validatePositiveNumber(String? value, String fieldName) {
    final numericResult = validateNumeric(value, fieldName);
    if (!numericResult.isValid) return numericResult;

    final number = double.parse(value!);
    if (number <= 0) {
      return ValidationResult.error('$fieldName must be a positive number');
    }

    return ValidationResult.success();
  }

  /// Validate establishment name
  ValidationResult validateEstablishmentName(String? name) {
    final requiredResult = validateRequired(name, 'Establishment name');
    if (!requiredResult.isValid) return requiredResult;

    final lengthResult = validateMinLength(name, 2, 'Establishment name');
    if (!lengthResult.isValid) return lengthResult;

    final maxLengthResult = validateMaxLength(name, 100, 'Establishment name');
    if (!maxLengthResult.isValid) return maxLengthResult;

    // Check for valid characters (letters, numbers, spaces, basic punctuation)
    final validCharsRegex = RegExp(r'^[a-zA-Z0-9\s\.\-]+$');
    if (!validCharsRegex.hasMatch(name!)) {
      return ValidationResult.error('Establishment name contains invalid characters');
    }

    return ValidationResult.success();
  }

  /// Validate address
  ValidationResult validateAddress(String? address) {
    final requiredResult = validateRequired(address, 'Address');
    if (!requiredResult.isValid) return requiredResult;

    final lengthResult = validateMinLength(address, 5, 'Address');
    if (!lengthResult.isValid) return lengthResult;

    final maxLengthResult = validateMaxLength(address, 200, 'Address');
    if (!maxLengthResult.isValid) return maxLengthResult;

    return ValidationResult.success();
  }

  /// Sanitize input to prevent injection attacks
  String sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true), '') // Remove script tags and content
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'alert\([^)]*\)', caseSensitive: false), '') // Remove alert functions
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '') // Remove javascript: protocols
        .replaceAll(RegExp(r'[&<>"/]'), '') // Remove potentially dangerous characters
        .trim();
  }

  /// Validate and sanitize search query
  ValidationResult validateSearchQuery(String? query) {
    if (query == null || query.trim().isEmpty) {
      return ValidationResult.success(); // Empty search is allowed
    }

    final maxLengthResult = validateMaxLength(query, 50, 'Search query');
    if (!maxLengthResult.isValid) return maxLengthResult;

    // Sanitize the query
    final sanitized = sanitizeInput(query);
    if (sanitized != query) {
      return ValidationResult.error('Search query contains invalid characters');
    }

    return ValidationResult.success();
  }

  /// Validate URL format
  ValidationResult validateUrl(String? url) {
    if (url == null || url.isEmpty) {
      return ValidationResult.error('URL is required');
    }

    try {
      final uri = Uri.parse(url);
      if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
        return ValidationResult.error('Invalid URL format');
      }
      return ValidationResult.success();
    } catch (e) {
      return ValidationResult.error('Invalid URL format');
    }
  }

  /// Composite validation for form fields
  ValidationResult validateField(String? value, List<Validator> validators) {
    for (final validator in validators) {
      final result = validator.validate(value);
      if (!result.isValid) {
        return result;
      }
    }
    return ValidationResult.success();
  }
}

/// Result of a validation operation
class ValidationResult {
  final bool isValid;
  final String? error;

  ValidationResult._(this.isValid, this.error);

  factory ValidationResult.success() => ValidationResult._(true, null);
  factory ValidationResult.error(String error) => ValidationResult._(false, error);

  @override
  String toString() => isValid ? 'Valid' : 'Invalid: $error';
}

/// Abstract validator interface
abstract class Validator {
  ValidationResult validate(String? value);
}

/// Required field validator
class RequiredValidator implements Validator {
  final String fieldName;

  RequiredValidator(this.fieldName);

  @override
  ValidationResult validate(String? value) {
    return ValidationService().validateRequired(value, fieldName);
  }
}

/// Email validator
class EmailValidator implements Validator {
  @override
  ValidationResult validate(String? value) {
    return ValidationService().validateEmail(value);
  }
}

/// Phone validator
class PhoneValidator implements Validator {
  @override
  ValidationResult validate(String? value) {
    return ValidationService().validatePhoneNumber(value);
  }
}

/// Length validator
class LengthValidator implements Validator {
  final int? minLength;
  final int? maxLength;
  final String fieldName;

  LengthValidator({
    required this.fieldName,
    this.minLength,
    this.maxLength,
  });

  @override
  ValidationResult validate(String? value) {
    if (minLength != null) {
      final result = ValidationService().validateMinLength(value, minLength!, fieldName);
      if (!result.isValid) return result;
    }

    if (maxLength != null) {
      final result = ValidationService().validateMaxLength(value, maxLength!, fieldName);
      if (!result.isValid) return result;
    }

    return ValidationResult.success();
  }
}

/// Safe TextFormField with built-in validation
class SafeTextFormField extends StatelessWidget {
  final String? initialValue;
  final String? hintText;
  final String? labelText;
  final List<Validator> validators;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLength;
  final int? maxLines;
  final bool enabled;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final bool autofocus;

  const SafeTextFormField({
    super.key,
    this.initialValue,
    this.hintText,
    this.labelText,
    this.validators = const [],
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.maxLength,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.onSaved,
    this.focusNode,
    this.textInputAction,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      maxLines: maxLines,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      autofocus: autofocus,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
      ),
      validator: (value) {
        final result = ValidationService().validateField(value, validators);
        return result.isValid ? null : result.error;
      },
      onChanged: (value) {
        // Sanitize input on change
        final sanitized = ValidationService().sanitizeInput(value);
        if (sanitized != value && controller != null) {
          controller!.value = controller!.value.copyWith(
            text: sanitized,
            selection: TextSelection.collapsed(offset: sanitized.length),
          );
        }
        onChanged?.call(sanitized);
      },
      onSaved: onSaved,
    );
  }
}