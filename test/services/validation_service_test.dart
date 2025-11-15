import 'package:flutter_test/flutter_test.dart';
import 'package:quiktik1/services/validation_service.dart';

void main() {
  group('ValidationService Tests', () {
    late ValidationService validationService;

    setUp(() {
      validationService = ValidationService();
    });

    group('Email Validation', () {
      test('should return success for valid email', () {
        final result = validationService.validateEmail('test@example.com');
        expect(result.isValid, true);
      });

      test('should return error for invalid email format', () {
        final result = validationService.validateEmail('invalid-email');
        expect(result.isValid, false);
        expect(result.error, 'Invalid email format');
      });

      test('should return error for empty email', () {
        final result = validationService.validateEmail('');
        expect(result.isValid, false);
        expect(result.error, 'Email is required');
      });

      test('should return error for null email', () {
        final result = validationService.validateEmail(null);
        expect(result.isValid, false);
        expect(result.error, 'Email is required');
      });
    });

    group('Phone Number Validation', () {
      test('should return success for valid phone numbers', () {
        final validPhones = [
          '+1234567890',
          '123-456-7890',
          '(123) 456-7890',
          '123 456 7890',
        ];

        for (final phone in validPhones) {
          final result = validationService.validatePhoneNumber(phone);
          expect(result.isValid, true, reason: 'Failed for phone: $phone');
        }
      });

      test('should return error for invalid phone numbers', () {
        final invalidPhones = [
          '123',
          'abc123',
          '++123456',
        ];

        for (final phone in invalidPhones) {
          final result = validationService.validatePhoneNumber(phone);
          expect(result.isValid, false,
              reason: 'Should fail for phone: $phone');
        }
      });
    });

    group('Required Field Validation', () {
      test('should return success for non-empty values', () {
        final result = validationService.validateRequired('test', 'Field');
        expect(result.isValid, true);
      });

      test('should return error for empty values', () {
        final result = validationService.validateRequired('', 'Field');
        expect(result.isValid, false);
        expect(result.error, 'Field is required');
      });

      test('should return error for whitespace-only values', () {
        final result = validationService.validateRequired('   ', 'Field');
        expect(result.isValid, false);
        expect(result.error, 'Field is required');
      });
    });

    group('Length Validation', () {
      test('should validate minimum length correctly', () {
        final validResult =
            validationService.validateMinLength('hello', 3, 'Field');
        expect(validResult.isValid, true);

        final invalidResult =
            validationService.validateMinLength('hi', 3, 'Field');
        expect(invalidResult.isValid, false);
        expect(invalidResult.error, 'Field must be at least 3 characters');
      });

      test('should validate maximum length correctly', () {
        final validResult =
            validationService.validateMaxLength('hi', 3, 'Field');
        expect(validResult.isValid, true);

        final invalidResult =
            validationService.validateMaxLength('hello', 3, 'Field');
        expect(invalidResult.isValid, false);
        expect(invalidResult.error, 'Field must be no more than 3 characters');
      });
    });

    group('Numeric Validation', () {
      test('should validate numeric values correctly', () {
        final validResults = [
          validationService.validateNumeric('123', 'Field'),
          validationService.validateNumeric('123.45', 'Field'),
          validationService.validateNumeric('-123', 'Field'),
        ];

        for (final result in validResults) {
          expect(result.isValid, true);
        }
      });

      test('should reject non-numeric values', () {
        final invalidResults = [
          validationService.validateNumeric('abc', 'Field'),
          validationService.validateNumeric('12a', 'Field'),
          validationService.validateNumeric('', 'Field'),
        ];

        for (final result in invalidResults) {
          expect(result.isValid, false);
        }
      });
    });

    group('Positive Number Validation', () {
      test('should validate positive numbers correctly', () {
        final validResults = [
          validationService.validatePositiveNumber('123', 'Field'),
          validationService.validatePositiveNumber('0.1', 'Field'),
        ];

        for (final result in validResults) {
          expect(result.isValid, true);
        }
      });

      test('should reject non-positive numbers', () {
        final invalidResults = [
          validationService.validatePositiveNumber('0', 'Field'),
          validationService.validatePositiveNumber('-1', 'Field'),
        ];

        for (final result in invalidResults) {
          expect(result.isValid, false);
        }
      });
    });

    group('Input Sanitization', () {
      test('should remove HTML tags', () {
        const String input = '<script>alert("xss")</script>Hello';
        final sanitized = validationService.sanitizeInput(input);
        expect(sanitized, 'Hello');
      });

      test('should remove dangerous characters', () {
        const String input = 'Hello<>&"World';
        final sanitized = validationService.sanitizeInput(input);
        expect(sanitized, 'HelloWorld');
      });

      test('should trim whitespace', () {
        const String input = '  Hello World  ';
        final sanitized = validationService.sanitizeInput(input);
        expect(sanitized, 'Hello World');
      });
    });

    group('URL Validation', () {
      test('should validate correct URLs', () {
        final validUrls = [
          'https://example.com',
          'http://test.org',
          'https://sub.domain.com/path',
        ];

        for (final url in validUrls) {
          final result = validationService.validateUrl(url);
          expect(result.isValid, true, reason: 'Should be valid: $url');
        }
      });

      test('should reject invalid URLs', () {
        final invalidUrls = [
          'not-a-url',
          'ftp://example.com',
          '',
        ];

        for (final url in invalidUrls) {
          final result = validationService.validateUrl(url);
          expect(result.isValid, false, reason: 'Should be invalid: $url');
        }
      });
    });
  });
}
