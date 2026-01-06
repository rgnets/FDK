import 'dart:async';
import 'dart:collection';
import 'package:rgnets_fdk/core/config/logger_config.dart';

/// Service for monitoring and tracking performance metrics
class PerformanceMonitorService {
  PerformanceMonitorService._();
  
  static final instance = PerformanceMonitorService._();
  
  // Performance metrics storage
  final _metrics = HashMap<String, List<PerformanceMetric>>();
  final _activeOperations = HashMap<String, Stopwatch>();
  final _logger = LoggerConfig.getLogger();
  
  // Stream for real-time metrics
  final _metricsController = StreamController<PerformanceMetric>.broadcast();
  Stream<PerformanceMetric> get metricsStream => _metricsController.stream;
  
  // Configuration
  static const int _maxMetricsPerOperation = 100;
  
  /// Start tracking an operation
  void startOperation(String operationName, {Map<String, dynamic>? metadata}) {
    final stopwatch = Stopwatch()..start();
    _activeOperations[operationName] = stopwatch;
    
    _logger.d('Performance: Started tracking "$operationName"');
  }
  
  /// End tracking an operation and record metrics
  Duration? endOperation(String operationName, {
    bool success = true,
    Map<String, dynamic>? metadata,
  }) {
    final stopwatch = _activeOperations.remove(operationName);
    if (stopwatch == null) {
      _logger.w('Performance: No active operation found for "$operationName"');
      return null;
    }
    
    stopwatch.stop();
    final duration = stopwatch.elapsed;
    
    final metric = PerformanceMetric(
      operationName: operationName,
      duration: duration,
      timestamp: DateTime.now(),
      success: success,
      metadata: metadata,
    );
    
    // Store metric
    _metrics.putIfAbsent(operationName, () => []).add(metric);
    
    // Limit stored metrics per operation
    final operationMetrics = _metrics[operationName]!;
    if (operationMetrics.length > _maxMetricsPerOperation) {
      operationMetrics.removeAt(0);
    }
    
    // Emit metric
    _metricsController.add(metric);
    
    // Log performance
    final milliseconds = duration.inMilliseconds;
    final status = success ? 'SUCCESS' : 'FAILED';
    _logger.d('Performance: $operationName completed [$status] in ${milliseconds}ms');
    
    // Warn if operation took too long
    if (milliseconds > 1000) {
      _logger.w('Performance WARNING: $operationName took ${milliseconds}ms (>1s)');
    }
    
    return duration;
  }
  
  /// Track a future operation
  Future<T> trackFuture<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    startOperation(operationName, metadata: metadata);
    
