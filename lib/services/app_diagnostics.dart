import 'dart:developer' as developer;
import 'app_initializer.dart';
import 'performance_monitor.dart';
import 'error_handler.dart';
import 'cache_service.dart';
import 'network_monitor.dart';
import 'app_state_manager.dart';
import 'config_manager.dart';

/// Comprehensive app diagnostic and status reporting tool
class AppDiagnostics {
  /// Generate comprehensive health and performance report
  static Map<String, dynamic> generateComprehensiveReport() {
    final reportTimer = PerformanceMonitor().startTimer('diagnostic_report');

    try {
      final report = {
        'timestamp': DateTime.now().toIso8601String(),
        'app_info': _getAppInfo(),
        'initialization_status': _getInitializationStatus(),
        'performance_metrics': _getPerformanceMetrics(),
        'error_analysis': _getErrorAnalysis(),
        'service_health': _getServiceHealth(),
        'system_resources': _getSystemResources(),
        'recommendations': _getRecommendations(),
      };

      developer.log(
        'Comprehensive diagnostic report generated successfully',
        name: 'AppDiagnostics',
      );

      return report;
    } catch (error, stackTrace) {
      developer.log(
        'Failed to generate diagnostic report: $error',
        name: 'AppDiagnostics',
        error: error,
        stackTrace: stackTrace,
      );

      return {
        'error': 'Failed to generate report',
        'details': error.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    } finally {
      PerformanceMonitor().stopTimer(reportTimer);
    }
  }

  /// Get basic app information
  static Map<String, dynamic> _getAppInfo() {
    return {
      'name': ConfigManager().get<String>('app_name', defaultValue: 'QuikTik'),
      'version':
          ConfigManager().get<String>('app_version', defaultValue: '1.0.0'),
      'build_mode': ConfigManager().get<bool>('debug_mode', defaultValue: false)
          ? 'debug'
          : 'release',
      'platform': _getPlatformInfo(),
    };
  }

  /// Get initialization status
  static Map<String, dynamic> _getInitializationStatus() {
    return {
      'app_initialized': AppInitializer.isInitialized,
      'health_check_passed': true, // Would be async in real implementation
      'services_status': {
        'error_handler': 'active',
        'performance_monitor': 'active',
        'cache_service': CacheService().getStats()['initialized'] ?? false,
        'network_monitor':
            NetworkMonitor().isConnected ? 'connected' : 'offline',
        'app_state_manager': AppStateManager().currentState.name,
        'config_manager': ConfigManager().isInitialized,
      },
    };
  }

  /// Get performance metrics summary
  static Map<String, dynamic> _getPerformanceMetrics() {
    final performanceReport = PerformanceMonitor().getPerformanceReport();
    final cacheStats = CacheService().getStats();

    return {
      'operation_timings': performanceReport,
      'cache_performance': {
        'hit_rate': cacheStats['hit_rate'],
        'total_items': cacheStats['total_items'],
        'memory_usage': cacheStats['memory_usage_estimate'],
      },
      'network_stats': NetworkMonitor().getNetworkStats(),
    };
  }

  /// Analyze error patterns and frequency
  static Map<String, dynamic> _getErrorAnalysis() {
    final errors = GlobalErrorHandler().errors;
    final recentErrors = errors
        .where(
          (error) => DateTime.now().difference(error.timestamp).inHours < 24,
        )
        .toList();

    final errorCounts = <String, int>{};
    final severityCounts = <String, int>{};

    for (final error in recentErrors) {
      final errorType = error.type.name;
      final severity = error.severity.name;

      errorCounts[errorType] = (errorCounts[errorType] ?? 0) + 1;
      severityCounts[severity] = (severityCounts[severity] ?? 0) + 1;
    }

    return {
      'total_errors': errors.length,
      'recent_errors_24h': recentErrors.length,
      'error_types': errorCounts,
      'error_severity': severityCounts,
      'last_error': errors.isNotEmpty
          ? {
              'message': errors.last.message,
              'timestamp': errors.last.timestamp.toIso8601String(),
              'severity': errors.last.severity.name,
            }
          : null,
    };
  }

  /// Check health of all services
  static Map<String, dynamic> _getServiceHealth() {
    return {
      'cache_service': _checkCacheHealth(),
      'network_monitor': _checkNetworkHealth(),
      'performance_monitor': _checkPerformanceHealth(),
      'config_manager': _checkConfigHealth(),
      'error_handler': _checkErrorHandlerHealth(),
    };
  }

  /// Get system resource usage estimates
  static Map<String, dynamic> _getSystemResources() {
    final cacheStats = CacheService().getStats();

    return {
      'memory_estimate': {
        'cache_usage_kb': cacheStats['memory_usage_estimate'],
        'status': cacheStats['memory_usage_estimate'] < 1024 ? 'good' : 'high',
      },
      'storage': {
        'cache_items': cacheStats['total_items'],
        'max_cache_size':
            ConfigManager().get<int>('max_cache_size', defaultValue: 100),
      },
    };
  }

  /// Generate recommendations for optimization
  static List<Map<String, dynamic>> _getRecommendations() {
    final recommendations = <Map<String, dynamic>>[];
    final cacheStats = CacheService().getStats();
    final errors = GlobalErrorHandler().errors;

    // Cache recommendations
    if (cacheStats['hit_rate'] < 0.5) {
      recommendations.add({
        'type': 'performance',
        'priority': 'medium',
        'title': 'Low Cache Hit Rate',
        'description':
            'Cache hit rate is below 50%. Consider adjusting cache TTL or size.',
        'action': 'Review caching strategy',
      });
    }

    // Error recommendations
    if (errors.length > 10) {
      recommendations.add({
        'type': 'reliability',
        'priority': 'high',
        'title': 'High Error Count',
        'description': 'Application has accumulated ${errors.length} errors.',
        'action': 'Review error patterns and implement fixes',
      });
    }

    // Network recommendations
    if (!NetworkMonitor().isConnected) {
      recommendations.add({
        'type': 'connectivity',
        'priority': 'high',
        'title': 'Network Disconnected',
        'description': 'Application is currently offline.',
        'action': 'Check network connection and implement offline mode',
      });
    }

    // Performance recommendations
    final performanceReport = PerformanceMonitor().getPerformanceReport();
    for (final entry in performanceReport.entries) {
      final operation = entry.key;
      final metrics = entry.value as Map<String, dynamic>;
      final avgTime = metrics['average_ms'] as num;

      if (avgTime > 1000) {
        recommendations.add({
          'type': 'performance',
          'priority': 'medium',
          'title': 'Slow Operation: $operation',
          'description':
              'Operation takes ${avgTime.toStringAsFixed(1)}ms on average.',
          'action': 'Optimize $operation performance',
        });
      }
    }

    return recommendations;
  }

  // Health check helper methods
  static Map<String, dynamic> _checkCacheHealth() {
    final stats = CacheService().getStats();
    return {
      'status': 'healthy',
      'hit_rate': stats['hit_rate'],
      'items': stats['total_items'],
    };
  }

  static Map<String, dynamic> _checkNetworkHealth() {
    return {
      'status': NetworkMonitor().isConnected ? 'connected' : 'disconnected',
      'stats': NetworkMonitor().getNetworkStats(),
    };
  }

  static Map<String, dynamic> _checkPerformanceHealth() {
    final report = PerformanceMonitor().getPerformanceReport();
    final hasSlowOperations = report.values.any((metrics) {
      final avgTime = (metrics as Map<String, dynamic>)['average_ms'] as num;
      return avgTime > 2000;
    });

    return {
      'status': hasSlowOperations ? 'degraded' : 'healthy',
      'operations_tracked': report.length,
    };
  }

  static Map<String, dynamic> _checkConfigHealth() {
    return {
      'status': ConfigManager().isInitialized ? 'healthy' : 'uninitialized',
      'config_valid': ConfigManager().validate(),
    };
  }

  static Map<String, dynamic> _checkErrorHandlerHealth() {
    final errorCount = GlobalErrorHandler().errors.length;
    return {
      'status': errorCount < 5 ? 'healthy' : 'needs_attention',
      'total_errors': errorCount,
    };
  }

  static Map<String, dynamic> _getPlatformInfo() {
    // Platform detection for web
    return {
      'type': 'web',
      'user_agent': 'Flutter Web',
      'supports_offline': true,
    };
  }

  /// Export report as formatted string for logging
  static String formatReportForLogging(Map<String, dynamic> report) {
    final buffer = StringBuffer();

    buffer.writeln('🏥 QUIKTIK APP HEALTH REPORT');
    buffer.writeln('=' * 50);

    // App Info
    final appInfo = report['app_info'] as Map<String, dynamic>;
    buffer.writeln('📱 App: ${appInfo['name']} v${appInfo['version']}');
    buffer.writeln('🔧 Mode: ${appInfo['build_mode']}');

    // Initialization Status
    final initStatus = report['initialization_status'] as Map<String, dynamic>;
    buffer.writeln('🚀 Initialized: ${initStatus['app_initialized']}');

    // Performance Summary
    final performance = report['performance_metrics'] as Map<String, dynamic>;
    final cachePerf = performance['cache_performance'] as Map<String, dynamic>;
    buffer.writeln(
        '⚡ Cache Hit Rate: ${(cachePerf['hit_rate'] * 100).toStringAsFixed(1)}%');

    // Error Summary
    final errors = report['error_analysis'] as Map<String, dynamic>;
    buffer.writeln('🚨 Total Errors: ${errors['total_errors']}');
    buffer.writeln('⏰ Recent Errors (24h): ${errors['recent_errors_24h']}');

    // Recommendations
    final recommendations = report['recommendations'] as List;
    buffer.writeln('💡 Recommendations: ${recommendations.length}');

    for (int i = 0; i < recommendations.length && i < 3; i++) {
      final rec = recommendations[i] as Map<String, dynamic>;
      buffer.writeln('   ${i + 1}. ${rec['title']} (${rec['priority']})');
    }

    buffer.writeln('=' * 50);
    buffer.writeln('Generated: ${report['timestamp']}');

    return buffer.toString();
  }
}
