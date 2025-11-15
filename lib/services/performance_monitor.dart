import 'dart:developer' as developer;

/// Performance monitoring service for tracking app performance
class PerformanceMonitor {
  static final PerformanceMonitor _instance = PerformanceMonitor._internal();
  factory PerformanceMonitor() => _instance;
  PerformanceMonitor._internal();

  final Map<String, Stopwatch> _activeTimers = {};
  final Map<String, List<int>> _performanceMetrics = {};

  /// Start measuring performance for a specific operation
  String startTimer(String operationName) {
    final timerId = '${operationName}_${DateTime.now().millisecondsSinceEpoch}';
    final stopwatch = Stopwatch()..start();
    _activeTimers[timerId] = stopwatch;
    return timerId;
  }

  /// Stop measuring and record performance
  void stopTimer(String timerId) {
    final stopwatch = _activeTimers.remove(timerId);
    final operationName = timerId.split('_').first;
    if (stopwatch != null) {
      stopwatch.stop();
      final duration = stopwatch.elapsedMilliseconds;

      _performanceMetrics.putIfAbsent(operationName, () => []);
      _performanceMetrics[operationName]!.add(duration);

      developer.log(
        'Performance: $operationName completed in ${duration}ms',
        name: 'PerformanceMonitor',
      );

      // Alert if operation takes too long
      if (duration > 1000) {
        developer.log(
          'Performance Warning: $operationName took ${duration}ms (>1s)',
          name: 'PerformanceMonitor',
        );
      }
    }
  }

  /// Get average performance for an operation
  double getAveragePerformance(String operationName) {
    final metrics = _performanceMetrics[operationName];
    if (metrics == null || metrics.isEmpty) return 0;

    final sum = metrics.reduce((a, b) => a + b);
    return sum / metrics.length;
  }

  /// Get performance report
  Map<String, dynamic> getPerformanceReport() {
    final report = <String, dynamic>{};

    for (final entry in _performanceMetrics.entries) {
      final operationName = entry.key;
      final metrics = entry.value;

      if (metrics.isNotEmpty) {
        report[operationName] = {
          'average_ms': getAveragePerformance(operationName),
          'min_ms': metrics.reduce((a, b) => a < b ? a : b),
          'max_ms': metrics.reduce((a, b) => a > b ? a : b),
          'samples': metrics.length,
        };
      }
    }

    return report;
  }

  /// Record an error occurrence
  void recordError(String errorMessage, String severity) {
    developer.log(
      'Error recorded: $errorMessage',
      name: 'PerformanceMonitor',
      level: severity.toLowerCase() == 'critical' ? 1000 : 800,
      error: errorMessage,
    );

    // Record error as a performance event
    final errorTimer = startTimer('error_handling');
    // Simulate immediate completion for error logging
    if (_activeTimers.containsKey(errorTimer)) {
      stopTimer(errorTimer);
    }
  }

  /// Clear all performance data
  void clearMetrics() {
    _activeTimers.clear();
    _performanceMetrics.clear();
  }
}
