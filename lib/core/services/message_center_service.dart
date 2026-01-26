import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/app_message.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/message_metrics.dart';

/// Callback type for message actions
typedef MessageActionCallback = void Function(Map<String, dynamic>? data);

/// Central hub for UX messaging, following ATT-FE-Tool patterns
class MessageCenterService {
  MessageCenterService._();

  static MessageCenterService? _instance;

  /// Singleton instance
  factory MessageCenterService() {
    _instance ??= MessageCenterService._();
    return _instance!;
  }

  /// Reset singleton for testing
  @visibleForTesting
  static void resetForTesting() {
    _instance?.dispose();
    _instance = null;
  }

  // Configuration
  static const int maxQueueSize = 20;
  static const Duration deduplicationWindow = Duration(seconds: 3);
  static const Duration stormWindow = Duration(seconds: 1);
  static const int stormThreshold = 5;
  static const Duration queuePollInterval = Duration(milliseconds: 100);

  // State
  final Queue<AppMessage> _messageQueue = Queue();
  final Map<String, DateTime> _deduplicationCache = {};
  final Map<String, int> _stormCounter = {};
  final List<MessageDiagnosticEvent> _eventHistory = [];
  final Map<String, MessageActionCallback> _actionCallbacks = {};

  // Streams
  final _messageController = StreamController<AppMessage>.broadcast();
  final _metricsController = StreamController<MessageMetrics>.broadcast();

  // Metrics tracking
  int _totalShown = 0;
  int _totalDeduplicated = 0;
  int _totalDropped = 0;
  int _totalErrors = 0;
  final Map<String, int> _byType = {};
  final Map<String, int> _byCategory = {};
  final Map<String, int> _bySource = {};
  DateTime? _sessionStart;
  DateTime? _lastMessageTime;

  Timer? _queueProcessor;
  bool _isProcessing = false;

  /// Stream of messages being displayed
  Stream<AppMessage> get messageStream => _messageController.stream;

  /// Stream of metrics updates
  Stream<MessageMetrics> get metricsStream => _metricsController.stream;

  /// Current queue size
  int get queueSize => _messageQueue.length;

  /// Recent diagnostic events
  List<MessageDiagnosticEvent> get recentEvents =>
      List.unmodifiable(_eventHistory);

  /// Initialize the message center
  void initialize() {
    _sessionStart = DateTime.now();
    _startQueueProcessor();
  }

  /// Show an info message
  void showInfo(
    String content, {
    String? actionLabel,
    String? actionKey,
    Map<String, dynamic>? actionData,
    String? sourceContext,
    String? deduplicationKey,
  }) {
    _enqueueMessage(
      content: content,
      type: MessageType.info,
      category: MessageCategory.general,
      priority: MessagePriority.normal,
      actionLabel: actionLabel,
      actionKey: actionKey,
      actionData: actionData,
      sourceContext: sourceContext,
      deduplicationKey: deduplicationKey,
    );
  }

  /// Show a success message
  void showSuccess(
    String content, {
    String? actionLabel,
    String? actionKey,
    Map<String, dynamic>? actionData,
    String? sourceContext,
    String? deduplicationKey,
  }) {
    _enqueueMessage(
      content: content,
      type: MessageType.success,
      category: MessageCategory.general,
      priority: MessagePriority.normal,
      actionLabel: actionLabel,
      actionKey: actionKey,
      actionData: actionData,
      sourceContext: sourceContext,
      deduplicationKey: deduplicationKey,
    );
  }

  /// Show a warning message
  void showWarning(
    String content, {
    MessageCategory category = MessageCategory.general,
    String? actionLabel,
    String? actionKey,
    Map<String, dynamic>? actionData,
    String? sourceContext,
    String? deduplicationKey,
  }) {
    _enqueueMessage(
      content: content,
      type: MessageType.warning,
      category: category,
      priority: MessagePriority.normal,
      actionLabel: actionLabel,
      actionKey: actionKey,
      actionData: actionData,
      sourceContext: sourceContext,
      deduplicationKey: deduplicationKey,
    );
  }

  /// Show an error message
  void showError(
    String content, {
    MessageCategory category = MessageCategory.general,
    String? actionLabel,
    String? actionKey,
    Map<String, dynamic>? actionData,
    String? sourceContext,
    String? deduplicationKey,
  }) {
    _enqueueMessage(
      content: content,
      type: MessageType.error,
      category: category,
      priority: MessagePriority.high,
      actionLabel: actionLabel,
      actionKey: actionKey,
      actionData: actionData,
      sourceContext: sourceContext,
      deduplicationKey: deduplicationKey,
    );
  }

