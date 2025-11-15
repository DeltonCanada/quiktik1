import 'package:flutter/foundation.dart';
import 'error_handler.dart';

/// Safe state manager that prevents invalid state transitions and provides error boundaries
abstract class SafeStateManager<T> extends ChangeNotifier {
  T? _state;
  AppError? _error;
  bool _isLoading = false;
  bool _isDisposed = false;

  /// Current state (nullable for safety)
  T? get state => _state;

  /// Current error if any
  AppError? get error => _error;

  /// Whether the manager is in loading state
  bool get isLoading => _isLoading;

  /// Whether the manager has been disposed
  bool get isDisposed => _isDisposed;

  /// Whether the state is valid and not null
  bool get hasValidState => _state != null && _error == null;

  /// Safely update state with error handling
  void safeSetState(T newState) {
    if (_isDisposed) {
      GlobalErrorHandler().reportError(AppError(
        message: 'Attempted to set state on disposed manager',
        stackTrace: StackTrace.current.toString(),
        type: ErrorType.business,
        severity: ErrorSeverity.medium,
        timestamp: DateTime.now(),
        context: runtimeType.toString(),
      ));
      return;
    }

    try {
      if (validateStateTransition(_state, newState)) {
        _state = newState;
        _error = null;
        _notifySafely();
      } else {
        _setError(AppError(
          message: 'Invalid state transition',
          stackTrace: StackTrace.current.toString(),
          type: ErrorType.business,
          severity: ErrorSeverity.medium,
          timestamp: DateTime.now(),
          context: runtimeType.toString(),
          additionalData: {
            'currentState': _state?.toString(),
            'newState': newState?.toString(),
          },
        ));
      }
    } catch (e, stackTrace) {
      _setError(AppError(
        message: 'Error during state update: $e',
        stackTrace: stackTrace.toString(),
        type: ErrorType.business,
        severity: ErrorSeverity.high,
        timestamp: DateTime.now(),
        context: runtimeType.toString(),
      ));
    }
  }

  /// Set loading state safely
  void safeSetLoading(bool loading) {
    if (_isDisposed) return;

    _isLoading = loading;
    _notifySafely();
  }

  /// Set error state
  void _setError(AppError error) {
    if (_isDisposed) return;

    _error = error;
    _isLoading = false;
    GlobalErrorHandler().reportError(error);
    _notifySafely();
  }

  /// Clear error state
  void clearError() {
    if (_isDisposed) return;

    _error = null;
    _notifySafely();
  }

  /// Execute an operation safely with error handling
  Future<void> safeExecute(Future<void> Function() operation) async {
    if (_isDisposed) return;

    try {
      safeSetLoading(true);
      await operation();
    } catch (e, stackTrace) {
      _setError(AppError(
        message: 'Operation failed: $e',
        stackTrace: stackTrace.toString(),
        type: ErrorType.business,
        severity: ErrorSeverity.high,
        timestamp: DateTime.now(),
        context: runtimeType.toString(),
      ));
    } finally {
      if (!_isDisposed) {
        safeSetLoading(false);
      }
    }
  }

  /// Safely notify listeners
  void _notifySafely() {
    if (_isDisposed) return;

    try {
      notifyListeners();
    } catch (e, stackTrace) {
      GlobalErrorHandler().reportError(AppError(
        message: 'Error notifying listeners: $e',
        stackTrace: stackTrace.toString(),
        type: ErrorType.flutter,
        severity: ErrorSeverity.medium,
        timestamp: DateTime.now(),
        context: runtimeType.toString(),
      ));
    }
  }

  /// Validate state transition (override in subclasses)
  bool validateStateTransition(T? currentState, T newState) {
    return true; // Default: allow all transitions
  }

