import 'dart:async';
import 'package:flutter/foundation.dart';
import '../utils/error_handler.dart';

/// Safe state management base class that prevents invalid state transitions
/// and handles errors gracefully
abstract class SafeStateManager<T> extends ChangeNotifier {
  T? _state;
  String? _errorMessage;
  bool _isLoading = false;
  bool _disposed = false;

  /// Current state (read-only)
  T? get state => _state;
  
  /// Current error message
  String? get errorMessage => _errorMessage;
  
  /// Loading status
  bool get isLoading => _isLoading;
  
  /// Whether this state manager has been disposed
  bool get disposed => _disposed;

  /// Initialize with default state
  SafeStateManager([T? initialState]) {
    _state = initialState;
  }

  /// Safely update state with validation
  @protected
  bool updateState(T? newState, {String? context}) {
    if (_disposed) {
      if (kDebugMode) {
        print('Warning: Attempted to update disposed state manager: $context');
      }
      return false;
    }

    try {
      if (validateStateTransition(_state, newState)) {
        _state = newState;
        _errorMessage = null;
        safeNotifyListeners(context: context);
        return true;
      } else {
        _handleError('Invalid state transition', context: context);
        return false;
      }
    } catch (error, stackTrace) {
      QuikTikErrorHandler.logError(error, stackTrace, 'State Update Error: $context');
      _handleError(error.toString(), context: context);
      return false;
    }
  }

  /// Validate state transitions (override in subclasses)
  @protected
  bool validateStateTransition(T? oldState, T? newState) {
    return true; // Default: allow all transitions
  }

  /// Safely set loading state
  @protected
  void setLoading(bool loading, {String? context}) {
    if (_disposed) return;
    
    if (_isLoading != loading) {
      _isLoading = loading;
      if (loading) {
        _errorMessage = null; // Clear errors when starting loading
      }
      safeNotifyListeners(context: context);
    }
  }

  /// Safely set error state
  @protected
  void setError(String errorMessage, {String? context}) {
    if (_disposed) return;
    
    _errorMessage = errorMessage;
    _isLoading = false;
    safeNotifyListeners(context: context);
  }

  /// Handle errors consistently
  void _handleError(String errorMessage, {String? context}) {
    if (_disposed) return;
    
    _errorMessage = errorMessage;
    _isLoading = false;
    safeNotifyListeners(context: 'Error in $context');
  }

  /// Clear error state
  void clearError() {
    if (_disposed) return;
    
    if (_errorMessage != null) {
      _errorMessage = null;
      safeNotifyListeners(context: 'Clear Error');
    }
  }

  /// Safely notify listeners with error handling
  @protected
  void safeNotifyListeners({String? context}) {
    if (_disposed) return;
    
    try {
      notifyListeners();
    } catch (error, stackTrace) {
      QuikTikErrorHandler.logError(error, stackTrace, 'Notify Listeners Error: $context');
    }
  }

