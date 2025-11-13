import 'package:flutter_test/flutter_test.dart';
import 'package:quiktik1/utils/validator.dart';

void main() {
  group('QuikTikValidator Tests', () {
    group('Email Validation', () {
      test('should return true for valid emails', () {
        expect(QuikTikValidator.isValidEmail('test@example.com'), true);
        expect(QuikTikValidator.isValidEmail('user.name@domain.co.uk'), true);
        expect(QuikTikValidator.isValidEmail('test123@test-domain.org'), true);
      });

      test('should return false for invalid emails', () {
        expect(QuikTikValidator.isValidEmail('invalid-email'), false);
        expect(QuikTikValidator.isValidEmail('test@'), false);
        expect(QuikTikValidator.isValidEmail('@domain.com'), false);
        expect(QuikTikValidator.isValidEmail(''), false);
        expect(QuikTikValidator.isValidEmail(null), false);
      });
    });

    group('Phone Number Validation', () {
      test('should return true for valid phone numbers', () {
        expect(QuikTikValidator.isValidPhoneNumber('+1234567890'), true);
        expect(QuikTikValidator.isValidPhoneNumber('123-456-7890'), true);
        expect(QuikTikValidator.isValidPhoneNumber('(123) 456-7890'), true);
      });

      test('should return false for invalid phone numbers', () {
        expect(QuikTikValidator.isValidPhoneNumber('123'), false);
        expect(QuikTikValidator.isValidPhoneNumber('abc'), false);
        expect(QuikTikValidator.isValidPhoneNumber(''), false);
        expect(QuikTikValidator.isValidPhoneNumber(null), false);
      });
    });

    group('Safe Type Conversions', () {
      test('safeString should handle null and various types', () {
        expect(QuikTikValidator.safeString(null), '');
        expect(QuikTikValidator.safeString('test'), 'test');
        expect(QuikTikValidator.safeString(123), '123');
        expect(QuikTikValidator.safeString(true), 'true');
      });

      test('safeInt should handle null and various types', () {
        expect(QuikTikValidator.safeInt(null), 0);
        expect(QuikTikValidator.safeInt(123), 123);
        expect(QuikTikValidator.safeInt('456'), 456);
        expect(QuikTikValidator.safeInt('invalid'), 0);
        expect(QuikTikValidator.safeInt(12.5), 12);
      });

      test('safeDouble should handle null and various types', () {
        expect(QuikTikValidator.safeDouble(null), 0.0);
        expect(QuikTikValidator.safeDouble(123.45), 123.45);
        expect(QuikTikValidator.safeDouble('456.78'), 456.78);
        expect(QuikTikValidator.safeDouble('invalid'), 0.0);
        expect(QuikTikValidator.safeDouble(12), 12.0);
      });

      test('safeBool should handle null and various types', () {
        expect(QuikTikValidator.safeBool(null), false);
        expect(QuikTikValidator.safeBool(true), true);
        expect(QuikTikValidator.safeBool('true'), true);
        expect(QuikTikValidator.safeBool('1'), true);
        expect(QuikTikValidator.safeBool(1), true);
        expect(QuikTikValidator.safeBool(0), false);
      });
    });

    group('Input Validation', () {
      test('should validate required fields', () {
        final result = QuikTikValidator.validateUserInput(
          'Name', 
          'John Doe', 
          required: true,
        );
        expect(result.isValid, true);
      });

      test('should fail validation for empty required fields', () {
        final result = QuikTikValidator.validateUserInput(
          'Name', 
          '', 
          required: true,
        );
        expect(result.isValid, false);
        expect(result.errorMessage, contains('required'));
      });

      test('should validate minimum length', () {
        final result = QuikTikValidator.validateUserInput(
          'Name', 
          'Jo', 
          minLength: 3,
        );
        expect(result.isValid, false);
        expect(result.errorMessage, contains('at least 3'));
      });

      test('should validate maximum length', () {
        final result = QuikTikValidator.validateUserInput(
          'Name', 
          'This is a very long name that exceeds the limit', 
          maxLength: 20,
        );
        expect(result.isValid, false);
        expect(result.errorMessage, contains('not exceed 20'));
      });
    });

    group('Sanitization', () {
      test('should remove HTML tags', () {
        final result = QuikTikValidator.sanitizeInput('<script>alert("test")</script>Hello');
        expect(result, 'Hello');
      });

      test('should handle null input', () {
        final result = QuikTikValidator.sanitizeInput(null);
        expect(result, '');
      });

      test('should trim whitespace', () {
        final result = QuikTikValidator.sanitizeInput('  Hello World  ');
        expect(result, 'Hello World');
      });
    });

    group('Date Validation', () {
      test('should validate correct date formats', () {
        expect(QuikTikValidator.isValidDate('2023-12-25'), true);
        expect(QuikTikValidator.isValidDate('2023-12-25T10:30:00'), true);
      });

      test('should reject invalid date formats', () {
        expect(QuikTikValidator.isValidDate('invalid-date'), false);
        expect(QuikTikValidator.isValidDate('2023-13-45'), false);
        expect(QuikTikValidator.isValidDate(''), false);
        expect(QuikTikValidator.isValidDate(null), false);
      });
    });

    group('Extension Methods', () {
      test('SafeStringExtension should work correctly', () {
        String? nullString;
        String? emptyString = '';
        String? validString = 'test';

        expect(nullString.orEmpty(), '');
        expect(emptyString.orEmpty(), '');
        expect(validString.orEmpty(), 'test');

        expect(nullString.isNullOrEmpty, true);
        expect(emptyString.isNullOrEmpty, true);
        expect(validString.isNullOrEmpty, false);

        expect('123'.toIntOrDefault(), 123);
        expect('invalid'.toIntOrDefault(999), 999);
      });

      test('SafeListExtension should work correctly', () {
        List<int>? nullList;
        List<int>? emptyList = [];
        List<int>? validList = [1, 2, 3];

        expect(nullList.orEmpty(), []);
        expect(emptyList.orEmpty(), []);
        expect(validList.orEmpty(), [1, 2, 3]);

        expect(nullList.isNullOrEmpty, true);
        expect(emptyList.isNullOrEmpty, true);
        expect(validList.isNullOrEmpty, false);

        expect(validList.safeElementAt(1), 2);
        expect(validList.safeElementAt(10), null);
      });
    });
  });
}