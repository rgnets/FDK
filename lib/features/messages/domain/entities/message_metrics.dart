import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_metrics.freezed.dart';

/// Metrics for the message monitoring dashboard
@freezed
class MessageMetrics with _$MessageMetrics {
  const factory MessageMetrics({
    /// Total messages shown
    @Default(0) int totalShown,

    /// Total messages deduplicated
    @Default(0) int totalDeduplicated,

    /// Total messages dropped
    @Default(0) int totalDropped,

    /// Total errors
    @Default(0) int totalErrors,

    /// Current queue size
    @Default(0) int queueSize,

    /// Maximum queue size
    @Default(20) int maxQueueSize,

    /// Messages by type count
    @Default({}) Map<String, int> byType,

    /// Messages by category count
    @Default({}) Map<String, int> byCategory,

    /// Messages by source count
    @Default({}) Map<String, int> bySource,

    /// Session start time
    DateTime? sessionStart,

    /// Last message time
    DateTime? lastMessageTime,

    /// Health score (0-100)
    @Default(100) int healthScore,

    /// Issues identified
    @Default([]) List<String> issues,

    /// Recommendations
    @Default([]) List<String> recommendations,
  }) = _MessageMetrics;

  const MessageMetrics._();

  /// Queue utilization percentage
  double get queueUtilization =>
      maxQueueSize > 0 ? (queueSize / maxQueueSize) * 100 : 0;

  /// Deduplication rate
  double get deduplicationRate => totalShown > 0
      ? (totalDeduplicated / (totalShown + totalDeduplicated)) * 100
      : 0;

  /// Error rate
  double get errorRate =>
      totalShown > 0 ? (totalErrors / totalShown) * 100 : 0;
}

/// Event types tracked by diagnostics
enum MessageEvent {
  /// Message was added to queue
  enqueued,

  /// Message was removed from queue
  dequeued,

  /// Message was displayed
  displayed,

  /// Message was dismissed
  dismissed,

  /// Message was deduplicated
  deduplicated,

  /// Message was dropped
  dropped,

  /// Error occurred
  error,
}

/// A diagnostic event record
@freezed
class MessageDiagnosticEvent with _$MessageDiagnosticEvent {
  const factory MessageDiagnosticEvent({
    required MessageEvent event,
    required DateTime timestamp,
    String? messageKey,
    String? details,
  }) = _MessageDiagnosticEvent;

  const MessageDiagnosticEvent._();
}
