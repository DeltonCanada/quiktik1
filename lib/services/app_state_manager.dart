import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Enhanced app state management with persistence and recovery
class AppStateManager extends ChangeNotifier {
  static final AppStateManager _instance = AppStateManager._internal();
  factory AppStateManager() => _instance;
  AppStateManager._internal();

  AppState _currentState = AppState.initializing;
  String? _lastError;
  DateTime? _lastStateChange;
  final List<StateTransition> _stateHistory = [];
  final StreamController<AppState> _stateController = StreamController<AppState>.broadcast();

  /// Current app state
  AppState get currentState => _currentState;
  
  /// Last error message
  String? get lastError => _lastError;
  
  /// Time of last state change
  DateTime? get lastStateChange => _lastStateChange;
  
  /// Stream of state changes
  Stream<AppState> get stateStream => _stateController.stream;

  /// Initialize the state manager
  void initialize() {
    _transitionTo(AppState.initializing);
    developer.log('AppStateManager initialized', name: 'AppStateManager');
  }

  /// Transition to a new state
  void transitionTo(AppState newState, {String? reason}) {
    _transitionTo(newState, reason: reason);
  }

  /// Set app as ready
  void setReady() {
    _transitionTo(AppState.ready, reason: 'App initialization completed');
  }

  /// Set app as loading with optional message
  void setLoading({String? message}) {
    _transitionTo(AppState.loading, reason: message ?? 'Loading operation started');
  }

  /// Set app in error state
  void setError(String error, {String? details}) {
    _lastError = details != null ? '$error: $details' : error;
    _transitionTo(AppState.error, reason: _lastError);
  }

  /// Clear error and return to ready state
  void clearError() {
    _lastError = null;
    _transitionTo(AppState.ready, reason: 'Error cleared');
  }

  /// Set app as offline
  void setOffline() {
    _transitionTo(AppState.offline, reason: 'Network connection lost');
  }

  /// Set app as online
  void setOnline() {
    _transitionTo(AppState.ready, reason: 'Network connection restored');
  }

  void _transitionTo(AppState newState, {String? reason}) {
    if (_currentState == newState) return;

    final previousState = _currentState;
    _currentState = newState;
    _lastStateChange = DateTime.now();

    // Record transition
    final transition = StateTransition(
      from: previousState,
      to: newState,
      timestamp: _lastStateChange!,
      reason: reason,
    );
    _stateHistory.add(transition);

    // Limit history size
    if (_stateHistory.length > 50) {
      _stateHistory.removeAt(0);
    }

    developer.log(
      'State transition: ${previousState.name} → ${newState.name}${reason != null ? " ($reason)" : ""}',
      name: 'AppStateManager',
    );

    // Notify listeners
    notifyListeners();
    _stateController.add(newState);
  }

  /// Get state transition history
  List<StateTransition> getStateHistory() => List.unmodifiable(_stateHistory);

  /// Get state statistics
  Map<String, dynamic> getStateStats() {
    final stateCount = <String, int>{};
    for (final transition in _stateHistory) {
      final stateName = transition.to.name;
      stateCount[stateName] = (stateCount[stateName] ?? 0) + 1;
    }

    return {
      'current_state': _currentState.name,
      'last_error': _lastError,
      'last_state_change': _lastStateChange?.toIso8601String(),
      'state_counts': stateCount,
      'total_transitions': _stateHistory.length,
    };
  }

  /// Check if app is in a recoverable error state
  bool get canRecover => _currentState == AppState.error && _lastError != null;

  /// Attempt to recover from error state
  void attemptRecovery() {
    if (canRecover) {
      developer.log('Attempting recovery from error state', name: 'AppStateManager');
      clearError();
    }
  }

  /// Add an error (use setError instead for state management)
  void addError(String errorMessage) {
    setError(errorMessage);
  }

  @override
  void dispose() {
    _stateController.close();
    super.dispose();
  }
}

/// Possible app states
enum AppState {
  initializing,
  loading,
  ready,
  error,
  offline,
}

/// State transition record
class StateTransition {
  final AppState from;
  final AppState to;
  final DateTime timestamp;
  final String? reason;

  const StateTransition({
    required this.from,
    required this.to,
    required this.timestamp,
    this.reason,
  });

  @override
  String toString() => '${from.name} → ${to.name} at ${timestamp.toIso8601String()}${reason != null ? " ($reason)" : ""}';
}