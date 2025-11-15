import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'error_handler.dart';
import 'safe_state_manager.dart';

/// Comprehensive async error handling and network safety
class AsyncSafetyService {
  static final AsyncSafetyService _instance = AsyncSafetyService._internal();
  factory AsyncSafetyService() => _instance;
  AsyncSafetyService._internal();

  /// Default timeout duration
  static const Duration defaultTimeout = Duration(seconds: 30);

  /// Execute an async operation safely with timeout and error handling
  static Future<SafeResult<T>> executeSafely<T>(
    Future<T> Function() operation, {
    Duration? timeout,
    String? operationName,
    int retryCount = 0,
    Duration retryDelay = const Duration(seconds: 1),
  }) async {
    final effectiveTimeout = timeout ?? defaultTimeout;
    final name = operationName ?? 'Unknown Operation';

    for (int attempt = 0; attempt <= retryCount; attempt++) {
      try {
        final result = await operation().timeout(effectiveTimeout);
        return SafeResult.success(result);
      } on TimeoutException catch (e, stackTrace) {
        final error = AppError(
          message:
              'Operation "$name" timed out after ${effectiveTimeout.inSeconds} seconds',
          stackTrace: stackTrace.toString(),
          type: ErrorType.network,
          severity: ErrorSeverity.high,
          timestamp: DateTime.now(),
          context: 'AsyncSafetyService.executeSafely',
          additionalData: {
            'operationName': name,
            'timeout': effectiveTimeout.inSeconds,
            'attempt': attempt + 1,
            'maxAttempts': retryCount + 1,
          },
        );

        if (attempt == retryCount) {
          return SafeResult.error(error);
        }

        GlobalErrorHandler().reportError(error);
        await Future.delayed(retryDelay);
      } on SocketException catch (e, stackTrace) {
        final error = AppError(
          message: 'Network error in "$name": ${e.message}',
          stackTrace: stackTrace.toString(),
          type: ErrorType.network,
          severity: ErrorSeverity.high,
          timestamp: DateTime.now(),
          context: 'AsyncSafetyService.executeSafely',
          additionalData: {
            'operationName': name,
            'attempt': attempt + 1,
            'maxAttempts': retryCount + 1,
          },
        );

        if (attempt == retryCount) {
          return SafeResult.error(error);
        }

        GlobalErrorHandler().reportError(error);
        await Future.delayed(retryDelay);
      } catch (e, stackTrace) {
        final error = AppError(
          message: 'Unexpected error in "$name": $e',
          stackTrace: stackTrace.toString(),
          type: ErrorType.business,
          severity: ErrorSeverity.high,
          timestamp: DateTime.now(),
          context: 'AsyncSafetyService.executeSafely',
          additionalData: {
            'operationName': name,
            'attempt': attempt + 1,
            'maxAttempts': retryCount + 1,
          },
        );

        if (attempt == retryCount) {
          return SafeResult.error(error);
        }

        GlobalErrorHandler().reportError(error);
        await Future.delayed(retryDelay);
      }
    }

    // This should never be reached, but just in case
    return SafeResult.error(AppError(
      message: 'Operation "$name" failed after all retry attempts',
      stackTrace: StackTrace.current.toString(),
      type: ErrorType.business,
      severity: ErrorSeverity.critical,
      timestamp: DateTime.now(),
      context: 'AsyncSafetyService.executeSafely',
    ));
  }

  /// Execute multiple async operations safely
  static Future<List<SafeResult<T>>> executeMultipleSafely<T>(
    List<Future<T> Function()> operations, {
    Duration? timeout,
    bool failFast = false,
  }) async {
    if (failFast) {
      // Stop on first error
      final results = <SafeResult<T>>[];
      for (int i = 0; i < operations.length; i++) {
        final result = await executeSafely(
          operations[i],
          timeout: timeout,
          operationName: 'Operation ${i + 1}',
        );
        results.add(result);
        if (!result.isSuccess) break;
      }
      return results;
    } else {
      // Execute all operations regardless of failures
      final futures = operations.asMap().entries.map((entry) => executeSafely(
            entry.value,
            timeout: timeout,
            operationName: 'Operation ${entry.key + 1}',
          ));
      return await Future.wait(futures);
    }
  }

  /// Create a safe stream subscription
  static StreamSubscription<T> createSafeSubscription<T>(
    Stream<T> stream,
    void Function(T data) onData, {
    void Function(AppError error)? onError,
    void Function()? onDone,
    bool cancelOnError = false,
  }) {
    return stream.listen(
      onData,
      onError: (error, stackTrace) {
        final appError = AppError(
          message: 'Stream error: $error',
          stackTrace: stackTrace.toString(),
          type: ErrorType.business,
          severity: ErrorSeverity.medium,
          timestamp: DateTime.now(),
          context: 'AsyncSafetyService.createSafeSubscription',
        );

        GlobalErrorHandler().reportError(appError);
        onError?.call(appError);
      },
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  /// Debounce function calls to prevent rapid-fire executions
  static Timer? _debounceTimer;
  static void debounce(
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 500),
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(delay, callback);
  }

  /// Throttle function calls to limit execution frequency
  static DateTime? _lastThrottleTime;
  static void throttle(
    VoidCallback callback, {
    Duration interval = const Duration(milliseconds: 1000),
  }) {
    final now = DateTime.now();
    if (_lastThrottleTime == null ||
        now.difference(_lastThrottleTime!) >= interval) {
      _lastThrottleTime = now;
      callback();
    }
  }
}

/// Circuit breaker pattern for failing operations
class CircuitBreaker {
  final String name;
  final int failureThreshold;
  final Duration timeout;
  final Duration resetTimeout;