  /// Show a critical message
  void showCritical(
    String content, {
    MessageCategory category = MessageCategory.system,
    String? actionLabel,
    String? actionKey,
    Map<String, dynamic>? actionData,
    String? sourceContext,
    String? deduplicationKey,
  }) {
    _enqueueMessage(
      content: content,
      type: MessageType.critical,
      category: category,
      priority: MessagePriority.critical,
      actionLabel: actionLabel,
      actionKey: actionKey,
      actionData: actionData,
      sourceContext: sourceContext,
      deduplicationKey: deduplicationKey,
    );
  }

  /// Show a transient message (disappears quickly)
  void showTransient(String content) {
    _enqueueMessage(
      content: content,
      type: MessageType.transient,
      category: MessageCategory.general,
      priority: MessagePriority.low,
    );
  }

  /// Register an action callback
  void registerAction(String actionKey, MessageActionCallback callback) {
    _actionCallbacks[actionKey] = callback;
  }

  /// Unregister an action callback
  void unregisterAction(String actionKey) {
    _actionCallbacks.remove(actionKey);
  }

  /// Execute a registered action
  void executeAction(String actionKey, {Map<String, dynamic>? data}) {
    final callback = _actionCallbacks[actionKey];
    if (callback != null) {
      callback(data);
    }
  }

  /// Get current metrics
  MessageMetrics getMetrics() {
    final healthScore = _calculateHealthScore();
    final issues = _identifyIssues();
    final recommendations = _generateRecommendations(issues);

    return MessageMetrics(
      totalShown: _totalShown,
      totalDeduplicated: _totalDeduplicated,
      totalDropped: _totalDropped,
      totalErrors: _totalErrors,
      queueSize: _messageQueue.length,
      maxQueueSize: maxQueueSize,
      byType: Map.unmodifiable(_byType),
      byCategory: Map.unmodifiable(_byCategory),
      bySource: Map.unmodifiable(_bySource),
      sessionStart: _sessionStart,
      lastMessageTime: _lastMessageTime,
      healthScore: healthScore,
      issues: issues,
      recommendations: recommendations,
    );
  }

  /// Clear all data and reset
  void clear() {
    _messageQueue.clear();
    _deduplicationCache.clear();
    _stormCounter.clear();
    _eventHistory.clear();
    _totalShown = 0;
    _totalDeduplicated = 0;
    _totalDropped = 0;
    _totalErrors = 0;
    _byType.clear();
    _byCategory.clear();
    _bySource.clear();
    _lastMessageTime = null;
  }

  /// Dispose resources
  void dispose() {
    _queueProcessor?.cancel();
    _messageController.close();
    _metricsController.close();
  }

  void _enqueueMessage({
    required String content,
    required MessageType type,
    required MessageCategory category,
    required MessagePriority priority,
    String? actionLabel,
    String? actionKey,
    Map<String, dynamic>? actionData,
    String? sourceContext,
    String? deduplicationKey,
  }) {
    final dedupKey = deduplicationKey ?? _generateDeduplicationKey(content, type);

    // Check for deduplication
    if (_isDuplicate(dedupKey)) {
      _totalDeduplicated++;
      _recordEvent(MessageEvent.deduplicated, dedupKey);
      return;
    }

    // Check for message storm
    if (_isStorm(dedupKey)) {
      _totalDropped++;
      _recordEvent(MessageEvent.dropped, dedupKey, details: 'storm');
      return;
    }

    // Create message
    final message = AppMessage(
      id: _generateId(),
      content: content,
      type: type,
      category: category,
      priority: priority,
      timestamp: DateTime.now(),
      action: actionLabel != null && actionKey != null
          ? MessageAction(
              label: actionLabel,
              actionKey: actionKey,
              data: actionData,
            )
          : null,
      sourceContext: sourceContext,
      deduplicationKey: dedupKey,
    );

    // Enqueue with priority handling
    if (!_enqueueWithPriority(message)) {
      _totalDropped++;
      _recordEvent(MessageEvent.dropped, dedupKey, details: 'queue_full');
      return;
    }

    _deduplicationCache[dedupKey] = DateTime.now();
    _stormCounter[dedupKey] = (_stormCounter[dedupKey] ?? 0) + 1;
    _recordEvent(MessageEvent.enqueued, dedupKey);
  }

  bool _enqueueWithPriority(AppMessage message) {
    if (_messageQueue.length >= maxQueueSize) {
      // Try to remove lower priority messages
      if (message.priority == MessagePriority.critical ||
          message.priority == MessagePriority.high) {
        final removed = _removeLowestPriority();
        if (!removed) return false;
      } else {
        return false;
      }
    }

    // Add message to queue (critical/high go to front)
    if (message.priority == MessagePriority.critical ||
        message.priority == MessagePriority.high) {
      _messageQueue.addFirst(message);
    } else {
      _messageQueue.addLast(message);
    }

    return true;
  }

