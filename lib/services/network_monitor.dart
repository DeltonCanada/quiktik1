import 'dart:async';
import 'dart:developer' as developer;

/// Network connectivity monitoring service for web platform
class NetworkMonitor {
  static final NetworkMonitor _instance = NetworkMonitor._internal();
  factory NetworkMonitor() => _instance;
  NetworkMonitor._internal();

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();
  Timer? _pingTimer;
  bool _isOnline = true;
  DateTime? _lastConnectedTime;

  /// Stream of connectivity changes
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Current connectivity status
  bool get isOnline => _isOnline;

  /// Time since last successful connection
  Duration? get timeSinceLastConnection {
    if (_lastConnectedTime == null) return null;
    return DateTime.now().difference(_lastConnectedTime!);
  }

  /// Initialize network monitoring
  void initialize() {
    // Start with online status
    _updateConnectionStatus(true);

    // Start periodic connectivity check
    _startPeriodicCheck();

    developer.log('Network monitor initialized', name: 'NetworkMonitor');
  }

  /// Dispose resources
  void dispose() {
    _pingTimer?.cancel();
    _connectionController.close();
  }

  /// Manual connectivity check
  Future<bool> checkConnectivity() async {
    try {
      // Simple connectivity check - for web platform
      // In a real implementation, you might ping a known endpoint
      await Future.delayed(const Duration(milliseconds: 100));

      const isConnected = true; // Assume connected for web platform
      _updateConnectionStatus(isConnected);
      return isConnected;
    } catch (e) {
      developer.log('Connectivity check failed: $e', name: 'NetworkMonitor');
      _updateConnectionStatus(false);
      return false;
    }
  }

  void _updateConnectionStatus(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;

      if (isOnline) {
        _lastConnectedTime = DateTime.now();
        developer.log('Network connection available', name: 'NetworkMonitor');
      } else {
        developer.log('Network connection unavailable', name: 'NetworkMonitor');
      }

      _connectionController.add(isOnline);
    }
  }

  void _startPeriodicCheck() {
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      checkConnectivity();
    });
  }

  /// Get connection status
  bool get isConnected => _isOnline;

  /// Check internet connectivity (async version)
  Future<bool> hasInternetConnection() async {
    await checkConnectivity();
    return _isOnline;
  }

  /// Get network statistics
  Map<String, dynamic> getNetworkStats() {
    return {
      'is_online': _isOnline,
      'last_connected': _lastConnectedTime?.toIso8601String(),
      'time_since_last_connection_seconds': timeSinceLastConnection?.inSeconds,
      'monitoring_active': _pingTimer?.isActive ?? false,
    };
  }
}
