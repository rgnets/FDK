import 'package:flutter/foundation.dart';
import 'package:rgnets_fdk/core/services/message_center_service.dart';
import 'package:rgnets_fdk/features/messages/domain/entities/app_message.dart';

/// Represents an error collected during startup
class StartupError {
  const StartupError({
    required this.message,
    required this.timestamp,
    this.context,
    this.isWarning = false,
    this.stackTrace,
  });

  final String message;
  final DateTime timestamp;
  final String? context;
  final bool isWarning;
  final String? stackTrace;
}

/// Collects errors that occur before the MessageCenter UI is ready.
///
/// Usage:
/// ```dart
/// // During startup (before UI ready)
/// StartupErrorCollector.addError('Network init failed', context: 'initialization');
///
/// // Once UI ready, flush all queued errors
/// StartupErrorCollector.flushToMessageCenter();
/// ```
class StartupErrorCollector {
  StartupErrorCollector._();

  static final List<StartupError> _errors = [];
  static bool _isFlushed = false;

  /// Add an error to the queue
  static void addError(
    String message, {
    String? context,
    String? stackTrace,
  }) {
    if (_isFlushed) {
      // If already flushed, send directly to message center
      MessageCenterService().showError(
        message,
        category: MessageCategory.system,
        sourceContext: context ?? 'startup',
      );
      return;
    }

    _errors.add(StartupError(
      message: message,
      timestamp: DateTime.now(),
      context: context,
      isWarning: false,
      stackTrace: stackTrace,
    ));

    if (kDebugMode) {
      debugPrint('[StartupErrorCollector] Error: $message');
      if (stackTrace != null) {
        debugPrint(stackTrace);
      }
    }
  }

  /// Add a warning to the queue
  static void addWarning(
    String message, {
    String? context,
  }) {
    if (_isFlushed) {
      MessageCenterService().showWarning(
        message,
        category: MessageCategory.system,
        sourceContext: context ?? 'startup',
      );
      return;
    }

    _errors.add(StartupError(
      message: message,
      timestamp: DateTime.now(),
      context: context,
      isWarning: true,
    ));

    if (kDebugMode) {
      debugPrint('[StartupErrorCollector] Warning: $message');
    }
  }

  /// Get all collected errors
  static List<StartupError> get errors => List.unmodifiable(_errors);

  /// Check if there are any errors
  static bool get hasErrors => _errors.any((e) => !e.isWarning);

  /// Check if there are any warnings
  static bool get hasWarnings => _errors.any((e) => e.isWarning);

  /// Get the count of errors
  static int get errorCount => _errors.where((e) => !e.isWarning).length;

  /// Get the count of warnings
  static int get warningCount => _errors.where((e) => e.isWarning).length;

  /// Flush all errors to the MessageCenter with staggered delays
  static Future<void> flushToMessageCenter({
    Duration delayBetween = const Duration(milliseconds: 500),
  }) async {
    if (_isFlushed) return;
    _isFlushed = true;

    final messageCenter = MessageCenterService();
    final sortedErrors = List<StartupError>.from(_errors)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (var i = 0; i < sortedErrors.length; i++) {
      final error = sortedErrors[i];

      if (i > 0) {
        await Future.delayed(delayBetween);
      }

      if (error.isWarning) {
        messageCenter.showWarning(
          error.message,
          category: MessageCategory.system,
          sourceContext: error.context ?? 'startup',
          deduplicationKey: 'startup_${error.message.hashCode}',
        );
      } else {
        messageCenter.showError(
          error.message,
          category: MessageCategory.system,
          sourceContext: error.context ?? 'startup',
          deduplicationKey: 'startup_${error.message.hashCode}',
        );
      }
    }

    _errors.clear();
  }

  /// Clear all collected errors without flushing
  static void clear() {
    _errors.clear();
  }

  /// Reset the collector state (for testing)
  @visibleForTesting
  static void reset() {
    _errors.clear();
    _isFlushed = false;
  }
}
