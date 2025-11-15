import 'dart:developer' as developer;

/// Centralized configuration management for the app
class ConfigManager {
  static final ConfigManager _instance = ConfigManager._internal();
  factory ConfigManager() => _instance;
  ConfigManager._internal();

  final Map<String, dynamic> _config = {};
  bool _isInitialized = false;

  /// Initialize with default configuration
  void initialize() {
    if (_isInitialized) return;

    _setDefaultConfig();
    _isInitialized = true;

    developer.log('Configuration manager initialized', name: 'ConfigManager');
  }

  void _setDefaultConfig() {
    _config.addAll({
      // App settings
      'app_name': 'QuikTik',
      'app_version': '1.0.0',
      'debug_mode': false,

      // Performance settings
      'enable_performance_monitoring': true,
      'max_cache_size': 100,
      'cache_ttl_minutes': 30,
      'network_check_interval_seconds': 30,

      // Queue settings
      'max_queue_size': 1000,
      'queue_update_interval_seconds': 10,
      'establishment_heartbeat_interval_seconds': 60,

      // UI settings
      'animation_duration_ms': 300,
      'enable_haptic_feedback': true,
      'theme_mode': 'system',

      // Security settings
      'enable_input_sanitization': true,
      'max_input_length': 1000,
      'session_timeout_minutes': 60,

      // Logging settings
      'log_level': 'info',
      'max_log_entries': 500,
      'enable_crash_reporting': true,

      // Feature flags
      'enable_establishment_sync': true,
      'enable_offline_mode': true,
      'enable_advanced_analytics': false,
      'enable_beta_features': false,
    });
  }

  /// Get configuration value
  T get<T>(String key, {T? defaultValue}) {
    if (!_isInitialized) {
      throw StateError(
          'ConfigManager not initialized. Call initialize() first.');
    }

    final value = _config[key];
    if (value == null) {
      if (defaultValue != null) {
        developer.log(
            'Config key not found, using default: $key = $defaultValue',
            name: 'ConfigManager');
        return defaultValue;
      }
      throw ArgumentError('Configuration key not found: $key');
    }

    if (value is T) {
      return value;
    } else {
      throw TypeError();
    }
  }

  /// Set configuration value
  void set<T>(String key, T value) {
    _config[key] = value;
    developer.log('Configuration updated: $key = $value',
        name: 'ConfigManager');
  }

  /// Check if configuration key exists
  bool contains(String key) => _config.containsKey(key);

  /// Get all configuration as read-only map
  Map<String, dynamic> getAll() => Map.unmodifiable(_config);

  /// Reset to default configuration
  void reset() {
    _config.clear();
    _setDefaultConfig();
    developer.log('Configuration reset to defaults', name: 'ConfigManager');
  }

  /// Update multiple configuration values
  void updateAll(Map<String, dynamic> updates) {
    _config.addAll(updates);
    developer.log('Configuration bulk update: ${updates.keys.join(", ")}',
        name: 'ConfigManager');
  }

  /// Enable/disable debug mode
  void setDebugMode(bool enabled) {
    set('debug_mode', enabled);
    developer.log('Debug mode ${enabled ? "enabled" : "disabled"}',
        name: 'ConfigManager');
  }

  /// Enable/disable feature flag
  void setFeatureFlag(String feature, bool enabled) {
    final key = 'enable_$feature';
    set(key, enabled);
    developer.log('Feature flag $feature ${enabled ? "enabled" : "disabled"}',
        name: 'ConfigManager');
  }

  /// Get feature flag status
  bool isFeatureEnabled(String feature) {
    final key = 'enable_$feature';
    return get<bool>(key, defaultValue: false);
  }

  /// Get performance configuration
  Map<String, dynamic> getPerformanceConfig() {
    return {
      'enable_performance_monitoring':
          get<bool>('enable_performance_monitoring'),
      'max_cache_size': get<int>('max_cache_size'),
      'cache_ttl_minutes': get<int>('cache_ttl_minutes'),
      'network_check_interval_seconds':
          get<int>('network_check_interval_seconds'),
    };
  }

  /// Get security configuration
  Map<String, dynamic> getSecurityConfig() {
    return {
      'enable_input_sanitization': get<bool>('enable_input_sanitization'),
      'max_input_length': get<int>('max_input_length'),
      'session_timeout_minutes': get<int>('session_timeout_minutes'),
    };
  }

  /// Check if configuration is initialized
  bool get isInitialized => _config.isNotEmpty;

  /// Validate configuration
  bool validate() {
    try {
      // Check required keys exist and have valid types
      final requiredConfigs = {
        'app_name': String,
        'app_version': String,
        'debug_mode': bool,
        'max_cache_size': int,
        'cache_ttl_minutes': int,
      };

      for (final entry in requiredConfigs.entries) {
        final key = entry.key;
        final expectedType = entry.value;

        if (!contains(key)) {
          developer.log('Missing required config: $key', name: 'ConfigManager');
          return false;
        }

        final value = _config[key];
        if (value.runtimeType != expectedType) {
          developer.log(
              'Invalid type for config $key: expected $expectedType, got ${value.runtimeType}',
              name: 'ConfigManager');
          return false;
        }
      }

      developer.log('Configuration validation passed', name: 'ConfigManager');
      return true;
    } catch (e) {
      developer.log('Configuration validation failed: $e',
          name: 'ConfigManager');
      return false;
    }
  }
}
