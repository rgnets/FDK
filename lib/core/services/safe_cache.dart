import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/core/services/logger_service.dart';

/// Type-safe, exception-safe caching for Flutter applications.
///
/// This implementation provides request deduplication to prevent duplicate
/// concurrent operations. Based on ATT-FE-Tool's SafeCache pattern.
///
/// Features:
/// - Type safety with runtime type checking
/// - Handles synchronous exceptions properly
/// - Input validation
/// - Proper cleanup even on errors
///
/// Safe for production use in single-threaded Flutter apps.
/// For multi-isolate apps, wrap with synchronized package.
///
/// Example:
/// ```dart
/// final data = await SafeCache.dedupe<String>('getData', () async {
///   return await api.fetchData();
/// });
/// ```
class SafeCache {
  // Store entries with type information
  static final Map<String, _TypedEntry> _operations = {};

  /// Safely deduplicates concurrent operations with type checking.
  ///
  /// Features:
  /// - Type-safe: Detects and prevents type mismatches
  /// - Exception-safe: Handles both sync and async exceptions
  /// - Input validation: Rejects invalid operation IDs
  /// - Automatic cleanup: Removes completed operations
  ///
  /// Example:
  /// ```dart
  /// final data = await SafeCache.dedupe<String>('getData', () async {
  ///   return await api.fetchData();
  /// });
  /// ```
  ///
  /// Throws:
  /// - [ArgumentError] if operationId is empty
  /// - [StateError] if same operationId used with different type
  static Future<T> dedupe<T>(
    String operationId,
    Future<T> Function() operation,
  ) {
    // Input validation
    if (operationId.isEmpty) {
      throw ArgumentError('operationId cannot be empty');
    }

    // Check for existing operation with type safety
    final existing = _operations[operationId];
    if (existing != null) {
      // Verify type compatibility
      if (existing.type != T) {
        throw StateError(
          'Operation "$operationId" already exists with type ${existing.type}, '
          'cannot dedupe with different type $T. '
          'Use different operation IDs for different return types.',
        );
      }
      // Return existing future - safe because we verified the type
      try {
        LoggerService.debug(
          'Reusing existing operation: "$operationId" (type=$T)',
          tag: 'SafeCache',
        );
      } catch (_) {
        // Fallback to debugPrint in case logger not ready
        debugPrint('SafeCache: reusing existing operation "$operationId" (type=$T)');
      }
      return existing.future as Future<T>;
    }

    // Create new operation with exception handling
    Future<T> future;
    try {
      // Call the operation - might throw synchronously
      try {
        LoggerService.debug(
          'Starting operation: "$operationId" (type=$T)',
          tag: 'SafeCache',
        );
      } catch (_) {
        debugPrint('SafeCache: starting operation "$operationId" (type=$T)');
      }
      future = operation();
    } catch (syncError, stackTrace) {
      // Handle synchronous exceptions by creating an error future
      // This ensures the error is cached and deduplicated
      future = Future<T>.error(syncError, stackTrace);
    }

    // Store the operation with its type
    _operations[operationId] = _TypedEntry(future, T);

    // Set up cleanup that runs after completion (success or failure)
    future.whenComplete(() {
      // Remove from cache to allow retry
      // Using try-catch in case map was cleared elsewhere
      try {
        _operations.remove(operationId);
        try {
          LoggerService.debug(
            'Completed operation: "$operationId"',
            tag: 'SafeCache',
          );
        } catch (_) {
          debugPrint('SafeCache: completed operation "$operationId"');
        }
      } catch (_) {
        // Ignore cleanup errors
      }
    });

    return future;
  }

  /// Check if an operation is currently running.
  static bool isRunning(String operationId) {
    return _operations.containsKey(operationId);
  }

  /// Get count of active operations.
  static int get activeCount => _operations.length;

  /// Get list of active operation IDs.
  static List<String> get activeOperations => _operations.keys.toList();

  /// Clear all operations (mainly for testing).
  ///
  /// Note: This doesn't cancel running operations, just removes
  /// them from the cache. They will continue running but won't
  /// be deduplicated.
  static void clearAll() {
    _operations.clear();
  }

  /// Get debug information about cached operations.
  static Map<String, String> get debugInfo {
    return _operations
        .map((key, value) => MapEntry(key, 'Type: ${value.type}'));
  }
}

/// Internal class to store type information with futures.
class _TypedEntry {
  final Future<dynamic> future;
  final Type type;

  _TypedEntry(this.future, this.type);
}