  /// Execute operation safely with loading and error handling
  @protected
  Future<bool> safeOperation(
    Future<void> Function() operation, {
    String? context,
    bool setLoadingState = true,
  }) async {
    if (_disposed) return false;
    
    try {
      if (setLoadingState) setLoading(true, context: context);
      
      await operation();
      
      if (setLoadingState) setLoading(false, context: context);
      return true;
    } catch (error, stackTrace) {
      QuikTikErrorHandler.logError(error, stackTrace, 'Safe Operation Error: $context');
      setError(QuikTikErrorHandler.getErrorMessage(error), context: context);
      return false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Safe state manager for list-based data
class SafeListStateManager<T> extends SafeStateManager<List<T>> {
  SafeListStateManager([List<T>? initialList]) : super(initialList ?? <T>[]);

  /// Get list safely
  List<T> get items => state ?? <T>[];

  /// Add item safely
  bool addItem(T item, {String? context}) {
    if (disposed) return false;
    
    final currentList = List<T>.from(items);
    currentList.add(item);
    return updateState(currentList, context: context ?? 'Add Item');
  }

  /// Remove item safely
  bool removeItem(T item, {String? context}) {
    if (disposed) return false;
    
    final currentList = List<T>.from(items);
    final removed = currentList.remove(item);
    if (removed) {
      return updateState(currentList, context: context ?? 'Remove Item');
    }
    return false;
  }

  /// Update item at index safely
  bool updateItemAt(int index, T item, {String? context}) {
    if (disposed || index < 0 || index >= items.length) return false;
    
    final currentList = List<T>.from(items);
    currentList[index] = item;
    return updateState(currentList, context: context ?? 'Update Item');
  }

  /// Clear all items safely
  bool clearItems({String? context}) {
    if (disposed) return false;
    
    return updateState(<T>[], context: context ?? 'Clear Items');
  }

  /// Replace entire list safely
  bool replaceItems(List<T> newItems, {String? context}) {
    if (disposed) return false;
    
    return updateState(List<T>.from(newItems), context: context ?? 'Replace Items');
  }

  /// Get item safely by index
  T? getItemAt(int index) {
    if (disposed || index < 0 || index >= items.length) return null;
    return items[index];
  }

  /// Find item safely
  T? findItem(bool Function(T) predicate) {
    if (disposed) return null;
    
    try {
      return items.firstWhere(predicate);
    } catch (e) {
      return null;
    }
  }

  /// Filter items safely
  List<T> filterItems(bool Function(T) predicate) {
    if (disposed) return <T>[];
    
    try {
      return items.where(predicate).toList();
    } catch (e) {
      return <T>[];
    }
  }
}

/// Safe state manager for map-based data
class SafeMapStateManager<K, V> extends SafeStateManager<Map<K, V>> {
  SafeMapStateManager([Map<K, V>? initialMap]) : super(initialMap ?? <K, V>{});

  /// Get map safely
  Map<K, V> get data => state ?? <K, V>{};

  /// Set value safely
  bool setValue(K key, V value, {String? context}) {
    if (disposed) return false;
    
    final currentMap = Map<K, V>.from(data);
    currentMap[key] = value;
    return updateState(currentMap, context: context ?? 'Set Value');
  }

  /// Remove value safely
  bool removeValue(K key, {String? context}) {
    if (disposed) return false;
    
    final currentMap = Map<K, V>.from(data);
    final removed = currentMap.remove(key);
    if (removed != null) {
      return updateState(currentMap, context: context ?? 'Remove Value');
    }
    return false;
  }

  /// Get value safely
  V? getValue(K key, {V? defaultValue}) {
    if (disposed) return defaultValue;
    return data[key] ?? defaultValue;
  }

  /// Check if key exists safely
  bool containsKey(K key) {
    if (disposed) return false;
    return data.containsKey(key);
  }

  /// Clear all data safely
  bool clearData({String? context}) {
    if (disposed) return false;
    
    return updateState(<K, V>{}, context: context ?? 'Clear Data');
  }

  /// Update multiple values safely
  bool updateData(Map<K, V> updates, {String? context}) {
    if (disposed) return false;
    
    final currentMap = Map<K, V>.from(data);
    currentMap.addAll(updates);
    return updateState(currentMap, context: context ?? 'Update Data');
  }
}

/// Mixin for safe async operations
mixin SafeAsyncMixin {
  /// Execute async operation with timeout and error handling
  Future<T?> safeAsyncCall<T>(
    Future<T> Function() operation, {
    Duration timeout = const Duration(seconds: 30),
    T? fallbackValue,
    String? context,
  }) async {
    try {
      return await operation().timeout(timeout);
    } catch (error, stackTrace) {
      QuikTikErrorHandler.logError(error, stackTrace, 'Safe Async Call: $context');
      return fallbackValue;
    }
  }

  /// Execute multiple async operations safely
  Future<List<T?>> safeAsyncBatch<T>(
    List<Future<T> Function()> operations, {
    Duration timeout = const Duration(seconds: 30),
    String? context,
  }) async {
    final futures = operations.map((op) => safeAsyncCall(op, timeout: timeout, context: context));
    return await Future.wait(futures);
  }
}

/// Safe stream subscription manager
class SafeStreamManager {
  final List<StreamSubscription> _subscriptions = [];
  bool _disposed = false;

  /// Add subscription safely
  void addSubscription<T>(
    Stream<T> stream,
    void Function(T) onData, {
    Function? onError,
    void Function()? onDone,
    String? context,
  }) {
    if (_disposed) return;

    final subscription = stream.listen(
      onData,
      onError: (error, stackTrace) {
        QuikTikErrorHandler.logError(error, stackTrace, 'Stream Error: $context');
        onError?.call(error);
      },
      onDone: onDone,
    );

    _subscriptions.add(subscription);
  }

  /// Cancel all subscriptions
  void cancelAll() {
    for (final subscription in _subscriptions) {
      try {
        subscription.cancel();
      } catch (e) {
        // Ignore cancellation errors
      }
    }
    _subscriptions.clear();
  }

  /// Dispose stream manager
  void dispose() {
    _disposed = true;
    cancelAll();
  }
}

/// Safe future cache to prevent duplicate requests
class SafeFutureCache<T> {
  final Map<String, Future<T>> _cache = {};
  final Duration _cacheDuration;

  SafeFutureCache({Duration cacheDuration = const Duration(minutes: 5)})
      : _cacheDuration = cacheDuration;

  /// Get or create cached future
  Future<T> getOrCreate(String key, Future<T> Function() creator) {
    if (_cache.containsKey(key)) {
      return _cache[key]!;
    }

    final future = creator();
    _cache[key] = future;

    // Remove from cache after duration
    Timer(_cacheDuration, () {
      _cache.remove(key);
    });

    return future;
  }

  /// Clear cache
  void clear() {
    _cache.clear();
  }
}

