import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'error_handler.dart';
import 'performance_monitor.dart';
import 'cache_service.dart';
import 'network_monitor.dart';
import 'app_state_manager.dart';
import 'config_manager.dart';

/// Centralized app initialization service that sets up all core services
class AppInitializer {
  static bool _isInitialized = false;
  
  /// Initialize all app services in the correct order
  static Future<void> initialize() async {
    if (_isInitialized) {
      developer.log('App already initialized', name: 'AppInitializer');
      return;
    }

    final performanceTimer = PerformanceMonitor().startTimer('app_initialization');

    try {
      developer.log('Starting app initialization...', name: 'AppInitializer');
      
      // 1. Initialize error handling first
      GlobalErrorHandler.initialize();
      developer.log('✓ Global error handler initialized', name: 'AppInitializer');

      // 2. Initialize app state management
      AppStateManager().setLoading(message: 'Initializing app...');
      developer.log('✓ App state manager initialized', name: 'AppInitializer');

      // 3. Initialize configuration management
      ConfigManager().initialize();
      developer.log('✓ Configuration manager initialized', name: 'AppInitializer');

      // 4. Initialize cache service
      await CacheService().initialize();
      developer.log('✓ Cache service initialized', name: 'AppInitializer');

      // 5. Initialize network monitoring
      NetworkMonitor().initialize();
      developer.log('✓ Network monitor initialized', name: 'AppInitializer');

      // 6. Wait for initial network check
      await _waitForNetworkCheck();

      // 7. Set app as ready
      AppStateManager().setReady();
      developer.log('✓ App initialization completed successfully', name: 'AppInitializer');

      _isInitialized = true;

    } catch (error, stackTrace) {
      // Handle initialization errors
      developer.log(
        'App initialization failed: $error',
        name: 'AppInitializer',
        error: error,
        stackTrace: stackTrace,
      );

      GlobalErrorHandler().reportError(AppError(
        message: 'App initialization failed: $error',
        stackTrace: stackTrace.toString(),
        type: ErrorType.platform,
        severity: ErrorSeverity.critical,
        timestamp: DateTime.now(),
        context: 'AppInitializer',
      ));

      AppStateManager().setError('Initialization failed', details: error.toString());
      rethrow;
    } finally {
      PerformanceMonitor().stopTimer(performanceTimer);
    }
  }

  /// Wait for initial network connectivity check
  static Future<void> _waitForNetworkCheck() async {
    final networkTimer = PerformanceMonitor().startTimer('network_check');
    
    try {
      // Wait up to 3 seconds for network check
      await NetworkMonitor().hasInternetConnection().timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          developer.log('Network check timed out', name: 'AppInitializer');
          return false;
        },
      );
    } catch (error) {
      developer.log('Network check failed: $error', name: 'AppInitializer');
      // Continue initialization even if network check fails
    } finally {
      PerformanceMonitor().stopTimer(networkTimer);
    }
  }

  /// Get initialization status
  static bool get isInitialized => _isInitialized;

  /// Get app health status
  static Map<String, dynamic> getHealthStatus() {
    return {
      'initialized': _isInitialized,
      'app_state': AppStateManager().currentState.name,
      'network_connected': NetworkMonitor().isConnected,
      'cache_stats': CacheService().getStats(),
      'performance_metrics': PerformanceMonitor().getPerformanceReport(),
      'config_loaded': ConfigManager().isInitialized,
      'error_count': GlobalErrorHandler().errors.length,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Perform health check and return status
  static Future<bool> performHealthCheck() async {
    final healthTimer = PerformanceMonitor().startTimer('health_check');
    
    try {
      final status = getHealthStatus();
      
      // Check critical components
      final isHealthy = status['initialized'] == true &&
                       status['app_state'] != 'error' &&
                       status['config_loaded'] == true;

      developer.log(
        'Health check completed: ${isHealthy ? 'HEALTHY' : 'UNHEALTHY'}',
        name: 'AppInitializer',
      );

      return isHealthy;
    } catch (error) {
      developer.log('Health check failed: $error', name: 'AppInitializer');
      return false;
    } finally {
      PerformanceMonitor().stopTimer(healthTimer);
    }
  }

  /// Reset initialization state (for testing)
  static void reset() {
    if (kDebugMode) {
      _isInitialized = false;
      developer.log('App initialization state reset', name: 'AppInitializer');
    }
  }
}

