import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cache entry with data and metadata
class CacheEntry<T> {
  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
  });

  final T data;
  final DateTime timestamp;
  final Duration ttl;

  bool get isStale => DateTime.now().difference(timestamp) > ttl;
  bool get isExpired => DateTime.now().difference(timestamp) > ttl * 2;
}

/// Cache manager implementing stale-while-revalidate pattern
class CacheManager {
  final Map<String, CacheEntry<dynamic>> _cache = {};
  final Map<String, Completer<dynamic>> _pendingRequests = {};

  /// Get cached data with stale-while-revalidate
  Future<T?> get<T>({
    required String key,
    required Future<T> Function() fetcher,
    Duration ttl = const Duration(minutes: 5),
    bool forceRefresh = false,
  }) async {
    // Safe type checking to prevent runtime cast errors
    final dynamic cachedEntry = _cache[key];
    
    // If no cached entry exists, fetch new data
    if (cachedEntry == null) {
      return _fetchAndCache(key, fetcher, ttl);
    }
    
    // Runtime type check to handle type variance safely
    // This prevents crashes when nullable and non-nullable types are mixed
    if (cachedEntry is! CacheEntry<T>) {
      // Type mismatch detected - invalidate and refetch
      // This handles cases like CacheEntry<List<Device>?> vs CacheEntry<List<Device>>
      _cache.remove(key);
      return _fetchAndCache(key, fetcher, ttl);
    }
    
    // Now safe to use after type check - cachedEntry is CacheEntry<T>
    final entry = cachedEntry;

    // If force refresh or expired, fetch immediately
    if (forceRefresh || entry.isExpired) {
      return _fetchAndCache(key, fetcher, ttl);
    }

    // If data is stale but not expired, return stale data and refresh in background
    if (entry.isStale) {
      // Return stale data immediately
      final staleData = entry.data;
      
      // Refresh in background without waiting
      unawaited(_fetchAndCache(key, fetcher, ttl).catchError((Object e) {
        // Silent fail for background refresh
        return null as T;
      }));
      
      return staleData;
    }

    // Data is fresh, return it
    return entry.data;
  }

  /// Fetch and cache data with deduplication
  Future<T> _fetchAndCache<T>(
    String key,
    Future<T> Function() fetcher,
    Duration ttl,
  ) async {
    // Check if there's already a pending request for this key
    if (_pendingRequests.containsKey(key)) {
      return await _pendingRequests[key]!.future as T;
    }

    // Create a new completer for this request
    final completer = Completer<T>();
    _pendingRequests[key] = completer;

    try {
      final data = await fetcher();
      
      // Cache the result
      _cache[key] = CacheEntry<T>(
        data: data,
        timestamp: DateTime.now(),
        ttl: ttl,
      );
      
      completer.complete(data);
      return data;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _pendingRequests.remove(key);
    }
  }

  /// Invalidate a specific cache entry
  void invalidate(String key) {
    _cache.remove(key);
  }

  /// Invalidate all cache entries matching a pattern
  void invalidatePattern(String pattern) {
    final regex = RegExp(pattern);
    _cache.removeWhere((key, _) => regex.hasMatch(key));
  }

  /// Clear all cache
  void clearAll() {
    _cache.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    var fresh = 0;
    var stale = 0;
    var expired = 0;

    for (final entry in _cache.values) {
      if (entry.isExpired) {
        expired++;
      } else if (entry.isStale) {
        stale++;
      } else {
        fresh++;
      }
    }

    return {
      'total': _cache.length,
      'fresh': fresh,
      'stale': stale,
      'expired': expired,
      'pending': _pendingRequests.length,
    };
  }
}

/// Provider for cache manager
final cacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});