  bool _removeLowestPriority() {
    AppMessage? lowest;
    for (final msg in _messageQueue) {
      if (msg.priority == MessagePriority.low) {
        lowest = msg;
        break;
      } else if (msg.priority == MessagePriority.normal && lowest == null) {
        lowest = msg;
      }
    }

    if (lowest != null) {
      _messageQueue.remove(lowest);
      return true;
    }
    return false;
  }

  bool _isDuplicate(String dedupKey) {
    final lastTime = _deduplicationCache[dedupKey];
    if (lastTime == null) return false;

    final now = DateTime.now();
    if (now.difference(lastTime) < deduplicationWindow) {
      return true;
    }

    // Clean up expired entry
    _deduplicationCache.remove(dedupKey);
    return false;
  }

  bool _isStorm(String dedupKey) {
    final count = _stormCounter[dedupKey] ?? 0;
    if (count >= stormThreshold) {
      // Reset counter after storm detection
      _stormCounter[dedupKey] = 0;
      return true;
    }
    return false;
  }

  void _startQueueProcessor() {
    _queueProcessor = Timer.periodic(queuePollInterval, (_) {
      _processQueue();
    });
  }

  void _processQueue() {
    if (_isProcessing || _messageQueue.isEmpty) return;
    _isProcessing = true;

    try {
      final message = _messageQueue.removeFirst();
      _recordEvent(MessageEvent.dequeued, message.deduplicationKey);

      // Update metrics
      _totalShown++;
      _lastMessageTime = DateTime.now();
      _byType[message.type.name] = (_byType[message.type.name] ?? 0) + 1;
      _byCategory[message.category.name] =
          (_byCategory[message.category.name] ?? 0) + 1;
      if (message.sourceContext != null) {
        _bySource[message.sourceContext!] =
            (_bySource[message.sourceContext!] ?? 0) + 1;
      }

      // Emit message
      _messageController.add(message);
      _recordEvent(MessageEvent.displayed, message.deduplicationKey);

      // Emit updated metrics
      _metricsController.add(getMetrics());

      // Clean up storm counter
      Timer(stormWindow, () {
        _stormCounter[message.deduplicationKey ?? ''] = 0;
      });
    } finally {
      _isProcessing = false;
    }
  }

  void _recordEvent(MessageEvent event, String? messageKey, {String? details}) {
    _eventHistory.add(MessageDiagnosticEvent(
      event: event,
      timestamp: DateTime.now(),
      messageKey: messageKey,
      details: details,
    ));

    // Limit history size
    while (_eventHistory.length > 200) {
      _eventHistory.removeAt(0);
    }

    if (event == MessageEvent.error) {
      _totalErrors++;
    }
  }

  int _calculateHealthScore() {
    var score = 100;

    // Penalize for errors
    if (_totalShown > 0) {
      final errorRate = _totalErrors / _totalShown;
      if (errorRate > 0.1) score -= 50;
      else if (errorRate > 0.05) score -= 25;
    }

    // Penalize for dropped messages
    if (_totalDropped > 10) score -= 30;
    else if (_totalDropped > 5) score -= 15;

    // Bonus for good deduplication
    if (_totalDeduplicated > 0 && _totalShown > 0) {
      final dedupRate = _totalDeduplicated / (_totalShown + _totalDeduplicated);
      if (dedupRate > 0.3) score += 10;
    }

    return score.clamp(0, 100);
  }

  List<String> _identifyIssues() {
    final issues = <String>[];

    if (_totalShown > 0 && _totalErrors / _totalShown > 0.1) {
      issues.add('High error rate detected');
    }

    if (_totalDropped > 10) {
      issues.add('Many messages being dropped');
    }

    if (_messageQueue.length > maxQueueSize * 0.8) {
      issues.add('Queue nearly full');
    }

    return issues;
  }

  List<String> _generateRecommendations(List<String> issues) {
    final recommendations = <String>[];

    for (final issue in issues) {
      switch (issue) {
        case 'High error rate detected':
          recommendations.add('Check network connectivity and server status');
          break;
        case 'Many messages being dropped':
          recommendations.add('Reduce message frequency or increase queue size');
          break;
        case 'Queue nearly full':
          recommendations.add('Process messages faster or reduce generation rate');
          break;
      }
    }

    return recommendations;
  }

  String _generateId() {
    return 'msg_${DateTime.now().millisecondsSinceEpoch}_${_totalShown + _messageQueue.length}';
  }

  String _generateDeduplicationKey(String content, MessageType type) {
    return '${type.name}_${content.hashCode}';
  }
}