  int _failureCount = 0;
  DateTime? _lastFailureTime;
  CircuitBreakerState _state = CircuitBreakerState.closed;

  CircuitBreaker({
    required this.name,
    this.failureThreshold = 5,
    this.timeout = const Duration(seconds: 30),
    this.resetTimeout = const Duration(minutes: 1),
  });

  CircuitBreakerState get state => _state;
  int get failureCount => _failureCount;

  /// Execute operation through circuit breaker
  Future<SafeResult<T>> execute<T>(Future<T> Function() operation) async {
    if (_state == CircuitBreakerState.open) {
      if (_shouldAttemptReset()) {
        _state = CircuitBreakerState.halfOpen;
      } else {
        return SafeResult.error(AppError(
          message: 'Circuit breaker "$name" is open',
          stackTrace: StackTrace.current.toString(),
          type: ErrorType.business,
          severity: ErrorSeverity.medium,
          timestamp: DateTime.now(),
          context: 'CircuitBreaker.execute',
          additionalData: {
            'circuitBreakerName': name,
            'failureCount': _failureCount,
            'state': _state.toString(),
          },
        ));
      }
    }

    try {
      final result = await AsyncSafetyService.executeSafely(
        operation,
        timeout: timeout,
        operationName: name,
      );

      if (result.isSuccess) {
        _onSuccess();
        return result;
      } else {
        _onFailure();
        return result;
      }
    } catch (e, stackTrace) {
      _onFailure();
      return SafeResult.error(AppError(
        message: 'Circuit breaker operation failed: $e',
        stackTrace: stackTrace.toString(),
        type: ErrorType.business,
        severity: ErrorSeverity.high,
        timestamp: DateTime.now(),
        context: 'CircuitBreaker.execute',
      ));
    }
  }

  bool _shouldAttemptReset() {
    return _lastFailureTime != null &&
        DateTime.now().difference(_lastFailureTime!) >= resetTimeout;
  }

  void _onSuccess() {
    _failureCount = 0;
    _state = CircuitBreakerState.closed;
  }

  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (_failureCount >= failureThreshold) {
      _state = CircuitBreakerState.open;
      GlobalErrorHandler().reportError(AppError(
        message: 'Circuit breaker "$name" opened due to failures',
        stackTrace: StackTrace.current.toString(),
        type: ErrorType.business,
        severity: ErrorSeverity.high,
        timestamp: DateTime.now(),
        context: 'CircuitBreaker._onFailure',
        additionalData: {
          'circuitBreakerName': name,
          'failureCount': _failureCount,
          'threshold': failureThreshold,
        },
      ));
    }
  }

  void reset() {
    _failureCount = 0;
    _lastFailureTime = null;
    _state = CircuitBreakerState.closed;
  }
}

enum CircuitBreakerState {
  closed,
  open,
  halfOpen,
}

/// Safe HTTP client wrapper
class SafeHttpClient {
  static final SafeHttpClient _instance = SafeHttpClient._internal();
  factory SafeHttpClient() => _instance;
  SafeHttpClient._internal();

  final HttpClient _client = HttpClient();
  final Map<String, CircuitBreaker> _circuitBreakers = {};

  /// Get or create circuit breaker for host
  CircuitBreaker _getCircuitBreaker(String host) {
    return _circuitBreakers.putIfAbsent(
      host,
      () => CircuitBreaker(name: 'HTTP-$host'),
    );
  }

  /// Safe HTTP GET request
  Future<SafeResult<String>> safeGet(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse(url);
      final circuitBreaker = _getCircuitBreaker(uri.host);

      return await circuitBreaker.execute(() async {
        final request = await _client.getUrl(uri);

        // Add headers
        headers?.forEach((key, value) {
          request.headers.add(key, value);
        });

        final response = await request.close();
        final responseBody = await response.transform(utf8.decoder).join();

        if (response.statusCode >= 200 && response.statusCode < 300) {
          return responseBody;
        } else {
          throw HttpException(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}',
            uri: uri,
          );
        }
      });
    } catch (e, stackTrace) {
      return SafeResult.error(AppError(
        message: 'HTTP GET failed for $url: $e',
        stackTrace: stackTrace.toString(),
        type: ErrorType.network,
        severity: ErrorSeverity.high,
        timestamp: DateTime.now(),
        context: 'SafeHttpClient.safeGet',
        additionalData: {'url': url},
      ));
    }
  }

  void dispose() {
    _client.close();
  }
}
