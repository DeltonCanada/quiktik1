import 'dart:developer' as developer;

/// Advanced caching service with TTL support and memory management
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  final Map<String, CacheItem> _cache = {};
  static const int _maxCacheSize = 100;
  static const Duration _defaultTtl = Duration(minutes: 30);

  /// Cache an item with optional TTL
  void put<T>(String key, T value, {Duration? ttl}) {
    // Clean expired items before adding new ones
    _cleanExpiredItems();

    // Manage cache size
    if (_cache.length >= _maxCacheSize) {
      _evictOldestItem();
    }

    final cacheItem = CacheItem<T>(
      value: value,
      timestamp: DateTime.now(),
      ttl: ttl ?? _defaultTtl,
    );

    _cache[key] = cacheItem;

    developer.log('Cached item: $key', name: 'CacheService');
  }

  /// Get a cached item
  T? get<T>(String key) {
    final item = _cache[key];
    if (item == null) return null;

    // Check if expired
    if (item.isExpired) {
      _cache.remove(key);
      developer.log('Cache expired: $key', name: 'CacheService');
      return null;
    }

    // Update access time for LRU
    item.lastAccessed = DateTime.now();

    developer.log('Cache hit: $key', name: 'CacheService');
    return item.value as T?;
  }

  /// Check if key exists and is not expired
  bool containsKey(String key) {
    final item = _cache[key];
    if (item == null || item.isExpired) {
      if (item?.isExpired == true) {
        _cache.remove(key);
      }
      return false;
    }
    return true;
  }

  /// Remove a specific key
  void remove(String key) {
    _cache.remove(key);
    developer.log('Removed from cache: $key', name: 'CacheService');
  }

  /// Clear all cache
  void clear() {
    _cache.clear();
    developer.log('Cache cleared', name: 'CacheService');
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    _cleanExpiredItems();

    return {
      'total_items': _cache.length,
      'max_size': _maxCacheSize,
      'usage_percentage': (_cache.length / _maxCacheSize * 100).round(),
      'items': _cache.keys.toList(),
    };
  }

  /// Clean expired items
  void _cleanExpiredItems() {
    final expiredKeys = <String>[];

    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _cache.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      developer.log('Cleaned ${expiredKeys.length} expired items',
          name: 'CacheService');
    }
  }

  /// Evict oldest item (LRU)
  void _evictOldestItem() {
    if (_cache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      final accessTime = entry.value.lastAccessed;
      if (oldestTime == null || accessTime.isBefore(oldestTime)) {
        oldestTime = accessTime;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
      developer.log('Evicted oldest item: $oldestKey', name: 'CacheService');
    }
  }

  /// Initialize the cache service
  Future<void> initialize() async {
    // Cache is ready to use immediately
    developer.log('Cache service initialized', name: 'CacheService');
  }

  /// Clear all cached data
  void clearAll() {
    _cache.clear();
    developer.log('All cache data cleared', name: 'CacheService');
  }
}

/// Cache item with metadata
class CacheItem<T> {
  final T value;
  final DateTime timestamp;
  final Duration ttl;
  DateTime lastAccessed;

  CacheItem({
    required this.value,
    required this.timestamp,
    required this.ttl,
  }) : lastAccessed = DateTime.now();

  bool get isExpired => DateTime.now().difference(timestamp) > ttl;
}