    try {
      final result = await operation();
      endOperation(operationName, success: true, metadata: metadata);
      return result;
    } catch (e) {
      endOperation(operationName, success: false, metadata: {
        ...?metadata,
        'error': e.toString(),
      });
      rethrow;
    }
  }
  
  /// Track multiple parallel operations
  Future<List<T>> trackParallel<T>(
    String groupName,
    List<Future<T> Function()> operations, {
    Map<String, dynamic>? metadata,
  }) async {
    startOperation(groupName, metadata: metadata);
    
    try {
      final stopwatch = Stopwatch()..start();
      final futures = operations.map((op) => op()).toList();
      final results = await Future.wait(futures);
      stopwatch.stop();
      
      endOperation(groupName, success: true, metadata: {
        ...?metadata,
        'parallelCount': operations.length,
        'parallelDuration': stopwatch.elapsedMilliseconds,
      });
      
      return results;
    } catch (e) {
      endOperation(groupName, success: false, metadata: {
        ...?metadata,
        'error': e.toString(),
      });
      rethrow;
    }
  }
  
  /// Get statistics for an operation
  PerformanceStats? getStats(String operationName) {
    final metrics = _metrics[operationName];
    if (metrics == null || metrics.isEmpty) {
      return null;
    }
    
    final durations = metrics.map((m) => m.duration.inMilliseconds).toList()
      ..sort();
    
    final sum = durations.reduce((a, b) => a + b);
    final average = sum / durations.length;
    final median = durations[durations.length ~/ 2];
    final min = durations.first;
    final max = durations.last;
    
    // Calculate percentiles
    final p95Index = (durations.length * 0.95).floor();
    final p99Index = (durations.length * 0.99).floor();
    final p95 = durations[p95Index < durations.length ? p95Index : durations.length - 1];
    final p99 = durations[p99Index < durations.length ? p99Index : durations.length - 1];
    
    final successCount = metrics.where((m) => m.success).length;
    final successRate = successCount / metrics.length;
    
    return PerformanceStats(
      operationName: operationName,
      sampleCount: metrics.length,
      averageMs: average,
      medianMs: median,
      minMs: min,
      maxMs: max,
      p95Ms: p95,
      p99Ms: p99,
      successRate: successRate,
    );
  }
  
  /// Get all statistics
  Map<String, PerformanceStats> getAllStats() {
    final stats = <String, PerformanceStats>{};
    
    for (final operationName in _metrics.keys) {
      final stat = getStats(operationName);
      if (stat != null) {
        stats[operationName] = stat;
      }
    }
    
    return stats;
  }
  
  /// Generate performance report
  String generateReport() {
    final buffer = StringBuffer()
      ..writeln('=== Performance Report ===')
      ..writeln('Generated: ${DateTime.now()}')
      ..writeln();
    
    final stats = getAllStats();
    if (stats.isEmpty) {
      buffer.writeln('No performance data available');
      return buffer.toString();
    }
    
    // Sort by average time (slowest first)
    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.averageMs.compareTo(a.value.averageMs));
    
    for (final entry in sortedEntries) {
      final stat = entry.value;
      buffer
        ..writeln('Operation: ${stat.operationName}')
        ..writeln('  Samples: ${stat.sampleCount}')
        ..writeln('  Average: ${stat.averageMs.toStringAsFixed(1)}ms')
        ..writeln('  Median: ${stat.medianMs}ms')
        ..writeln('  Min: ${stat.minMs}ms')
        ..writeln('  Max: ${stat.maxMs}ms')
        ..writeln('  P95: ${stat.p95Ms}ms')
        ..writeln('  P99: ${stat.p99Ms}ms')
        ..writeln('  Success Rate: ${(stat.successRate * 100).toStringAsFixed(1)}%');
      
      // Performance assessment
      if (stat.averageMs > 1000) {
        buffer.writeln('  ⚠️ SLOW: Average > 1s');
      } else if (stat.averageMs > 500) {
        buffer.writeln('  ⚠️ MODERATE: Average > 500ms');
      } else {
        buffer.writeln('  ✅ FAST: Average < 500ms');
      }
      
      buffer.writeln();
    }
    
    return buffer.toString();
  }
  
  /// Clear all metrics
  void clearMetrics() {
    _metrics.clear();
    _activeOperations.clear();
    _logger.d('Performance: All metrics cleared');
  }
  
  /// Clear metrics for specific operation
  void clearOperationMetrics(String operationName) {
    _metrics.remove(operationName);
    _activeOperations.remove(operationName);
    _logger.d('Performance: Metrics cleared for "$operationName"');
  }
  
  /// Dispose resources
  void dispose() {
    _metricsController.close();
  }
}

/// Performance metric data
class PerformanceMetric {
  const PerformanceMetric({
    required this.operationName,
    required this.duration,
    required this.timestamp,
    required this.success,
    this.metadata,
  });
  
  final String operationName;
  final Duration duration;
  final DateTime timestamp;
  final bool success;
  final Map<String, dynamic>? metadata;
}

/// Performance statistics
class PerformanceStats {
  const PerformanceStats({
    required this.operationName,
    required this.sampleCount,
    required this.averageMs,
    required this.medianMs,
    required this.minMs,
    required this.maxMs,
    required this.p95Ms,
    required this.p99Ms,
    required this.successRate,
  });
  
  final String operationName;
  final int sampleCount;
  final double averageMs;
  final int medianMs;
  final int minMs;
  final int maxMs;
  final int p95Ms;
  final int p99Ms;
  final double successRate;
}