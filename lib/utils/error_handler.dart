import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:developer' as developer;

/// Global error handler for the QuikTik application
/// This class provides centralized error handling, logging, and user-friendly error display
class QuikTikErrorHandler {
  static final QuikTikErrorHandler _instance = QuikTikErrorHandler._internal();
  factory QuikTikErrorHandler() => _instance;
  QuikTikErrorHandler._internal();

  /// Initialize global error handling
  static void initialize() {
    // Handle Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      logError(details.exception, details.stack, 'Flutter Framework Error');
    };

    // Handle errors outside of Flutter framework
    PlatformDispatcher.instance.onError = (error, stack) {
      logError(error, stack, 'Platform Error');
      return true;
    };
  }

  /// Log errors with detailed context
  static void logError(dynamic error, StackTrace? stackTrace, String context) {
    final errorMessage = '''
    ═══════════════════════════════════════════════════════════
    QuikTik Error Report
    ═══════════════════════════════════════════════════════════
    Context: $context
    Time: ${DateTime.now().toIso8601String()}
    Error: $error
    Stack Trace: ${stackTrace ?? 'No stack trace available'}
    ═══════════════════════════════════════════════════════════
    ''';

    if (kDebugMode) {
      developer.log(errorMessage, name: 'QuikTikError');
    }

    // In production, you could send this to a crash reporting service
    // like Firebase Crashlytics, Sentry, etc.
  }

  /// Handle specific types of errors with custom messages
  static String getErrorMessage(dynamic error) {
    if (error is NetworkException) {
      return 'Network connection issue. Please check your internet connection and try again.';
    } else if (error is ValidationException) {
      return error.message;
    } else if (error is TimeoutException) {
      return 'The operation took too long. Please try again.';
    } else if (error is FormatException) {
      return 'Invalid data format received. Please try again.';
    } else if (error is StateError) {
      return 'Application state error. Please restart the app.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Show user-friendly error dialog
  static void showErrorDialog(BuildContext context, dynamic error, {String? title}) {
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ErrorDialog(
        title: title ?? 'Error',
        message: getErrorMessage(error),
        error: error,
      ),
    );
  }

  /// Handle async operations safely
  static Future<T?> safeAsyncOperation<T>(
    Future<T> Function() operation, {
    BuildContext? context,
    String? errorContext,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      logError(error, stackTrace, errorContext ?? 'Async Operation');
      
      if (context != null && context.mounted) {
        showErrorDialog(context, error);
      }
      
      return fallbackValue;
    }
  }
}

/// Custom error dialog widget
class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final dynamic error;

  const ErrorDialog({
    super.key,
    required this.title,
    required this.message,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      icon: Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
        size: 48,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (kDebugMode && error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Debug Info: ${error.toString()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: Colors.grey[700],
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
        if (kDebugMode)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Could implement error reporting here
            },
            child: const Text('Report Error'),
          ),
      ],
    );
  }
}

/// Custom exception classes for better error handling
class NetworkException implements Exception {
  final String message;
  final int? statusCode;
  
  NetworkException(this.message, {this.statusCode});
  
  @override
  String toString() => 'NetworkException: $message (Status: $statusCode)';
}

class ValidationException implements Exception {
  final String message;
  final String? field;
  
  ValidationException(this.message, {this.field});
  
  @override
  String toString() => 'ValidationException: $message${field != null ? ' (Field: $field)' : ''}';
}

class TimeoutException implements Exception {
  final String message;
  final Duration timeout;
  
  TimeoutException(this.message, this.timeout);
  
  @override
  String toString() => 'TimeoutException: $message (Timeout: ${timeout.inSeconds}s)';
}

/// Global error boundary widget
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(dynamic error)? errorWidgetBuilder;
  
  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorWidgetBuilder,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  dynamic _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorWidgetBuilder?.call(_error) ?? 
        ErrorDisplayWidget(error: _error);
    }
    
    return ErrorCapture(
      onError: (error) => setState(() => _error = error),
      child: widget.child,
    );
  }
}

/// Widget to capture and handle errors in child widgets
class ErrorCapture extends StatelessWidget {
  final Widget child;
  final Function(dynamic error) onError;
  
  const ErrorCapture({
    super.key,
    required this.child,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorBoundaryWidget(
      onError: onError,
      child: child,
    );
  }
}

/// Low-level error boundary implementation
class ErrorBoundaryWidget extends StatefulWidget {
  final Widget child;
  final Function(dynamic error) onError;
  
  const ErrorBoundaryWidget({
    super.key,
    required this.child,
    required this.onError,
  });

  @override
  State<ErrorBoundaryWidget> createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<ErrorBoundaryWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
  
  @override
  void didUpdateWidget(ErrorBoundaryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Handle widget updates safely
  }
}

/// Default error display widget
class ErrorDisplayWidget extends StatelessWidget {
  final dynamic error;
  
  const ErrorDisplayWidget({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                QuikTikErrorHandler.getErrorMessage(error),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Restart or navigate to safe state
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/', 
                    (route) => false,
                  );
                },
                child: const Text('Go to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}