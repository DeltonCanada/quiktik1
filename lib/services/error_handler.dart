import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'performance_monitor.dart';
import 'app_state_manager.dart';

/// Global error handler that captures and manages all application errors
class GlobalErrorHandler {
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();
  factory GlobalErrorHandler() => _instance;
  GlobalErrorHandler._internal();

  final List<AppError> _errors = [];
  final StreamController<AppError> _errorStreamController = StreamController<AppError>.broadcast();

  Stream<AppError> get errorStream => _errorStreamController.stream;
  List<AppError> get errors => List.unmodifiable(_errors);

  /// Initialize the global error handler
  static void initialize() {
    FlutterError.onError = (FlutterErrorDetails details) {
      _instance._handleFlutterError(details);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _instance._handlePlatformError(error, stack);
      return true;
    };
  }

  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    final error = AppError(
      message: details.exception.toString(),
      stackTrace: details.stack?.toString() ?? '',
      type: ErrorType.flutter,
      severity: ErrorSeverity.high,
      timestamp: DateTime.now(),
      context: details.library ?? 'Unknown',
    );

    _addError(error);

    // In debug mode, show the error
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }

  /// Handle platform errors
  void _handlePlatformError(Object error, StackTrace stackTrace) {
    final appError = AppError(
      message: error.toString(),
      stackTrace: stackTrace.toString(),
      type: ErrorType.platform,
      severity: ErrorSeverity.critical,
      timestamp: DateTime.now(),
      context: 'Platform',
    );

    _addError(appError);
  }

  /// Add a custom error
  void reportError(AppError error) {
    _addError(error);
  }

  /// Add error to the list and notify listeners
  void _addError(AppError error) {
    _errors.add(error);
    _errorStreamController.add(error);

    // Log the error with performance context
    _logError(error);

    // Track error in performance monitoring
    PerformanceMonitor().recordError(error.message, error.severity.name);

    // Update app state with error
    AppStateManager().addError(error.message);

    // In production, you might want to send to crash reporting service
    if (kReleaseMode) {
      _sendToCrashReporting(error);
    }
  }

  /// Log error using dart:developer logging
  void _logError(AppError error) {
    developer.log(
      '🚨 ERROR: ${error.message}',
      name: 'GlobalErrorHandler',
      level: _getSeverityLevel(error.severity),
      error: error.message,
      stackTrace: error.stackTrace.isNotEmpty ? StackTrace.fromString(error.stackTrace) : null,
    );
  }

  /// Get log level based on error severity
  int _getSeverityLevel(ErrorSeverity severity) {
    switch (severity) {
      case ErrorSeverity.critical:
        return 1000; // Severe
      case ErrorSeverity.high:
        return 900;  // Warning
      case ErrorSeverity.medium:
        return 800;  // Info
      case ErrorSeverity.low:
        return 700;  // Config
    }
  }

  /// Send error to crash reporting service (placeholder)
  void _sendToCrashReporting(AppError error) {
    // TODO: Implement crash reporting service integration
    // Examples: Firebase Crashlytics, Sentry, Bugsnag
  }

  /// Clear all errors
  void clearErrors() {
    _errors.clear();
  }

  /// Dispose resources
  void dispose() {
    _errorStreamController.close();
  }
}

/// Represents an application error with additional context
class AppError {
  final String message;
  final String stackTrace;
  final ErrorType type;
  final ErrorSeverity severity;
  final DateTime timestamp;
  final String context;
  final Map<String, dynamic>? additionalData;

  AppError({
    required this.message,
    required this.stackTrace,
    required this.type,
    required this.severity,
    required this.timestamp,
    required this.context,
    this.additionalData,
  });

  @override
  String toString() {
    return 'AppError(message: $message, type: $type, severity: $severity, context: $context)';
  }
}

/// Types of errors that can occur
enum ErrorType {
  flutter,
  platform,
  network,
  validation,
  business,
  security,
}

/// Error severity levels
enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

/// Error boundary widget that catches and displays errors gracefully
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, AppError error)? errorBuilder;
  final void Function(AppError error)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  AppError? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(context, _error!) ?? 
             DefaultErrorWidget(error: _error!);
    }

    return ErrorCatcher(
      onError: (error) {
        setState(() {
          _error = error;
        });
        widget.onError?.call(error);
      },
      child: widget.child,
    );
  }
}

/// Widget that catches errors in its child tree
class ErrorCatcher extends StatefulWidget {
  final Widget child;
  final void Function(AppError error) onError;

  const ErrorCatcher({
    super.key,
    required this.child,
    required this.onError,
  });

  @override
  State<ErrorCatcher> createState() => _ErrorCatcherState();
}

class _ErrorCatcherState extends State<ErrorCatcher> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    // Set up error capturing for this widget's context
    FlutterError.onError = (FlutterErrorDetails details) {
      final error = AppError(
        message: details.exception.toString(),
        stackTrace: details.stack?.toString() ?? '',
        type: ErrorType.flutter,
        severity: ErrorSeverity.high,
        timestamp: DateTime.now(),
        context: 'ErrorCatcher',
      );
      widget.onError(error);
    };
  }
}

/// Default error widget with professional styling
class DefaultErrorWidget extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;

  const DefaultErrorWidget({
    super.key,
    required this.error,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
            Icon(
              _getErrorIcon(),
              size: 64,
              color: _getErrorColor(),
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _getErrorColor(),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _getErrorMessage(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
            if (kDebugMode) ...[
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Error Details'),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error.message,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
          ),
        ),
      ),
    );
  }

  IconData _getErrorIcon() {
    switch (error.severity) {
      case ErrorSeverity.critical:
        return Icons.error;
      case ErrorSeverity.high:
        return Icons.warning;
      case ErrorSeverity.medium:
        return Icons.info;
      case ErrorSeverity.low:
        return Icons.help_outline;
    }
  }

  Color _getErrorColor() {
    switch (error.severity) {
      case ErrorSeverity.critical:
        return Colors.red[700]!;
      case ErrorSeverity.high:
        return Colors.orange[700]!;
      case ErrorSeverity.medium:
        return Colors.blue[700]!;
      case ErrorSeverity.low:
        return Colors.grey[600]!;
    }
  }

  String _getErrorMessage() {
    switch (error.type) {
      case ErrorType.network:
        return 'Please check your internet connection and try again.';
      case ErrorType.validation:
        return 'Please check your input and try again.';
      case ErrorType.business:
        return 'Unable to complete the operation. Please try again.';
      case ErrorType.security:
        return 'Security error occurred. Please contact support.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}