  /// Reset to initial state
  void reset() {
    if (_isDisposed) return;

    _state = null;
    _error = null;
    _isLoading = false;
    _notifySafely();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

/// Safe async operation result
class SafeResult<T> {
  final T? data;
  final AppError? error;
  final bool isSuccess;

  SafeResult.success(this.data)
      : error = null,
        isSuccess = true;
  SafeResult.error(this.error)
      : data = null,
        isSuccess = false;

  /// Execute a callback if the result is successful
  SafeResult<R> then<R>(R Function(T data) callback) {
    if (isSuccess && data != null) {
      try {
        final nonNullData = data as T;
        return SafeResult.success(callback(nonNullData));
      } catch (e, stackTrace) {
        return SafeResult.error(AppError(
          message: 'Error in then callback: $e',
          stackTrace: stackTrace.toString(),
          type: ErrorType.business,
          severity: ErrorSeverity.medium,
          timestamp: DateTime.now(),
          context: 'SafeResult.then',
        ));
      }
    }
    return SafeResult.error(error);
  }
}

/// Null safety utilities
class SafeUtils {
  /// Safely get a value or return default
  static T safeGet<T>(T? value, T defaultValue) {
    return value ?? defaultValue;
  }

  /// Safely execute a function on a nullable value
  static R? safeCall<T, R>(T? value, R Function(T) callback) {
    if (value == null) return null;
    try {
      return callback(value);
    } catch (e) {
      GlobalErrorHandler().reportError(AppError(
        message: 'Error in safe call: $e',
        stackTrace: StackTrace.current.toString(),
        type: ErrorType.business,
        severity: ErrorSeverity.low,
        timestamp: DateTime.now(),
        context: 'SafeUtils.safeCall',
      ));
      return null;
    }
  }

  /// Safely parse integer
  static int? safeParseInt(String? value) {
    if (value == null || value.isEmpty) return null;
    return int.tryParse(value);
  }

  /// Safely parse double
  static double? safeParseDouble(String? value) {
    if (value == null || value.isEmpty) return null;
    return double.tryParse(value);
  }

  /// Safely get list item at index
  static T? safeGetListItem<T>(List<T>? list, int index) {
    if (list == null || index < 0 || index >= list.length) return null;
    return list[index];
  }

  /// Safely get map value
  static V? safeGetMapValue<K, V>(Map<K, V>? map, K key) {
    if (map == null) return null;
    return map[key];
  }
}

/// Safe list operations
extension SafeList<T> on List<T>? {
  /// Safely get item at index
  T? safeGet(int index) {
    if (this == null || index < 0 || index >= this!.length) return null;
    return this![index];
  }

  /// Safely get first item
  T? get safeFirst {
    if (this == null || this!.isEmpty) return null;
    return this!.first;
  }

  /// Safely get last item
  T? get safeLast {
    if (this == null || this!.isEmpty) return null;
    return this!.last;
  }

  /// Safe length
  int get safeLength => this?.length ?? 0;

  /// Safe isEmpty check
  bool get safeIsEmpty => this?.isEmpty ?? true;

  /// Safe isNotEmpty check
  bool get safeIsNotEmpty => this?.isNotEmpty ?? false;
}

/// Safe string operations
extension SafeString on String? {
  /// Safe trim
  String get safeTrim => this?.trim() ?? '';

  /// Safe toLowerCase
  String get safeToLowerCase => this?.toLowerCase() ?? '';

  /// Safe toUpperCase
  String get safeToUpperCase => this?.toUpperCase() ?? '';

  /// Safe isEmpty check
  bool get safeIsEmpty => this?.isEmpty ?? true;

  /// Safe isNotEmpty check
  bool get safeIsNotEmpty => this?.isNotEmpty ?? false;

  /// Safe length
  int get safeLength => this?.length ?? 0;

  /// Safe substring
  String safeSubstring(int start, [int? end]) {
    if (this == null) return '';
    final str = this!;
    final safeStart = start.clamp(0, str.length);
    final safeEnd = end?.clamp(safeStart, str.length) ?? str.length;
    return str.substring(safeStart, safeEnd);
  }
}
