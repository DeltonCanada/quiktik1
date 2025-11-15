import 'package:flutter_test/flutter_test.dart';
import 'package:quiktik1/services/error_handler.dart';

void main() {
  group('GlobalErrorHandler Tests', () {
    late GlobalErrorHandler errorHandler;

    setUp(() {
      errorHandler = GlobalErrorHandler();
      errorHandler.clearErrors();
    });

    test('should initialize without errors', () {
      expect(errorHandler.errors, isEmpty);
    });

    test('should add and track errors correctly', () {
      final error = AppError(
        message: 'Test error',
        stackTrace: 'Test stack trace',
        type: ErrorType.business,
        severity: ErrorSeverity.medium,
        timestamp: DateTime.now(),
        context: 'Test context',
      );

      errorHandler.reportError(error);

      expect(errorHandler.errors.length, 1);
      expect(errorHandler.errors.first.message, 'Test error');
    });

    test('should stream errors correctly', () async {
      final error = AppError(
        message: 'Streamed error',
        stackTrace: 'Stack trace',
        type: ErrorType.network,
        severity: ErrorSeverity.high,
        timestamp: DateTime.now(),
        context: 'Stream test',
      );

      // Listen to error stream
      final errorStream = errorHandler.errorStream;
      final streamErrors = <AppError>[];
      final subscription = errorStream.listen((error) {
        streamErrors.add(error);
      });

      // Report error
      errorHandler.reportError(error);

      // Wait for stream to process
      await Future.delayed(const Duration(milliseconds: 10));

      expect(streamErrors.length, 1);
      expect(streamErrors.first.message, 'Streamed error');

      await subscription.cancel();
    });

    test('should clear errors correctly', () {
      final error = AppError(
        message: 'Error to clear',
        stackTrace: '',
        type: ErrorType.platform,
        severity: ErrorSeverity.low,
        timestamp: DateTime.now(),
        context: 'Clear test',
      );

      errorHandler.reportError(error);
      expect(errorHandler.errors.length, 1);

      errorHandler.clearErrors();
      expect(errorHandler.errors, isEmpty);
    });
  });

  group('AppError Tests', () {
    test('should create AppError with all properties', () {
      final timestamp = DateTime.now();
      final error = AppError(
        message: 'Test message',
        stackTrace: 'Test stack trace',
        type: ErrorType.security,
        severity: ErrorSeverity.critical,
        timestamp: timestamp,
        context: 'Test context',
        additionalData: {'key': 'value'},
      );

      expect(error.message, 'Test message');
      expect(error.stackTrace, 'Test stack trace');
      expect(error.type, ErrorType.security);
      expect(error.severity, ErrorSeverity.critical);
      expect(error.timestamp, timestamp);
      expect(error.context, 'Test context');
      expect(error.additionalData?['key'], 'value');
    });

    test('should have correct toString representation', () {
      final error = AppError(
        message: 'Test error',
        stackTrace: '',
        type: ErrorType.flutter,
        severity: ErrorSeverity.medium,
        timestamp: DateTime.now(),
        context: 'toString test',
      );

      final errorString = error.toString();
      expect(errorString, contains('Test error'));
      expect(errorString, contains('flutter'));
      expect(errorString, contains('medium'));
      expect(errorString, contains('toString test'));
    });
  });

  group('ErrorSeverity Tests', () {
    test('should have all severity levels', () {
      expect(ErrorSeverity.values.length, 4);
      expect(ErrorSeverity.values, contains(ErrorSeverity.low));
      expect(ErrorSeverity.values, contains(ErrorSeverity.medium));
      expect(ErrorSeverity.values, contains(ErrorSeverity.high));
      expect(ErrorSeverity.values, contains(ErrorSeverity.critical));
    });
  });

  group('ErrorType Tests', () {
    test('should have all error types', () {
      expect(ErrorType.values.length, 6);
      expect(ErrorType.values, contains(ErrorType.flutter));
      expect(ErrorType.values, contains(ErrorType.platform));
      expect(ErrorType.values, contains(ErrorType.network));
      expect(ErrorType.values, contains(ErrorType.validation));
      expect(ErrorType.values, contains(ErrorType.business));
      expect(ErrorType.values, contains(ErrorType.security));
    });
  });
}
